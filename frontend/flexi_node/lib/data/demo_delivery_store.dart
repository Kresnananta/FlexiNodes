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

class DemoPickupNode {
  const DemoPickupNode({
    required this.id,
    required this.name,
    required this.distance,
    required this.walkingTime,
    required this.status,
    required this.capacity,
    required this.voucherText,
    required this.voucherAmount,
    required this.latitude,
    required this.longitude,
    this.recommended = false,
  });

  final String id;
  final String name;
  final String distance;
  final String walkingTime;
  final String status;
  final String capacity;
  final String voucherText;
  final int voucherAmount;
  final double latitude;
  final double longitude;
  final bool recommended;
}

class DemoDeliveryStore extends ChangeNotifier {
  DemoDeliveryStore() {
    _initAuth();
  }

  final String _deliveryId = 'paket_001';

  static const List<DemoPickupNode> availableNodes = [
    DemoPickupNode(
      id: 'node_001',
      name: 'Indomaret Ahmad Yani',
      distance: '75m',
      walkingTime: '2 min',
      status: 'Available',
      capacity: '6 slots',
      voucherText: 'Rp5.000',
      voucherAmount: 5000,
      latitude: -7.2812,
      longitude: 112.7521,
      recommended: true,
    ),
    DemoPickupNode(
      id: 'node_002',
      name: 'Warung Bu Sari',
      distance: '90m',
      walkingTime: '3 min',
      status: 'Available',
      capacity: '3 slots',
      voucherText: 'Rp4.000',
      voucherAmount: 4000,
      latitude: -7.2809,
      longitude: 112.7542,
    ),
    DemoPickupNode(
      id: 'node_003',
      name: 'Alfamart Kertajaya',
      distance: '100m',
      walkingTime: '4 min',
      status: 'Almost full',
      capacity: '1 slot',
      voucherText: 'Rp6.000',
      voucherAmount: 6000,
      latitude: -7.2827,
      longitude: 112.7534,
    ),
  ];

  DemoDeliveryStatus status = DemoDeliveryStatus.onDelivery;

  final String orderId = 'SD1440-Y';
  String receiverName = 'Andika Sujanto';
  String driverName = 'Rizky Fahmi';

  String nodeId = availableNodes.first.id;
  String nodeName = availableNodes.first.name;
  String nodeDistance = availableNodes.first.distance;
  String walkingTime = availableNodes.first.walkingTime;
  String nodeStatus = availableNodes.first.status;
  String nodeCapacity = availableNodes.first.capacity;
  double nodeLatitude = availableNodes.first.latitude;
  double nodeLongitude = availableNodes.first.longitude;

  int voucherAmount = availableNodes.first.voucherAmount;
  String otpCode = '';

  String trafficStatus = 'normal';
  int delayMinutes = 0;
  bool offerCreated = false;
  bool offerAccepted = false;
  bool dropoffConfirmed = false;
  bool homeDeliverySelected = false;
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

  // Online Cloud Function / Cloud Run API
  String get _apiUrl {
    return 'https://api-mw5zqv12rq-uc.a.run.app';
  }

  // Use this instead if you want local Firebase emulator API:
  /*
  String get _apiUrl {
    return kIsWeb
        ? 'http://127.0.0.1:5001/demo-no-project/us-central1/api'
        : 'http://10.0.2.2:5001/demo-no-project/us-central1/api';
  }
  */

  DemoPickupNode get selectedNode {
    return availableNodes.firstWhere(
      (node) => node.id == nodeId,
      orElse: () => availableNodes.first,
    );
  }

  void selectPickupNode(DemoPickupNode node) {
    nodeId = node.id;
    nodeName = node.name;
    nodeDistance = node.distance;
    walkingTime = node.walkingTime;
    nodeStatus = node.status;
    nodeCapacity = node.capacity;
    nodeLatitude = node.latitude;
    nodeLongitude = node.longitude;
    voucherAmount = node.voucherAmount;
    homeDeliverySelected = false;

    _addLocalAiMessage(
      sender: 'Receiver',
      type: 'receiver',
      message: 'Selected pickup node: ${node.name}.',
      shouldNotify: false,
    );

    notifyListeners();
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

      nodeId = data['selectedNodeId'] as String? ?? nodeId;
      nodeName = data['selectedNodeName'] as String? ?? nodeName;
      nodeLatitude = (data['selectedNodeLat'] as num?)?.toDouble() ?? nodeLatitude;
      nodeLongitude = (data['selectedNodeLng'] as num?)?.toDouble() ?? nodeLongitude;

      final matchedNode = availableNodes.where((node) => node.id == nodeId).toList();
      if (matchedNode.isNotEmpty) {
        nodeDistance = matchedNode.first.distance;
        walkingTime = matchedNode.first.walkingTime;
        nodeStatus = matchedNode.first.status;
        nodeCapacity = matchedNode.first.capacity;
        voucherAmount = matchedNode.first.voucherAmount;
      }

      otpCode = data['otpCode']?.toString() ?? otpCode;
      homeDeliverySelected = data['homeDeliverySelected'] as bool? ?? homeDeliverySelected;

      final String docStatus = data['status'] as String? ?? 'on_delivery';

      if (docStatus == 'on_delivery' && delayMinutes > 15 && !homeDeliverySelected) {
        status = DemoDeliveryStatus.offerPending;
        offerCreated = true;
      } else if (docStatus == 'rerouted_to_node') {
        status = DemoDeliveryStatus.reroutedToNode;
        offerAccepted = true;
        offerCreated = true;
        homeDeliverySelected = false;
      } else if (docStatus == 'delivered_to_node') {
        status = DemoDeliveryStatus.deliveredToNode;
        offerAccepted = true;
        offerCreated = true;
        dropoffConfirmed = true;
        homeDeliverySelected = false;
      } else if (docStatus == 'completed') {
        status = DemoDeliveryStatus.completed;
        offerAccepted = true;
        offerCreated = true;
        dropoffConfirmed = true;
        homeDeliverySelected = false;
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
          'homeDeliverySelected': false,
          'voucherIssued': false,
          'selectedNodeId': nodeId,
          'selectedNodeName': nodeName,
          'selectedNodeLat': nodeLatitude,
          'selectedNodeLng': nodeLongitude,
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

  String get formattedVoucher {
    return 'Rp${voucherAmount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  // Backward compatibility for old pages still referencing formattedCashback.
  String get formattedCashback => formattedVoucher;

  bool get voucherEligible {
    return offerAccepted && !homeDeliverySelected;
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
    return status == DemoDeliveryStatus.offerPending &&
        !offerAccepted &&
        !homeDeliverySelected;
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

  Future<void> keepHomeDelivery() async {
    homeDeliverySelected = true;
    offerAccepted = false;
    offerCreated = false;

    _addLocalAiMessage(
      sender: 'Receiver',
      type: 'receiver',
      message: 'Receiver chose to keep door-to-door delivery. No voucher will be issued.',
    );

    try {
      await FirebaseFirestore.instance
          .collection('deliveries')
          .doc(_deliveryId)
          .update({
        'status': 'on_delivery',
        'homeDeliverySelected': true,
        'voucherIssued': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error keeping home delivery: $e');
      notifyListeners();
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
          'cashbackAmount': voucherAmount,
          'voucherAmount': voucherAmount,
          'nodeLat': nodeLatitude,
          'nodeLng': nodeLongitude,
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
        'selectedNodeLat': nodeLatitude,
        'selectedNodeLng': nodeLongitude,
        'mitraReceivedAt': FieldValue.serverTimestamp(),
        'mitraReceiveSource': source,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _addLocalAiMessage(
        sender: 'Mitra',
        type: 'mitra',
        message: 'Package received by $nodeName through $source.',
      );
    } catch (e) {
      debugPrint('Error marking package received by mitra: $e');

      status = DemoDeliveryStatus.deliveredToNode;
      dropoffConfirmed = true;
      offerAccepted = true;
      offerCreated = true;
      homeDeliverySelected = false;

      _addLocalAiMessage(
        sender: 'Mitra',
        type: 'mitra',
        message: 'Package received by $nodeName through $source.',
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

      _addLocalAiMessage(
        sender: 'Mitra',
        type: 'mitra',
        message:
            'Package released to $receiverName through $source. Delivery completed.',
      );
    } catch (e) {
      debugPrint('Error completing pickup: $e');

      status = DemoDeliveryStatus.completed;
      dropoffConfirmed = true;
      offerAccepted = true;
      offerCreated = true;
      homeDeliverySelected = false;

      _addLocalAiMessage(
        sender: 'Mitra',
        type: 'mitra',
        message:
            'Package released to $receiverName through $source. Delivery completed.',
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
      final defaultNode = availableNodes.first;

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
        'homeDeliverySelected': false,
        'voucherIssued': false,
        'selectedNodeId': defaultNode.id,
        'selectedNodeName': defaultNode.name,
        'selectedNodeLat': defaultNode.latitude,
        'selectedNodeLng': defaultNode.longitude,
        'otpCode': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      selectPickupNode(defaultNode);
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
    homeDeliverySelected = false;

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
              'Current delay estimate is 20 minutes. Offering a pickup voucher is cheaper than forcing the courier through traffic.',
        ),
        AiChatMessage(
          sender: 'Flexi AI',
          type: 'select_node',
          message:
              'Recommended node found: $nodeName, $nodeDistance from receiver, with $nodeCapacity.',
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
    homeDeliverySelected = false;
    dropoffConfirmed = false;
    otpCode = safeOtpCode;

    aiMessages.addAll([
      const AiChatMessage(
        sender: 'Receiver',
        type: 'receiver',
        message: 'Accept & Pick Up selected.',
      ),
      AiChatMessage(
        sender: 'System',
        type: 'system',
        message: 'Delivery destination updated to $nodeName.',
      ),
      AiChatMessage(
        sender: 'Flexi AI',
        type: 'action',
        message: 'Driver route has been updated. Pickup voucher $formattedVoucher will be issued.',
      ),
    ]);

    notifyListeners();
  }

  void _localReset() {
    final defaultNode = availableNodes.first;

    status = DemoDeliveryStatus.onDelivery;
    trafficStatus = 'normal';
    delayMinutes = 0;
    offerCreated = false;
    offerAccepted = false;
    dropoffConfirmed = false;
    homeDeliverySelected = false;
    otpCode = '';

    nodeId = defaultNode.id;
    nodeName = defaultNode.name;
    nodeDistance = defaultNode.distance;
    walkingTime = defaultNode.walkingTime;
    nodeStatus = defaultNode.status;
    nodeCapacity = defaultNode.capacity;
    nodeLatitude = defaultNode.latitude;
    nodeLongitude = defaultNode.longitude;
    voucherAmount = defaultNode.voucherAmount;

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

  void _addLocalAiMessage({
    required String sender,
    required String type,
    required String message,
    bool shouldNotify = true,
  }) {
    aiMessages.add(
      AiChatMessage(
        sender: sender,
        type: type,
        message: message,
      ),
    );

    if (shouldNotify) {
      notifyListeners();
    }
  }
}

final demoDeliveryStore = DemoDeliveryStore();
