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

  void _initAuth() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenToDelivery();
        _listenToChat();
        // Seed dummy data if needed
        _seedDummyData(user.uid);
      }
    });
  }

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

  List<AiChatMessage> aiMessages = [];

  final String _deliveryId = 'paket_001';
  String get _apiUrl => kIsWeb 
    ? 'http://127.0.0.1:5001/demo-no-project/us-central1/api' 
    : 'http://10.0.2.2:5001/demo-no-project/us-central1/api';

  void _listenToDelivery() {
    FirebaseFirestore.instance
        .collection('deliveries')
        .doc(_deliveryId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        delayMinutes = data['delayMinutes'] ?? 0;
        trafficStatus = delayMinutes > 15 ? 'heavy' : 'normal';
        final String docStatus = data['status'] ?? 'on_delivery';
        
        if (docStatus == 'on_delivery' && delayMinutes > 15) {
          status = DemoDeliveryStatus.offerPending;
          offerCreated = true;
        } else if (docStatus == 'rerouted_to_node') {
          status = DemoDeliveryStatus.reroutedToNode;
          offerAccepted = true;
          offerCreated = true;
          otpCode = data['otpCode']?.toString() ?? '';
        } else if (docStatus == 'delivered_to_node') {
          status = DemoDeliveryStatus.deliveredToNode;
          dropoffConfirmed = true;
        } else {
          status = DemoDeliveryStatus.onDelivery;
        }
        notifyListeners();
      }
    });
  }

  void _listenToChat() {
    FirebaseFirestore.instance
        .collection('AI_message')
        .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
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
        aiMessages = docs.map((doc) => AiChatMessage.fromJson(doc.data())).toList();
        if (aiMessages.isEmpty) {
          aiMessages.add(const AiChatMessage(
            sender: 'System',
            type: 'system',
            message: 'Delivery SD1440-Y started. Courier is heading to receiver address.',
          ));
        }
        notifyListeners();
      } catch (e) {
        print("Error processing chat snapshot: $e");
      }
    }, onError: (e) {
      print("Firestore chat listener error: $e");
    });
  }

  Future<void> _seedDummyData(String uid) async {
    // Try to create dummy delivery data
    try {
      final doc = FirebaseFirestore.instance.collection('deliveries').doc(_deliveryId);
      final snap = await doc.get();
      if (!snap.exists || snap.data()?['receiverId'] != uid) {
        await doc.set({
          'receiverId': uid,
          'driverId': 'driver_123',
          'status': 'on_delivery',
          'delayMinutes': 0,
        });
      }
    } catch (e) {
      print("Seed data skipped due to rules, which is fine if backend handles it: $e");
    }
  }

  String get formattedCashback => 'Rp${cashbackAmount.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      )}';

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
    }
  }

  bool get shouldRouteToNode {
    return status == DemoDeliveryStatus.reroutedToNode ||
        status == DemoDeliveryStatus.deliveredToNode;
  }

  bool get canShowOffer {
    return status == DemoDeliveryStatus.offerPending && !offerAccepted;
  }

  Future<void> simulateHeavyTraffic() async {
    try {
      await http.post(
        Uri.parse('$_apiUrl/simulate-traffic'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deliveryId': _deliveryId, 'delayMinutes': 20}),
      );
    } catch (e) {
      print('Error simulating traffic: $e');
    }
  }

  Future<void> acceptPickupOffer() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await http.post(
        Uri.parse('$_apiUrl/accept-offer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deliveryId': _deliveryId,
          'receiverId': uid,
          'nodeId': 'node_001',
          'nodeName': nodeName,
          'cashbackAmount': cashbackAmount,
        }),
      );
    } catch (e) {
      print('Error accepting offer: $e');
    }
  }

  void confirmDropoff() {
    FirebaseFirestore.instance.collection('deliveries').doc(_deliveryId).update({
      'status': 'delivered_to_node'
    });
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
      print('Error sending chat: $e');
    } finally {
      isChatLoading = false;
      notifyListeners();
    }
  }

  void resetDemo() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    FirebaseFirestore.instance.collection('deliveries').doc(_deliveryId).set({
      'receiverId': uid,
      'driverId': 'driver_123',
      'status': 'on_delivery',
      'delayMinutes': 0,
    });
    // Can't delete AI_message from client due to rules, but that's okay for demo.
  }
}

final demoDeliveryStore = DemoDeliveryStore();
