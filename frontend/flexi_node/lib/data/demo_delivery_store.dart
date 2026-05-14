import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

enum DemoDeliveryStatus {
  onDelivery,
  trafficDetected,
  offerPending,
  reroutedToNode,
  deliveredToNode,
  completed,
}

class AiChatMessage {
  const AiChatMessage({
    required this.sender,
    required this.message,
    required this.type,
  });

  final String sender;
  final String message;
  final String type;

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      sender: json['sender'] as String? ?? 'System',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
    );
  }
}

class DemoDeliveryStore extends ChangeNotifier {
  DemoDeliveryStore() {
    _initAuth();
  }

  final String _deliveryId = 'paket_001';
  final String nodeId = 'node_001';

  DemoDeliveryStatus status = DemoDeliveryStatus.onDelivery;

  final String orderId = 'SD1440-Y';
  String receiverName = 'Andika Sujanto';
  String driverName = 'Rizky Fahmi';
  String nodeName = 'Indomaret Ahmad Yani';
  String nodeDistance = '75m';
  String walkingTime = '2 min';
  int cashbackAmount = 5000;
  String otpCode = '';

  String trafficStatus = 'normal';
  int delayMinutes = 0;
  bool offerCreated = false;
  bool offerAccepted = false;
  bool dropoffConfirmed = false;
  bool isChatLoading = false;

  List<AiChatMessage> aiMessages = [
    const AiChatMessage(
      sender: 'System',
      type: 'system',
      message:
          'Delivery SD1440-Y started. Courier is heading to receiver address.',
    ),
  ];

  String get deliveryId => _deliveryId;

  String get _apiUrl {
    return kIsWeb
        ? 'http://127.0.0.1:5001/demo-no-project/us-central1/api'
        : 'http://10.0.2.2:5001/demo-no-project/us-central1/api';
  }

  void _initAuth() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenToDelivery();
        _listenToChat();
        _seedDummyData(user.uid);
      }
    });
  }

  void _listenToDelivery() {
    FirebaseFirestore.instance
        .collection('deliveries')
        .doc(_deliveryId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final data = doc.data()!;

      delayMinutes = data['delayMinutes'] as int? ?? 0;
      trafficStatus = delayMinutes > 15 ? 'heavy' : 'normal';

      receiverName = data['receiverName'] as String? ?? receiverName;
      driverName = data['driverName'] as String? ?? driverName;
      nodeName = data['selectedNodeName'] as String? ?? nodeName;
      otpCode = data['otpCode']?.toString() ?? otpCode;

      final String docStatus = data['status'] as String? ?? 'on_delivery';

      if (docStatus == 'on_delivery' && delayMinutes > 15) {
        status = DemoDeliveryStatus.offerPending;
        offerCreated = true;
      } else if (docStatus == 'rerouted_to_node') {
        status = DemoDeliveryStatus.reroutedToNode;
        offerAccepted = true;
        offerCreated = true;
      } else if (docStatus == 'delivered_to_node') {
        status = DemoDeliveryStatus.deliveredToNode;
        offerAccepted = true;
        offerCreated = true;
        dropoffConfirmed = true;
      } else if (docStatus == 'completed') {
        status = DemoDeliveryStatus.completed;
        offerAccepted = true;
        offerCreated = true;
        dropoffConfirmed = true;
      } else {
        status = DemoDeliveryStatus.onDelivery;
        offerCreated = false;
        offerAccepted = false;
        dropoffConfirmed = false;
      }

      notifyListeners();
    }, onError: (e) {
      debugPrint('Firestore delivery listener error: $e');
    });
  }

  void _listenToChat() {
    FirebaseFirestore.instance
        .collection('AI_message')
        .where(
          'receiverId',
          isEqualTo: FirebaseAuth.instance.currentUser?.uid,
        )
        .snapshots()
        .listen((snapshot) {
      try {
        final docs = snapshot.docs.toList();

        docs.sort((a, b) {
          final tA = a.data()['createdAt'] as Timestamp?;
          final tB = b.data()['createdAt'] as Timestamp?;

          if (tA == null && tB == null) return 0;
          if (tA == null) return 1;
          if (tB == null) return -1;

          return tA.compareTo(tB);
        });

        aiMessages = docs.map((doc) {
          return AiChatMessage.fromJson(doc.data());
        }).toList();

        if (aiMessages.isEmpty) {
          aiMessages.add(
            const AiChatMessage(
              sender: 'System',
              type: 'system',
              message:
                  'Delivery SD1440-Y started. Courier is heading to receiver address.',
            ),
          );
        }

        notifyListeners();
      } catch (e) {
        debugPrint('Error processing chat snapshot: $e');
      }
    }, onError: (e) {
      debugPrint('Firestore chat listener error: $e');
    });
  }

  Future<void> _seedDummyData(String uid) async {
    try {
      final doc = FirebaseFirestore.instance
          .collection('deliveries')
          .doc(_deliveryId);

      final snap = await doc.get();

      if (!snap.exists || snap.data()?['receiverId'] != uid) {
        await doc.set({
          'receiverId': uid,
          'receiverName': receiverName,
          'driverId': 'driver_123',
          'driverName': driverName,
          'status': 'on_delivery',
          'delayMinutes': 0,
          'selectedNodeId': null,
          'selectedNodeName': null,
          'otpCode': '',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint(
        'Seed data skipped due to rules, which is fine if backend handles it: $e',
      );
    }
  }

  String get safeOtpCode => otpCode.isNotEmpty ? otpCode : '8421';

  String get formattedCashback {
    return 'Rp${cashbackAmount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  String get statusText {
    switch (status) {
      case DemoDeliveryStatus.onDelivery:
        return 'on_delivery';
      case DemoDeliveryStatus.trafficDetected:
        return 'traffic_detected';
      case DemoDeliveryStatus.offerPending:
        return 'offer_pending';
      case DemoDeliveryStatus.reroutedToNode:
        return 'rerouted_to_node';
      case DemoDeliveryStatus.deliveredToNode:
        return 'delivered_to_node';
      case DemoDeliveryStatus.completed:
        return 'completed';
    }
  }

  bool get shouldRouteToNode {
    return status == DemoDeliveryStatus.reroutedToNode ||
        status == DemoDeliveryStatus.deliveredToNode ||
        status == DemoDeliveryStatus.completed;
  }

  bool get canShowOffer {
    return status == DemoDeliveryStatus.offerPending && !offerAccepted;
  }

  String get driverQrPayload {
    return jsonEncode({
      'type': 'driver_dropoff',
      'deliveryId': _deliveryId,
      'orderId': orderId,
      'driverId': 'driver_123',
      'driverName': driverName,
      'nodeId': nodeId,
      'nodeName': nodeName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  String get receiverQrPayload {
    return jsonEncode({
      'type': 'receiver_pickup',
      'deliveryId': _deliveryId,
      'orderId': orderId,
      'receiverId': FirebaseAuth.instance.currentUser?.uid ?? 'receiver_demo',
      'receiverName': receiverName,
      'otpCode': safeOtpCode,
      'nodeId': nodeId,
      'nodeName': nodeName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  String get mitraQrPayload {
    return jsonEncode({
      'type': 'mitra_node',
      'nodeId': nodeId,
      'nodeName': nodeName,
      'deliveryId': _deliveryId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> simulateHeavyTraffic() async {
    try {
      await http.post(
        Uri.parse('$_apiUrl/simulate-traffic'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deliveryId': _deliveryId,
          'delayMinutes': 20,
        }),
      );
    } catch (e) {
      debugPrint('Error simulating traffic: $e');
      _localSetOfferPending();
    }
  }

  Future<void> acceptPickupOffer() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      _localAcceptOffer();
      return;
    }

    try {
      await http.post(
        Uri.parse('$_apiUrl/accept-offer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deliveryId': _deliveryId,
          'receiverId': uid,
          'nodeId': nodeId,
          'nodeName': nodeName,
          'cashbackAmount': cashbackAmount,
        }),
      );
    } catch (e) {
      debugPrint('Error accepting offer: $e');
      _localAcceptOffer();
    }
  }

  Future<void> confirmDropoff() async {
    await markReceivedByMitra(source: 'driver_app');
  }

  Future<void> markReceivedByMitra({
    required String source,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('deliveries')
          .doc(_deliveryId)
          .update({
        'status': 'delivered_to_node',
        'selectedNodeId': nodeId,
        'selectedNodeName': nodeName,
        'mitraReceivedAt': FieldValue.serverTimestamp(),
        'mitraReceiveSource': source,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      aiMessages.add(
        AiChatMessage(
          sender: 'Mitra',
          type: 'mitra',
          message: 'Package received by $nodeName through $source.',
        ),
      );
    } catch (e) {
      debugPrint('Error marking package received by mitra: $e');

      status = DemoDeliveryStatus.deliveredToNode;
      dropoffConfirmed = true;
      offerAccepted = true;
      offerCreated = true;

      aiMessages.add(
        AiChatMessage(
          sender: 'Mitra',
          type: 'mitra',
          message: 'Package received by $nodeName through $source.',
        ),
      );

      notifyListeners();
    }
  }

  Future<void> markCompletedByReceiver({
    required String source,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('deliveries')
          .doc(_deliveryId)
          .update({
        'status': 'completed',
        'receiverPickedUpAt': FieldValue.serverTimestamp(),
        'receiverPickupSource': source,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      aiMessages.add(
        AiChatMessage(
          sender: 'Mitra',
          type: 'mitra',
          message:
              'Package released to $receiverName through $source. Delivery completed.',
        ),
      );
    } catch (e) {
      debugPrint('Error completing pickup: $e');

      status = DemoDeliveryStatus.completed;
      dropoffConfirmed = true;
      offerAccepted = true;
      offerCreated = true;

      aiMessages.add(
        AiChatMessage(
          sender: 'Mitra',
          type: 'mitra',
          message:
              'Package released to $receiverName through $source. Delivery completed.',
        ),
      );

      notifyListeners();
    }
  }

  Future<String> processScannedQr(
    String rawValue, {
    String? expectedType,
  }) async {
    final decoded = jsonDecode(rawValue);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid QR payload.');
    }

    final type = decoded['type']?.toString();
    final scannedDeliveryId = decoded['deliveryId']?.toString();

    if (type == null) {
      throw Exception('QR type is missing.');
    }

    if (expectedType != null && expectedType != type) {
      throw Exception(
        'Wrong QR type. Expected $expectedType but got $type.',
      );
    }

    if (scannedDeliveryId != null && scannedDeliveryId != _deliveryId) {
      throw Exception('This QR belongs to a different package.');
    }

    if (type == 'driver_dropoff') {
      if (!shouldRouteToNode && status != DemoDeliveryStatus.offerPending) {
        throw Exception('Package has not been rerouted to this node yet.');
      }

      await markReceivedByMitra(source: 'driver_qr_scan');

      return 'Package $orderId received by $nodeName. Status changed to delivered_to_node.';
    }

    if (type == 'receiver_pickup') {
      final scannedOtp = decoded['otpCode']?.toString();

      if (status != DemoDeliveryStatus.deliveredToNode &&
          status != DemoDeliveryStatus.completed) {
        throw Exception(
          'Package is not stored at this node yet. Scan driver QR first.',
        );
      }

      if (scannedOtp != safeOtpCode) {
        throw Exception('OTP does not match.');
      }

      await markCompletedByReceiver(source: 'receiver_qr_scan');

      return 'Package $orderId released to $receiverName. Status changed to completed.';
    }

    if (type == 'mitra_node') {
      return 'Mitra node verified: $nodeName.';
    }

    throw Exception('Unsupported QR type: $type.');
  }

  Future<void> sendChatMessage(String message) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || message.trim().isEmpty) return;

    isChatLoading = true;
    notifyListeners();

    try {
      await http.post(
        Uri.parse('$_apiUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deliveryId': _deliveryId,
          'receiverId': uid,
          'message': message,
        }),
      );
    } catch (e) {
      debugPrint('Error sending chat: $e');
    } finally {
      isChatLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetDemo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      _localReset();
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('deliveries')
          .doc(_deliveryId)
          .set({
        'receiverId': uid,
        'receiverName': receiverName,
        'driverId': 'driver_123',
        'driverName': driverName,
        'status': 'on_delivery',
        'delayMinutes': 0,
        'selectedNodeId': null,
        'selectedNodeName': null,
        'otpCode': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error resetting demo: $e');
      _localReset();
    }
  }

  void _localSetOfferPending() {
    status = DemoDeliveryStatus.offerPending;
    trafficStatus = 'heavy';
    delayMinutes = 20;
    offerCreated = true;
    offerAccepted = false;
    dropoffConfirmed = false;

    aiMessages
      ..clear()
      ..addAll([
        const AiChatMessage(
          sender: 'System',
          type: 'system',
          message: 'Traffic simulation started by driver.',
        ),
        const AiChatMessage(
          sender: 'Flexi AI',
          type: 'observe',
          message: 'Heavy traffic detected near receiver location.',
        ),
        const AiChatMessage(
          sender: 'Flexi AI',
          type: 'reason',
          message:
              'Current delay estimate is 20 minutes. Cost of delay is higher than Rp5.000 cashback.',
        ),
        const AiChatMessage(
          sender: 'Flexi AI',
          type: 'select_node',
          message:
              'Recommended node found: Indomaret Ahmad Yani, 75m from receiver, with 6 available slots.',
        ),
        const AiChatMessage(
          sender: 'Flexi AI',
          type: 'action',
          message: 'Pickup offer sent to receiver. Waiting for receiver approval.',
        ),
      ]);

    notifyListeners();
  }

  void _localAcceptOffer() {
    status = DemoDeliveryStatus.reroutedToNode;
    offerCreated = true;
    offerAccepted = true;
    dropoffConfirmed = false;
    otpCode = safeOtpCode;

    aiMessages.addAll([
      const AiChatMessage(
        sender: 'Receiver',
        type: 'receiver',
        message: 'Accept & Pick Up selected.',
      ),
      const AiChatMessage(
        sender: 'System',
        type: 'system',
        message: 'Delivery destination updated to Indomaret Ahmad Yani.',
      ),
      const AiChatMessage(
        sender: 'Flexi AI',
        type: 'action',
        message: 'Driver route has been updated to the selected pickup node.',
      ),
    ]);

    notifyListeners();
  }

  void _localReset() {
    status = DemoDeliveryStatus.onDelivery;
    trafficStatus = 'normal';
    delayMinutes = 0;
    offerCreated = false;
    offerAccepted = false;
    dropoffConfirmed = false;
    otpCode = '';

    aiMessages
      ..clear()
      ..add(
        const AiChatMessage(
          sender: 'System',
          type: 'system',
          message:
              'Delivery SD1440-Y started. Courier is heading to receiver address.',
        ),
      );

    notifyListeners();
  }
}

final demoDeliveryStore = DemoDeliveryStore();