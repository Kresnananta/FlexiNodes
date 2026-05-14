import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            Stack(
              children: [
                const MiniMap(
                  height: 260,
                  showNode: true,
                  showCustomer: true,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: StatusPill(
                    icon: Icons.warning_amber,
                    label: 'Heavy traffic',
                    color: FlexiColors.orange,
                    background: FlexiColors.orangeSoft,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            FlexiPrimaryButton(
              label: 'View Live Route Map',
              icon: Icons.map_outlined,
              onPressed: () => Navigator.pushNamed(context, '/rerouted-navigation'),
            ),

            const SizedBox(height: 14),

            FlexiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Order SD1440-Y',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      StatusPill(
                        label: 'Delayed',
                        color: FlexiColors.orange,
                        background: FlexiColors.orangeSoft,
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
                  const Text(
                    'Estimated delay: 20 minutes',
                    style: TextStyle(
                      color: FlexiColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

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
                        const Text(
                          'You can pick up your package at a nearby partner store and receive cashback.',
                          style: TextStyle(
                            color: FlexiColors.muted,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FlexiPrimaryButton(
                          label: 'See nearby pickup nodes',
                          icon: Icons.storefront,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/nearby-nodes'),
                          backgroundColor: FlexiColors.blue,
                        ),
                        const SizedBox(height: 8),
                        FlexiOutlineButton(
                          label: 'Stay with home delivery',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            const FlexiCard(
              child: Column(
                children: [
                  TimelineStep(
                    title: 'Package picked up',
                    subtitle: 'Warehouse Surabaya • 13:25',
                    active: true,
                  ),
                  TimelineStep(
                    title: 'On the way',
                    subtitle: 'Courier is moving to your location',
                    active: true,
                  ),
                  TimelineStep(
                    title: 'Delayed by traffic',
                    subtitle: 'Heavy traffic near your address',
                    active: true,
                  ),
                  TimelineStep(
                    title: 'Delivered',
                    subtitle: 'Waiting for final delivery',
                    active: false,
                    last: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}