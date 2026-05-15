import 'package:flutter/material.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';
import 'live_route_preview.dart';

class DeliveryDetailsPage extends StatelessWidget {
  const DeliveryDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: const FlexiAppBar(title: 'Delivery Details'),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const LiveRoutePreview(
                  height: 190,
                  mode: 'driver',
                  forceDestinationToSelectedNode: true,
                  showOpenButton: true,
                ),

                const SizedBox(height: 14),

                FlexiCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusPill(
                        icon: store.shouldRouteToNode
                            ? Icons.alt_route
                            : Icons.local_shipping_outlined,
                        label: store.shouldRouteToNode
                            ? 'Rerouted to node'
                            : 'Home delivery route',
                        color: store.shouldRouteToNode
                            ? FlexiColors.primary
                            : FlexiColors.orange,
                        background: store.shouldRouteToNode
                            ? FlexiColors.lightGreen
                            : FlexiColors.orangeSoft,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Package ${store.orderId}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Receiver: ${store.receiverName}',
                        style: const TextStyle(
                          color: FlexiColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                FlexiCard(
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Original address',
                        value: store.receiverLocationText,
                      ),
                      _DetailRow(
                        label: 'Current destination',
                        value: store.shouldRouteToNode
                            ? store.nodeName
                            : 'Receiver address',
                      ),
                      _DetailRow(
                        label: 'Delay reason',
                        value: store.trafficStatus == 'heavy'
                            ? 'Heavy traffic near receiver address'
                            : 'Normal traffic',
                      ),
                      _DetailRow(
                        label: 'AI recommendation',
                        value: store.homeDeliverySelected
                            ? 'Receiver chose home delivery, no voucher issued'
                            : 'Drop at partner node within ${store.nodeDistance}',
                      ),
                      _DetailRow(
                        label: 'Voucher',
                        value: store.voucherEligible
                            ? store.formattedVoucher
                            : 'Not issued yet',
                      ),
                      _DetailRow(label: 'Pickup node', value: store.nodeName),
                      _DetailRow(label: 'Status', value: store.statusText),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                FlexiCard(
                  child: Column(
                    children: [
                      const TimelineStep(
                        title: 'Picked up',
                        subtitle: 'Courier received package',
                        active: true,
                      ),
                      const TimelineStep(
                        title: 'On the way',
                        subtitle: 'Moving toward receiver address',
                        active: true,
                      ),
                      TimelineStep(
                        title: store.trafficStatus == 'heavy'
                            ? 'Delayed by traffic'
                            : 'Traffic normal',
                        subtitle: store.trafficStatus == 'heavy'
                            ? 'AI detected operational drag'
                            : 'No reroute required yet',
                        active: true,
                      ),
                      TimelineStep(
                        title: store.homeDeliverySelected
                            ? 'Home delivery continued'
                            : 'Rerouted to node',
                        subtitle: store.homeDeliverySelected
                            ? 'Receiver rejected pickup node offer'
                            : 'Receiver accepted Flexi Pickup at ${store.nodeName}',
                        active:
                            store.homeDeliverySelected ||
                            store.shouldRouteToNode,
                      ),
                      TimelineStep(
                        title: store.statusText == 'completed'
                            ? 'Completed'
                            : store.statusText == 'delivered_to_node'
                            ? 'Delivered to node'
                            : 'Waiting for handover',
                        subtitle: store.statusText == 'completed'
                            ? 'Receiver picked up the package'
                            : store.statusText == 'delivered_to_node'
                            ? 'Waiting for receiver pickup QR'
                            : 'Driver still needs to show QR to mitra',
                        active:
                            store.statusText == 'delivered_to_node' ||
                            store.statusText == 'completed',
                        last: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: FlexiPrimaryButton(
                        label: 'Open Navigation',
                        icon: Icons.navigation,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/real-map',
                          arguments: {'mode': 'driver', 'usePhoneGps': true},
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FlexiOutlineButton(
                        label: 'Driver QR',
                        icon: Icons.qr_code_2,
                        onPressed: () =>
                            Navigator.pushNamed(context, '/driver-qr'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                FlexiOutlineButton(
                  label: 'Call Receiver',
                  icon: Icons.phone_outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: const TextStyle(color: FlexiColors.muted, fontSize: 12.5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
