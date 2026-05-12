import 'package:flutter/foundation.dart';

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
}

class DemoDeliveryStore extends ChangeNotifier {
  DemoDeliveryStatus status = DemoDeliveryStatus.onDelivery;

  final String orderId = 'SD1440-Y';
  final String receiverName = 'Andika Sujanto';
  final String driverName = 'Rizky Fahmi';
  final String nodeName = 'Indomaret Ahmad Yani';
  final String nodeDistance = '75m';
  final String walkingTime = '2 min';
  final int cashbackAmount = 5000;
  final String otpCode = '8421';

  String trafficStatus = 'normal';
  int delayMinutes = 0;
  bool offerCreated = false;
  bool offerAccepted = false;
  bool dropoffConfirmed = false;

  final List<AiChatMessage> aiMessages = [
    const AiChatMessage(
      sender: 'System',
      type: 'system',
      message: 'Delivery SD1440-Y started. Courier is heading to receiver address.',
    ),
  ];

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

  void simulateHeavyTraffic() {
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
          message: 'Current delay estimate is 20 minutes. Cost of delay is higher than Rp5.000 cashback.',
        ),
        const AiChatMessage(
          sender: 'Flexi AI',
          type: 'select_node',
          message: 'Recommended node found: Indomaret Ahmad Yani, 75m from receiver, with 6 available slots.',
        ),
        const AiChatMessage(
          sender: 'Flexi AI',
          type: 'action',
          message: 'Pickup offer sent to receiver. Waiting for receiver approval.',
        ),
      ]);

    notifyListeners();
  }

  void acceptPickupOffer() {
    status = DemoDeliveryStatus.reroutedToNode;
    offerAccepted = true;
    offerCreated = true;
    dropoffConfirmed = false;

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

  void confirmDropoff() {
    status = DemoDeliveryStatus.deliveredToNode;
    dropoffConfirmed = true;

    aiMessages.addAll([
      const AiChatMessage(
        sender: 'Driver',
        type: 'driver',
        message: 'Package dropped at Indomaret Ahmad Yani.',
      ),
      const AiChatMessage(
        sender: 'System',
        type: 'system',
        message: 'OTP pickup code 8421 is active. Cashback Rp5.000 has been issued.',
      ),
    ]);

    notifyListeners();
  }

  void resetDemo() {
    status = DemoDeliveryStatus.onDelivery;
    trafficStatus = 'normal';
    delayMinutes = 0;
    offerCreated = false;
    offerAccepted = false;
    dropoffConfirmed = false;
    aiMessages
      ..clear()
      ..add(
        const AiChatMessage(
          sender: 'System',
          type: 'system',
          message: 'Delivery SD1440-Y started. Courier is heading to receiver address.',
        ),
      );

    notifyListeners();
  }
}

final demoDeliveryStore = DemoDeliveryStore();
