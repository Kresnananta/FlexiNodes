import 'package:flutter/material.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';

class FlexiAiChatPage extends StatefulWidget {
  const FlexiAiChatPage({super.key});

  @override
  State<FlexiAiChatPage> createState() => _FlexiAiChatPageState();
}

class _FlexiAiChatPageState extends State<FlexiAiChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;

        // Auto-scroll trick whenever state changes (like new message)
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: FlexiAppBar(
            title: 'Flexi AI Agent',
            actions: [
              IconButton(
                tooltip: 'Reset demo',
                onPressed: store.resetDemo,
                icon: const Icon(Icons.refresh, color: FlexiColors.primary),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                _DemoStatusCard(store: store),
                _ActionPanel(store: store), // Moved up here as per Option A
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: store.aiMessages.length,
                    itemBuilder: (context, index) {
                      final message = store.aiMessages[index];
                      return _ChatBubble(message: message);
                    },
                  ),
                ),
                _ChatInputPanel(store: store, controller: _textController),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DemoStatusCard extends StatelessWidget {
  const _DemoStatusCard({required this.store});

  final DemoDeliveryStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlexiColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FlexiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Demo State',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                label: store.orderId,
                icon: Icons.inventory_2_outlined,
              ),
              StatusPill(
                label: store.statusText,
                icon: Icons.sync_alt,
                color: store.shouldRouteToNode
                    ? FlexiColors.primary
                    : FlexiColors.orange,
                background: store.shouldRouteToNode
                    ? FlexiColors.lightGreen
                    : FlexiColors.orangeSoft,
              ),
              StatusPill(
                label: store.trafficStatus,
                icon: Icons.traffic_outlined,
                color: store.trafficStatus == 'heavy'
                    ? FlexiColors.orange
                    : FlexiColors.primary,
                background: store.trafficStatus == 'heavy'
                    ? FlexiColors.orangeSoft
                    : FlexiColors.lightGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final AiChatMessage message;

  bool get isAi => message.sender == 'Flexi AI';
  bool get isUser => message.type == 'user';
  bool get isReceiver => message.sender == 'Receiver' || isUser;
  bool get isDriver => message.sender == 'Driver';

  @override
  Widget build(BuildContext context) {
    final alignment = isReceiver || isDriver
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final bg = isAi
        ? FlexiColors.blueSoft
        : isReceiver
        ? FlexiColors.lightGreen
        : isDriver
        ? FlexiColors.orangeSoft
        : FlexiColors.surface;
    final iconColor = isAi
        ? FlexiColors.blue
        : isReceiver
        ? FlexiColors.primary
        : isDriver
        ? FlexiColors.orange
        : FlexiColors.muted;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FlexiColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: iconColor,
              child: Icon(
                _iconForType(message.type),
                size: 15,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.sender,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.message,
                    style: const TextStyle(
                      color: FlexiColors.text,
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'observe':
        return Icons.visibility_outlined;
      case 'reason':
        return Icons.psychology_outlined;
      case 'select_node':
        return Icons.storefront_outlined;
      case 'action':
        return Icons.bolt_outlined;
      case 'receiver':
        return Icons.person_outline;
      case 'driver':
        return Icons.local_shipping_outlined;
      case 'user':
        return Icons.person;
      default:
        return Icons.info_outline;
    }
  }
}

class _ChatInputPanel extends StatelessWidget {
  const _ChatInputPanel({required this.store, required this.controller});

  final DemoDeliveryStore store;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: FlexiColors.surface,
        border: Border(top: BorderSide(color: FlexiColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !store.isChatLoading,
              decoration: InputDecoration(
                hintText: 'Tulis pesan untuk AI...',
                hintStyle: const TextStyle(
                  color: FlexiColors.muted,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: FlexiColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: FlexiColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: FlexiColors.primary),
                ),
                filled: true,
                fillColor: FlexiColors.bg,
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  store.sendChatMessage(val);
                  controller.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          store.isChatLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              : CircleAvatar(
                  backgroundColor: FlexiColors.primary,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        store.sendChatMessage(controller.text);
                        controller.clear();
                      }
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.store});

  final DemoDeliveryStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: FlexiColors.bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!store.offerCreated)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FlexiPrimaryButton(
                        label: store.isCheckingRealtimeTraffic
                            ? 'Checking...'
                            : 'Realtime Traffic',
                        icon: Icons.online_prediction,
                        onPressed: () => store.checkRealtimeTraffic(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FlexiPrimaryButton(
                        label: 'Demo Traffic',
                        icon: Icons.traffic_outlined,
                        onPressed: store.simulateHeavyTraffic,
                        backgroundColor: FlexiColors.orange,
                      ),
                    ),
                  ],
                ),
                if (store.realtimeTrafficError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    store.realtimeTrafficError!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: FlexiColors.red,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            )
          else if (store.canShowOffer)
            FlexiPrimaryButton(
              label: 'Open Receiver Offer',
              icon: Icons.notifications_active_outlined,
              onPressed: () => Navigator.pushNamed(context, '/flexi-offer'),
            )
          else if (store.shouldRouteToNode && !store.dropoffConfirmed)
            FlexiPrimaryButton(
              label: 'Open Driver Reroute',
              icon: Icons.alt_route,
              onPressed: () =>
                  Navigator.pushNamed(context, '/rerouted-navigation'),
            )
          else
            FlexiPrimaryButton(
              label: 'View Confirmation',
              icon: Icons.check_circle_outline,
              onPressed: () => Navigator.pushNamed(context, '/confirmation'),
            ),
        ],
      ),
    );
  }
}
