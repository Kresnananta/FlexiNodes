import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/demo_delivery_store.dart';
import 'flexi_ui.dart';

class RealDeliveryMapPage extends StatefulWidget {
  const RealDeliveryMapPage({super.key});

  @override
  State<RealDeliveryMapPage> createState() => _RealDeliveryMapPageState();
}

class _RealDeliveryMapPageState extends State<RealDeliveryMapPage> {
  GoogleMapController? mapController;
  bool usePhoneGps = false;
  bool loadingGps = false;
  String? gpsError;

  static const LatLng hardcodedDriver = LatLng(-7.2756, 112.7420);
  static const LatLng receiverLocation = LatLng(-7.2818, 112.7580);
  static const LatLng nodeLocation = LatLng(-7.2812, 112.7521);

  LatLng driverLocation = hardcodedDriver;

  LatLng get destination =>
      demoDeliveryStore.shouldRouteToNode ? nodeLocation : receiverLocation;

  @override
  void initState() {
    super.initState();
    demoDeliveryStore.addListener(_onDemoChanged);
  }

  @override
  void dispose() {
    demoDeliveryStore.removeListener(_onDemoChanged);
    mapController?.dispose();
    super.dispose();
  }

  void _onDemoChanged() {
    if (!mounted) return;
    setState(() {});
    _fitCameraToRoute();
  }

  Future<void> _fitCameraToRoute() async {
    final controller = mapController;
    if (controller == null) return;

    final points = [driverLocation, destination, nodeLocation, receiverLocation];

    final southwest = LatLng(
      points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
      points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
    );

    final northeast = LatLng(
      points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
      points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
    );

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southwest, northeast: northeast),
        70,
      ),
    );
  }

  Future<void> _toggleGps() async {
    if (usePhoneGps) {
      setState(() {
        usePhoneGps = false;
        driverLocation = hardcodedDriver;
        gpsError = null;
      });
      _fitCameraToRoute();
      return;
    }

    setState(() {
      loadingGps = true;
      gpsError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('GPS/location service is disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied forever. Enable it in app settings.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        usePhoneGps = true;
        driverLocation = LatLng(position.latitude, position.longitude);
      });

      await _fitCameraToRoute();
    } catch (e) {
      setState(() {
        gpsError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => loadingGps = false);
    }
  }

  Set<Marker> _markers() {
    return {
      Marker(
        markerId: const MarkerId('driver'),
        position: driverLocation,
        infoWindow: InfoWindow(
          title: usePhoneGps ? 'Phone GPS / Driver' : 'Driver: Rizky Fahmi',
          snippet: usePhoneGps ? 'Current phone location' : 'Hardcoded demo location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId('receiver'),
        position: receiverLocation,
        infoWindow: const InfoWindow(
          title: 'Receiver: Andika',
          snippet: 'Original home delivery address',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
      Marker(
        markerId: const MarkerId('node'),
        position: nodeLocation,
        infoWindow: const InfoWindow(
          title: 'Indomaret Ahmad Yani',
          snippet: 'Flexi Pickup Node • 75m',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };
  }

  Set<Polyline> _polylines() {
    final routeColor =
        demoDeliveryStore.shouldRouteToNode ? FlexiColors.primary : FlexiColors.orange;

    return {
      Polyline(
        polylineId: const PolylineId('delivery-route'),
        points: [driverLocation, destination],
        color: routeColor,
        width: 6,
        geodesic: true,
      ),
      if (demoDeliveryStore.shouldRouteToNode)
        Polyline(
          polylineId: const PolylineId('receiver-walk-route'),
          points: const [receiverLocation, nodeLocation],
          color: FlexiColors.blue,
          width: 4,
          patterns: [PatternItem.dash(16), PatternItem.gap(8)],
          geodesic: true,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;
        final routeText = store.shouldRouteToNode
            ? 'Driver → Indomaret Ahmad Yani'
            : 'Driver → Receiver Address';

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: const FlexiAppBar(title: 'Real Map Demo'),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: hardcodedDriver,
                          zoom: 14,
                        ),
                        markers: _markers(),
                        polylines: _polylines(),
                        myLocationEnabled: usePhoneGps,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        onMapCreated: (controller) async {
                          mapController = controller;
                          await Future.delayed(const Duration(milliseconds: 350));
                          _fitCameraToRoute();
                        },
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: _MapStatusCard(
                          routeText: routeText,
                          store: store,
                          usePhoneGps: usePhoneGps,
                          loadingGps: loadingGps,
                          gpsError: gpsError,
                          onToggleGps: _toggleGps,
                          onSimulateTraffic: store.simulateHeavyTraffic,
                        ),
                      ),
                    ],
                  ),
                ),
                _BottomActionPanel(store: store),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapStatusCard extends StatelessWidget {
  const _MapStatusCard({
    required this.routeText,
    required this.store,
    required this.usePhoneGps,
    required this.loadingGps,
    required this.gpsError,
    required this.onToggleGps,
    required this.onSimulateTraffic,
  });

  final String routeText;
  final DemoDeliveryStore store;
  final bool usePhoneGps;
  final bool loadingGps;
  final String? gpsError;
  final VoidCallback onToggleGps;
  final VoidCallback onSimulateTraffic;

  @override
  Widget build(BuildContext context) {
    return FlexiCard(
      padding: const EdgeInsets.all(12),
      color: Colors.white.withOpacity(0.94),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: store.shouldRouteToNode
                    ? FlexiColors.lightGreen
                    : FlexiColors.orangeSoft,
                child: Icon(
                  store.shouldRouteToNode ? Icons.alt_route : Icons.traffic,
                  color: store.shouldRouteToNode ? FlexiColors.primary : FlexiColors.orange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  routeText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FlexiColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(label: store.statusText, icon: Icons.sync_alt),
              StatusPill(
                label: usePhoneGps ? 'Phone GPS' : 'Hardcoded GPS',
                icon: Icons.gps_fixed,
                color: usePhoneGps ? FlexiColors.primary : FlexiColors.blue,
                background: usePhoneGps ? FlexiColors.lightGreen : FlexiColors.blueSoft,
              ),
            ],
          ),
          if (gpsError != null) ...[
            const SizedBox(height: 8),
            Text(
              gpsError!,
              style: const TextStyle(
                color: FlexiColors.red,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton.icon(
                    onPressed: loadingGps ? null : onToggleGps,
                    icon: loadingGps
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(usePhoneGps ? Icons.gps_off : Icons.gps_fixed, size: 16),
                    label: Text(usePhoneGps ? 'Use Demo GPS' : 'Use Phone GPS'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FlexiColors.primary,
                      side: const BorderSide(color: FlexiColors.border),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: store.offerCreated ? null : onSimulateTraffic,
                    icon: const Icon(Icons.traffic, size: 16),
                    label: const Text('Traffic'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlexiColors.orange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: FlexiColors.border,
                      elevation: 0,
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomActionPanel extends StatelessWidget {
  const _BottomActionPanel({required this.store});

  final DemoDeliveryStore store;

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;
    VoidCallback onPressed;

    if (!store.offerCreated) {
      label = 'Simulate Heavy Traffic';
      icon = Icons.traffic;
      onPressed = store.simulateHeavyTraffic;
    } else if (store.canShowOffer) {
      label = 'Open Receiver Offer';
      icon = Icons.notifications_active_outlined;
      onPressed = () => Navigator.pushNamed(context, '/flexi-offer');
    } else if (!store.dropoffConfirmed) {
      label = 'Confirm Drop-off';
      icon = Icons.check_circle_outline;
      onPressed = store.confirmDropoff;
    } else {
      label = 'View Confirmation';
      icon = Icons.inventory_2_outlined;
      onPressed = () => Navigator.pushNamed(context, '/confirmation');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: FlexiColors.border)),
      ),
      child: FlexiPrimaryButton(
        label: label,
        icon: icon,
        onPressed: onPressed,
        backgroundColor: !store.offerCreated ? FlexiColors.orange : FlexiColors.primary,
      ),
    );
  }
}
