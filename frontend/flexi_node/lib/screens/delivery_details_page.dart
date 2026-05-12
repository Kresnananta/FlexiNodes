import 'package:flutter/material.dart';
import 'flexi_ui.dart';

class DeliveryDetailsPage extends StatelessWidget {
  const DeliveryDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlexiColors.bg,
      appBar: const FlexiAppBar(title: 'Delivery Details'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const MiniMap(height: 180, showNode: true, showCustomer: true, routeToNode: true),
            const SizedBox(height: 14),
            FlexiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  StatusPill(
                    icon: Icons.alt_route,
                    label: 'Rerouted to node',
                    color: FlexiColors.primary,
                    background: FlexiColors.lightGreen,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Package SD1440-Y',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Receiver: Andika Sujanto',
                    style: TextStyle(color: FlexiColors.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const FlexiCard(
              child: Column(
                children: [
                  _DetailRow(label: 'Original address', value: 'Jl. Sudirman Kav 52-53, Senayan'),
                  _DetailRow(label: 'Updated destination', value: 'Indomaret Ahmad Yani'),
                  _DetailRow(label: 'Delay reason', value: 'Heavy traffic near receiver address'),
                  _DetailRow(label: 'AI recommendation', value: 'Drop at partner node within 75m'),
                  _DetailRow(label: 'OTP code', value: '8421'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const FlexiCard(
              child: Column(
                children: [
                  TimelineStep(title: 'Picked up', subtitle: 'Courier received package', active: true),
                  TimelineStep(title: 'On the way', subtitle: 'Moving toward receiver address', active: true),
                  TimelineStep(title: 'Delayed by traffic', subtitle: 'AI detected operational drag', active: true),
                  TimelineStep(title: 'Rerouted to node', subtitle: 'Receiver accepted Flexi Pickup', active: true),
                  TimelineStep(title: 'Delivered to node', subtitle: 'Waiting for courier confirmation', active: false, last: true),
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
                    onPressed: () => Navigator.pushNamed(context, '/rerouted-navigation'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FlexiOutlineButton(
                    label: 'Call Receiver',
                    icon: Icons.phone_outlined,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

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
            child: Text(label, style: const TextStyle(color: FlexiColors.muted, fontSize: 12.5)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
