import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../services/geocoding_service.dart';

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

class DemoOrderSummary {
  const DemoOrderSummary({
    required this.id,
    required this.status,
    required this.subtitle,
    required this.statusText,
    required this.delayMinutes,
    required this.isActive,
    this.receiverName = 'Customer',
    this.selectedNodeId,
  });

  final String id;
  final DemoDeliveryStatus status;
  final String subtitle;
  final String statusText;
  final int delayMinutes;
  final bool isActive;
  final String receiverName;
  final String? selectedNodeId;
}

class DemoDeliveryStore extends ChangeNotifier {
  DemoDeliveryStore() {
    pickupNodes = List<DemoPickupNode>.of(fallbackNodes);
    _initAuth();
  }

  final String _deliveryId = 'paket_001';

  static const List<DemoPickupNode> fallbackNodes = [
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

  // Backward-compatible fallback for older screens. New code should use
  // [pickupNodes] so it reflects Firestore.
  static const List<DemoPickupNode> availableNodes = fallbackNodes;

  List<DemoPickupNode> pickupNodes = const [];

  DemoDeliveryStatus status = DemoDeliveryStatus.onDelivery;

  String orderId = 'paket_001';
  String receiverName = 'Budiman';
  String receiverEmail = 'andika@example.com';
  String receiverAddress = '';
  String driverName = 'Rizky Fahmi';

  String nodeId = fallbackNodes.first.id;
  String nodeName = fallbackNodes.first.name;
  String nodeDistance = fallbackNodes.first.distance;
  String walkingTime = fallbackNodes.first.walkingTime;
  String nodeStatus = fallbackNodes.first.status;
  String nodeCapacity = fallbackNodes.first.capacity;
  double nodeLatitude = fallbackNodes.first.latitude;
  double nodeLongitude = fallbackNodes.first.longitude;

  double receiverLatitude = -7.2815;
  double receiverLongitude = 112.7525;
  double driverLatitude = -7.28;
  double driverLongitude = 112.75;

  int voucherAmount = fallbackNodes.first.voucherAmount;
  String? voucherCode;
  String? offerReason;
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

  List<DemoOrderSummary> orders = const [];

  String get deliveryId => _deliveryId;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _deliverySub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _nodesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _offersSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatSub;

  List<Map<String, dynamic>> _nodeDocs = const [];
  String? _lastGeocodedLatLng;

  static const String _googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );
  static const String _googleRoutesApiKey = String.fromEnvironment(
    'GOOGLE_ROUTES_API_KEY',
  );
  static const String _webIndexMapsApiKey =
      'AIzaSyCBA6L9i7NiCVCcEECuwYKd8ej6xQni8DY';

  String get _geocodingApiKey {
    if (_googleMapsApiKey.isNotEmpty) return _googleMapsApiKey;
    if (_googleRoutesApiKey.isNotEmpty) return _googleRoutesApiKey;
    return _webIndexMapsApiKey;
  }

  // Online Cloud Function / Cloud Run API
  String get _apiUrl {
    return 'https://api-mw5zqvl2rq-uc.a.run.app';
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
    final nodes = pickupNodes.isEmpty ? fallbackNodes : pickupNodes;

    return nodes.firstWhere(
      (node) => node.id == nodeId,
      orElse: () => nodes.first,
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
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenToNodes();
        _listenToDelivery();
        _listenToOrders();
        _listenToOffers();
        _listenToChat();
      } else {
        _deliverySub?.cancel();
        _ordersSub?.cancel();
        _nodesSub?.cancel();
        _offersSub?.cancel();
        _chatSub?.cancel();
      }
    });
  }

  void _listenToDelivery() {
    _deliverySub?.cancel();
    _deliverySub = FirebaseFirestore.instance
        .collection('deliveries')
        .doc(_deliveryId)
        .snapshots()
        .listen(
          (doc) {
            if (!doc.exists) return;

            final data = doc.data()!;

            orderId = data['orderId']?.toString() ?? doc.id;
            delayMinutes = _readInt(
              data['delayMinutes'] ?? data['current_traffic_delay'],
            );
            trafficStatus = delayMinutes > 15 ? 'heavy' : 'normal';

            final String rId = data['receiverId'] as String? ?? '';
            final String dId = data['driverId'] as String? ?? '';

            if (rId.isNotEmpty) _fetchReceiverInfo(rId);
            if (dId.isNotEmpty) _fetchDriverInfo(dId);

            final targetLocation = data['targetLocation'];
            receiverLatitude =
                _readGeoLatitude(targetLocation) ??
                (data['target_latitude'] as num?)?.toDouble() ??
                receiverLatitude;
            receiverLongitude =
                _readGeoLongitude(targetLocation) ??
                (data['target_longitude'] as num?)?.toDouble() ??
                receiverLongitude;
            receiverAddress =
                data['targetAddress']?.toString() ??
                data['receiverAddress']?.toString() ??
                receiverAddress;
            _resolveReceiverAddress();

            final aiOffer = data['ai_offer'];
            if (aiOffer is Map) {
              nodeId = aiOffer['node_id']?.toString() ?? nodeId;
              voucherAmount = _readInt(
                aiOffer['cashback_amount'],
                fallback: voucherAmount,
              );
              offerReason = aiOffer['reason']?.toString() ?? offerReason;
            }

            nodeId = data['selectedNodeId'] as String? ?? nodeId;
            nodeName = data['selectedNodeName'] as String? ?? nodeName;
            nodeLatitude =
                (data['selectedNodeLat'] as num?)?.toDouble() ?? nodeLatitude;
            nodeLongitude =
                (data['selectedNodeLng'] as num?)?.toDouble() ?? nodeLongitude;
            _rebuildPickupNodes();
            _applySelectedNodeFromList(keepOfferVoucher: offerCreated);

            otpCode = data['otpCode']?.toString() ?? otpCode;
            homeDeliverySelected =
                data['homeDeliverySelected'] as bool? ?? homeDeliverySelected;

            final String docStatus = data['status'] as String? ?? 'on_delivery';

            if (docStatus == 'on_delivery' &&
                delayMinutes > 15 &&
                !homeDeliverySelected) {
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
          },
          onError: (e) {
            debugPrint('Firestore delivery listener error: $e');
          },
        );
  }

  void _listenToOrders() {
    _ordersSub?.cancel();
    _ordersSub = FirebaseFirestore.instance
        .collection('deliveries')
        .snapshots()
        .listen(
          (snapshot) {
            final summaries =
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  final rawStatus = data['status']?.toString() ?? 'on_delivery';
                  final mappedStatus = _statusFromText(rawStatus);
                  final delay = _readInt(
                    data['delayMinutes'] ?? data['current_traffic_delay'],
                  );
                  return DemoOrderSummary(
                    id: data['orderId']?.toString() ?? doc.id,
                    status: mappedStatus,
                    subtitle: _orderSubtitle(mappedStatus, delay),
                    statusText: _orderStatusLabel(mappedStatus, delay),
                    delayMinutes: delay,
                    isActive: doc.id == _deliveryId,
                    receiverName:
                        data['receiverName']?.toString() ??
                        data['customerName']?.toString() ??
                        (doc.id == _deliveryId ? receiverName : 'Customer'),
                    selectedNodeId: data['selectedNodeId']?.toString(),
                  );
                }).toList()..sort((a, b) {
                  if (a.isActive && !b.isActive) return -1;
                  if (!a.isActive && b.isActive) return 1;
                  return a.id.compareTo(b.id);
                });

            orders = summaries;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Firestore orders listener error: $e');
          },
        );
  }

  void _listenToNodes() {
    _nodesSub?.cancel();
    _nodesSub = FirebaseFirestore.instance
        .collection('nodes')
        .snapshots()
        .listen(
          (snapshot) {
            _nodeDocs = snapshot.docs
                .map((doc) => {'id': doc.id, 'data': doc.data()})
                .toList();

            _rebuildPickupNodes();
            _applySelectedNodeFromList();
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Firestore nodes listener error: $e');
          },
        );
  }

  void _listenToOffers() {
    _offersSub?.cancel();
    _offersSub = FirebaseFirestore.instance
        .collection('offers')
        .where('deliveryId', isEqualTo: _deliveryId)
        .snapshots()
        .listen(
          (snapshot) {
            final docs = snapshot.docs.toList()
              ..sort((a, b) {
                final aTime = _readDateTime(a.data()['offeredAt']);
                final bTime = _readDateTime(b.data()['offeredAt']);
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime);
              });

            if (docs.isEmpty) return;

            final acceptedDocs = docs
                .where((doc) => doc.data()['status'] == 'accepted')
                .toList();
            final pendingDocs = docs
                .where((doc) => doc.data()['status'] == 'pending')
                .toList();
            final preferred = acceptedDocs.isNotEmpty
                ? acceptedDocs.first
                : pendingDocs.isNotEmpty
                ? pendingDocs.first
                : docs.first;
            final data = preferred.data();

            offerCreated = true;
            offerAccepted = data['status'] == 'accepted' || offerAccepted;
            nodeId = data['nodeId']?.toString() ?? nodeId;
            nodeName = data['nodeName']?.toString() ?? nodeName;
            nodeDistance = _formatMeters(_readInt(data['distanceMeters']));
            voucherAmount = _voucherAmountFromOffer(
              data,
              fallback: voucherAmount,
            );
            voucherCode = data['voucherCode']?.toString() ?? voucherCode;
            offerReason = data['reason']?.toString() ?? offerReason;

            _rebuildPickupNodes();
            _applySelectedNodeFromList(keepOfferVoucher: true);

            if (status == DemoDeliveryStatus.onDelivery &&
                data['status'] == 'pending' &&
                !homeDeliverySelected) {
              status = DemoDeliveryStatus.offerPending;
            }

            notifyListeners();
          },
          onError: (e) {
            debugPrint('Firestore offers listener error: $e');
          },
        );
  }

  void _listenToChat() {
    _chatSub?.cancel();
    _chatSub = FirebaseFirestore.instance
        .collection('AI_message')
        .where('deliveryId', isEqualTo: _deliveryId)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final docs = snapshot.docs.toList();

              docs.sort((a, b) {
                final tA = _readDateTime(a.data()['createdAt']);
                final tB = _readDateTime(b.data()['createdAt']);

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
                  AiChatMessage(
                    sender: 'System',
                    type: 'system',
                    message:
                        'Delivery $orderId started. Courier is heading to receiver address.',
                  ),
                );
              }

              notifyListeners();
            } catch (e) {
              debugPrint('Error processing chat snapshot: $e');
            }
          },
          onError: (e) {
            debugPrint('Firestore chat listener error: $e');
          },
        );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _deliverySub?.cancel();
    _ordersSub?.cancel();
    _nodesSub?.cancel();
    _offersSub?.cancel();
    _chatSub?.cancel();
    super.dispose();
  }

  String get safeOtpCode => otpCode.isNotEmpty ? otpCode : '8421';

  String get receiverFirstName {
    final trimmed = receiverName.trim();
    if (trimmed.isEmpty) return 'Customer';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  String get driverFirstName {
    final trimmed = driverName.trim();
    if (trimmed.isEmpty) return 'Driver';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  String get formattedVoucher {
    return 'Rp${voucherAmount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  // Backward compatibility for old pages still referencing formattedCashback.
  String get formattedCashback => formattedVoucher;

  bool get voucherEligible {
    return offerAccepted && !homeDeliverySelected;
  }

  String get voucherCodeText {
    return voucherCode ?? 'FLEXI${voucherAmount.toString()}';
  }

  String get receiverLocationText {
    if (receiverAddress.trim().isNotEmpty) return receiverAddress;
    return '${receiverLatitude.toStringAsFixed(4)}, ${receiverLongitude.toStringAsFixed(4)}';
  }

  String get activeDestinationName {
    if (shouldRouteToNode) return nodeName;
    return 'Receiver address';
  }

  String get activeDeliveryStatusLabel {
    if (homeDeliverySelected) return 'Home Delivery';
    if (status == DemoDeliveryStatus.completed) return 'Completed';
    if (status == DemoDeliveryStatus.deliveredToNode) return 'Ready for Pickup';
    if (shouldRouteToNode) return 'Rerouted';
    if (canShowOffer || delayMinutes > 15) return 'Delayed';
    return 'On Delivery';
  }

  String get activeDeliverySubtitle {
    if (homeDeliverySelected) {
      return 'Door-to-door delivery continues with $driverName.';
    }
    if (status == DemoDeliveryStatus.completed) {
      return 'Package pickup completed at $nodeName.';
    }
    if (status == DemoDeliveryStatus.deliveredToNode) {
      return 'Package is waiting at $nodeName.';
    }
    if (shouldRouteToNode) {
      return 'Courier is heading to $nodeName.';
    }
    if (delayMinutes > 0) {
      return 'Estimated arrival delayed by ~$delayMinutes mins.';
    }
    return 'Courier $driverName is moving to your address.';
  }

  String get estimatedArrivalText {
    if (status == DemoDeliveryStatus.completed) return 'Done';
    if (status == DemoDeliveryStatus.deliveredToNode) return 'Ready';
    if (delayMinutes > 0) return '+$delayMinutes min';
    return 'On time';
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
        body: jsonEncode({'deliveryId': _deliveryId, 'delayMinutes': 20}),
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
      message:
          'Receiver chose to keep door-to-door delivery. No voucher will be issued.',
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

  Future<void> markReceivedByMitra({required String source}) async {
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

  Future<void> markCompletedByReceiver({required String source}) async {
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
    final scannedOrderId = decoded['orderId']?.toString();

    if (type == null) {
      throw Exception('QR type is missing.');
    }

    if (expectedType != null && expectedType != type) {
      throw Exception('Wrong QR type. Expected $expectedType but got $type.');
    }

    if (scannedDeliveryId != null && scannedDeliveryId != _deliveryId) {
      throw Exception('This QR belongs to a different package.');
    }

    if (scannedOrderId != null && scannedOrderId != orderId) {
      throw Exception(
        'This QR belongs to package $scannedOrderId, not $orderId.',
      );
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
      final defaultNode =
          (pickupNodes.isEmpty ? fallbackNodes : pickupNodes).first;

      await FirebaseFirestore.instance
          .collection('deliveries')
          .doc(_deliveryId)
          .set({
            'receiverId': uid,
            'driverId': 'driver_123',
            'status': 'on_delivery',
            'delayMinutes': 0,
            'targetLocation': const GeoPoint(-7.2815, 112.7525),
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
          message:
              'Pickup offer sent to receiver. Waiting for receiver approval.',
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
        message:
            'Driver route has been updated. Pickup voucher $formattedVoucher will be issued.',
      ),
    ]);

    notifyListeners();
  }

  void _localReset() {
    final defaultNode =
        (pickupNodes.isEmpty ? fallbackNodes : pickupNodes).first;

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
        AiChatMessage(
          sender: 'System',
          type: 'system',
          message:
              'Delivery $orderId started. Courier is heading to receiver address.',
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
    aiMessages.add(AiChatMessage(sender: sender, type: type, message: message));

    if (shouldNotify) {
      notifyListeners();
    }
  }

  Future<void> _fetchReceiverInfo(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        receiverName = data?['name'] ?? receiverName;
        receiverEmail = data?['email'] ?? receiverEmail;
        receiverAddress =
            data?['homeAddress']?.toString() ??
            data?['address']?.toString() ??
            receiverAddress;
        final homeLocation = data?['homeLocation'];
        receiverLatitude = _readGeoLatitude(homeLocation) ?? receiverLatitude;
        receiverLongitude =
            _readGeoLongitude(homeLocation) ?? receiverLongitude;
        _resolveReceiverAddress();
        _rebuildPickupNodes();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching receiver info: $e');
    }
  }

  Future<void> _fetchDriverInfo(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        driverName = data?['name'] ?? driverName;
        final currentLocation = data?['currentLocation'];
        driverLatitude = _readGeoLatitude(currentLocation) ?? driverLatitude;
        driverLongitude = _readGeoLongitude(currentLocation) ?? driverLongitude;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching driver info: $e');
    }
  }

  Future<void> _resolveReceiverAddress() async {
    final key = _geocodingApiKey;
    final latLngKey =
        '${receiverLatitude.toStringAsFixed(6)},${receiverLongitude.toStringAsFixed(6)}';

    if (key.isEmpty || _lastGeocodedLatLng == latLngKey) return;
    if (receiverAddress.trim().isNotEmpty &&
        !RegExp(r'^-?\d+\.\d+').hasMatch(receiverAddress.trim())) {
      _lastGeocodedLatLng = latLngKey;
      return;
    }

    _lastGeocodedLatLng = latLngKey;

    try {
      final address = await GeocodingService(apiKey: key).reverseGeocode(
        latitude: receiverLatitude,
        longitude: receiverLongitude,
      );
      if (address == null || address.trim().isEmpty) return;

      receiverAddress = address;
      notifyListeners();
    } catch (e) {
      debugPrint('Reverse geocoding skipped: $e');
    }
  }

  void _rebuildPickupNodes() {
    if (_nodeDocs.isEmpty) {
      pickupNodes = List<DemoPickupNode>.of(fallbackNodes);
      return;
    }

    pickupNodes =
        _nodeDocs.map((entry) {
          final data = entry['data'] as Map<String, dynamic>;
          final id = entry['id'] as String;
          final location = data['location'];
          final latitude =
              _readGeoLatitude(location) ?? fallbackNodes.first.latitude;
          final longitude =
              _readGeoLongitude(location) ?? fallbackNodes.first.longitude;
          final meters = _distanceMeters(
            receiverLatitude,
            receiverLongitude,
            latitude,
            longitude,
          );
          final capacity = _readInt(data['capacity']);
          final available = data['available'] as bool? ?? capacity > 0;
          final status = !available
              ? 'Unavailable'
              : capacity <= 1
              ? 'Almost full'
              : 'Available';
          final voucher = id == nodeId
              ? voucherAmount
              : _defaultVoucherAmount(capacity);

          return DemoPickupNode(
            id: id,
            name: data['name']?.toString() ?? id,
            distance: _formatMeters(meters),
            walkingTime: _walkingTime(meters),
            status: status,
            capacity: '$capacity slots',
            voucherText: _formatRupiah(voucher),
            voucherAmount: voucher,
            latitude: latitude,
            longitude: longitude,
            recommended: id == nodeId || pickupNodes.isEmpty,
          );
        }).toList()..sort((a, b) {
          final aMeters = _parseMeters(a.distance);
          final bMeters = _parseMeters(b.distance);
          return aMeters.compareTo(bMeters);
        });
  }

  void _applySelectedNodeFromList({bool keepOfferVoucher = false}) {
    final nodes = pickupNodes.isEmpty ? fallbackNodes : pickupNodes;
    final matchedNode = nodes.where((node) => node.id == nodeId).toList();

    if (matchedNode.isEmpty) return;

    final node = matchedNode.first;
    nodeName = node.name;
    nodeDistance = node.distance;
    walkingTime = node.walkingTime;
    nodeStatus = node.status;
    nodeCapacity = node.capacity;
    nodeLatitude = node.latitude;
    nodeLongitude = node.longitude;
    if (!keepOfferVoucher) {
      voucherAmount = node.voucherAmount;
    }
  }

  static double? _readGeoLatitude(dynamic value) {
    if (value is GeoPoint) return value.latitude;
    if (value is Map) {
      final raw = value['latitude'];
      if (raw is num) return raw.toDouble();
    }
    return null;
  }

  static double? _readGeoLongitude(dynamic value) {
    if (value is GeoPoint) return value.longitude;
    if (value is Map) {
      final raw = value['longitude'];
      if (raw is num) return raw.toDouble();
    }
    return null;
  }

  static int _readInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is Map) {
      final seconds = value['seconds'] ?? value['_seconds'];
      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch(seconds.round() * 1000);
      }
      final iso = value['iso'];
      if (iso is String) return DateTime.tryParse(iso);
    }
    return null;
  }

  static DemoDeliveryStatus _statusFromText(String value) {
    switch (value) {
      case 'traffic_detected':
        return DemoDeliveryStatus.trafficDetected;
      case 'offer_pending':
        return DemoDeliveryStatus.offerPending;
      case 'rerouted_to_node':
        return DemoDeliveryStatus.reroutedToNode;
      case 'delivered_to_node':
        return DemoDeliveryStatus.deliveredToNode;
      case 'completed':
        return DemoDeliveryStatus.completed;
      case 'on_delivery':
      default:
        return DemoDeliveryStatus.onDelivery;
    }
  }

  static String _orderStatusLabel(DemoDeliveryStatus status, int delay) {
    switch (status) {
      case DemoDeliveryStatus.completed:
        return 'Completed';
      case DemoDeliveryStatus.deliveredToNode:
        return 'Ready for Pickup';
      case DemoDeliveryStatus.reroutedToNode:
        return 'Rerouted';
      case DemoDeliveryStatus.offerPending:
        return 'Offer Pending';
      case DemoDeliveryStatus.trafficDetected:
        return 'Traffic Delay';
      case DemoDeliveryStatus.onDelivery:
        return delay > 15 ? 'Delayed' : 'Courier on the way';
    }
  }

  static String _orderSubtitle(DemoDeliveryStatus status, int delay) {
    switch (status) {
      case DemoDeliveryStatus.completed:
        return 'Package completed';
      case DemoDeliveryStatus.deliveredToNode:
        return 'Waiting for receiver pickup';
      case DemoDeliveryStatus.reroutedToNode:
        return 'Courier heading to partner node';
      case DemoDeliveryStatus.offerPending:
        return 'Flexi Pickup offer available';
      case DemoDeliveryStatus.trafficDetected:
        return 'AI detected heavy traffic';
      case DemoDeliveryStatus.onDelivery:
        return delay > 15
            ? 'Delayed by traffic'
            : 'Moving toward receiver address';
    }
  }

  static int _voucherAmountFromOffer(
    Map<String, dynamic> data, {
    required int fallback,
  }) {
    final explicitAmount = _readInt(
      data['voucherAmount'] ??
          data['cashbackAmount'] ??
          data['cashback_amount'],
      fallback: -1,
    );
    if (explicitAmount > 0) return explicitAmount;

    switch (data['voucherType']?.toString()) {
      case 'discount_10':
        return 10000;
      case 'free_shipping':
        return 7000;
      case 'discount_5':
        return 5000;
      default:
        return fallback > 0 ? fallback : 5000;
    }
  }

  static int _defaultVoucherAmount(int capacity) {
    if (capacity <= 1) return 6000;
    if (capacity <= 3) return 5000;
    return 4000;
  }

  static int _distanceMeters(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    const earthRadiusMeters = 6371000;
    final dLat = _degreesToRadians(endLat - startLat);
    final dLng = _degreesToRadians(endLng - startLng);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(startLat)) *
            math.cos(_degreesToRadians(endLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (earthRadiusMeters * c).round();
  }

  static double _degreesToRadians(double value) => value * math.pi / 180;

  static String _formatMeters(int meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
    return '${meters}m';
  }

  static int _parseMeters(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.endsWith('km')) {
      final km = double.tryParse(normalized.replaceAll('km', '')) ?? 0;
      return (km * 1000).round();
    }
    return int.tryParse(normalized.replaceAll('m', '')) ?? 0;
  }

  static String _walkingTime(int meters) {
    final minutes = math.max(1, (meters / 80).ceil());
    return '$minutes min';
  }

  static String _formatRupiah(int amount) {
    return 'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }
}

final demoDeliveryStore = DemoDeliveryStore();
