import 'package:flutter/material.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';
import 'live_route_preview.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: const FlexiAppBar(title: 'Tracking'),
          bottomNavigationBar: const CompactBottomNav(
            currentIndex: 2,
            routes: [
              '/receiver-home',
              '/orders',
              '/tracking',
              '/vouchers',
              '/profile',
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
              children: [
                const LiveRoutePreview(
                  height: 260,
                  mode: 'receiver',
                  showOpenButton: true,
                ),
                const SizedBox(height: 14),
                FlexiCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Order SD1440-Y',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          StatusPill(
                            label: store.homeDeliverySelected
                                ? 'Home Delivery'
                                : store.shouldRouteToNode
                                    ? 'Rerouted'
                                    : 'Delayed',
                            color: store.homeDeliverySelected
                                ? FlexiColors.blue
                                : store.shouldRouteToNode
                                    ? FlexiColors.primary
                                    : FlexiColors.orange,
                            background: store.homeDeliverySelected
                                ? FlexiColors.blueSoft
                                : store.shouldRouteToNode
                                    ? FlexiColors.lightGreen
                                    : FlexiColors.orangeSoft,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Courier: Rizky Fahmi',
                        style: TextStyle(
                          color: FlexiColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.homeDeliverySelected
                            ? 'You chose to keep door-to-door delivery. No voucher will be issued.'
                            : 'Estimated delay: 20 minutes',
                        style: const TextStyle(
                          color: FlexiColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (store.homeDeliverySelected)
                  FlexiCard(
                    color: FlexiColors.blueSoft,
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: FlexiColors.blue,
                          child: Icon(
                            Icons.home_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Door-to-door delivery selected\n',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      'Your courier will continue to your address. Since you did not choose a pickup node, no voucher will be issued.',
                                  style: TextStyle(
                                    color: FlexiColors.muted,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  FlexiCard(
                    color: FlexiColors.blueSoft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          backgroundColor: FlexiColors.blue,
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AI detected heavy traffic',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'You can pick up your package at a nearby partner store and receive a ${store.formattedVoucher} voucher.',
                                style: const TextStyle(
                                  color: FlexiColors.muted,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FlexiPrimaryButton(
                                label: 'See nearby pickup nodes',
                                icon: Icons.storefront,
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/nearby-nodes',
                                ),
                                backgroundColor: FlexiColors.blue,
                              ),
                              const SizedBox(height: 8),
                              FlexiOutlineButton(
                                label: 'Stay with home delivery',
                                icon: Icons.home_outlined,
                                onPressed: () async {
                                  await store.keepHomeDelivery();

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Home delivery selected. No voucher will be issued.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),
                FlexiCard(
                  child: Column(
                    children: [
                      const TimelineStep(
                        title: 'Package picked up',
                        subtitle: 'Warehouse Surabaya • 13:25',
                        active: true,
                      ),
                      const TimelineStep(
                        title: 'On the way',
                        subtitle: 'Courier is moving to your location',
                        active: true,
                      ),
                      TimelineStep(
                        title: store.homeDeliverySelected
                            ? 'Door-to-door delivery continued'
                            : 'Delayed by traffic',
                        subtitle: store.homeDeliverySelected
                            ? 'Receiver chose to keep home delivery'
                            : 'Heavy traffic near your address',
                        active: true,
                      ),
                      TimelineStep(
                        title: store.shouldRouteToNode
                            ? 'Rerouted to pickup node'
                            : 'Delivered',
                        subtitle: store.shouldRouteToNode
                            ? 'Package is heading to ${store.nodeName}'
                            : 'Waiting for final delivery',
                        active: store.shouldRouteToNode,
                        last: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
