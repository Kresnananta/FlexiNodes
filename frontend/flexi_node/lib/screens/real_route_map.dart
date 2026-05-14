import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/demo_delivery_store.dart';
import '../services/routes_api_service.dart';
import 'flexi_ui.dart';

class RealRouteMapPage extends StatefulWidget {
  const RealRouteMapPage({
    super.key,
    this.mode = 'receiver',
    this.usePhoneGpsByDefault = false,
  });

  final String mode; // 'receiver' or 'driver'
  final bool usePhoneGpsByDefault;

  @override
  State<RealRouteMapPage> createState() => _RealRouteMapPageState();
}

class _RealRouteMapPageState extends State<RealRouteMapPage> {
  GoogleMapController? mapController;

  // Run with:
  // flutter run --dart-define=GOOGLE_ROUTES_API_KEY=YOUR_KEY
  static const String routesApiKey =
      String.fromEnvironment('GOOGLE_ROUTES_API_KEY');

  final RoutesApiService routesApi = RoutesApiService(apiKey: routesApiKey);

  // Demo coordinates
  static const LatLng demoDriverLocation = LatLng(-7.2756, 112.7420);
  static const LatLng receiverLocation = LatLng(-7.2818, 112.7580);
  static const LatLng nodeLocation = LatLng(-7.2812, 112.7521);

  LatLng driverLocation = demoDriverLocation;

  List<LatLng> routePoints = [
    demoDriverLocation,
    receiverLocation,
  ];

  int distanceMeters = 0;
  String durationText = '-';

  bool usePhoneGps = false;
  bool loadingGps = false;
  bool loadingRoute = false;

  String? gpsError;
  String? routeError;

  bool get isDriverMode => widget.mode == 'driver';

  LatLng get destination {
    return demoDeliveryStore.shouldRouteToNode
        ? nodeLocation
        : receiverLocation;
  }

  String get destinationName {
    return demoDeliveryStore.shouldRouteToNode
        ? demoDeliveryStore.nodeName
        : 'Receiver Address';
  }

  String get mapTitle {
    if (isDriverMode) {
      return demoDeliveryStore.shouldRouteToNode
          ? 'Route to Pickup Node'
          : 'Route to Receiver';
    }

    return demoDeliveryStore.shouldRouteToNode
        ? 'Package Rerouted to Node'
        : 'Package is Being Delivered';
  }

  @override
  void initState() {
    super.initState();

    usePhoneGps = widget.usePhoneGpsByDefault;

    demoDeliveryStore.addListener(_onDemoStateChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (usePhoneGps) {
        await loadPhoneGps();
      } else {
        await loadRoute();
      }
    });
  }

  @override
  void dispose() {
    demoDeliveryStore.removeListener(_onDemoStateChanged);
    mapController?.dispose();
    super.dispose();
  }

  void _onDemoStateChanged() {
    if (!mounted) return;
    loadRoute();
  }

  Future<void> loadPhoneGps() async {
    setState(() {
      loadingGps = true;
      gpsError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('GPS is disabled. Please turn on location services.');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission denied forever. Enable it in app settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        driverLocation = LatLng(position.latitude, position.longitude);
        usePhoneGps = true;
      });

      await loadRoute();
    } catch (e) {
      setState(() {
        gpsError = e.toString().replaceFirst('Exception: ', '');
        usePhoneGps = false;
        driverLocation = demoDriverLocation;
      });

      await loadRoute();
    } finally {
      if (mounted) {
        setState(() => loadingGps = false);
      }
    }
  }

  Future<void> useDemoGps() async {
    setState(() {
      usePhoneGps = false;
      driverLocation = demoDriverLocation;
      gpsError = null;
    });

    await loadRoute();
  }

  Future<void> loadRoute() async {
    setState(() {
      loadingRoute = true;
      routeError = null;
    });

    try {
      final result = await routesApi.getDrivingRoute(
        origin: driverLocation,
        destination: destination,
      );

      setState(() {
        routePoints = result.points;
        distanceMeters = result.distanceMeters;
        durationText = result.durationText;
      });
    } catch (e) {
      setState(() {
        routeError = e.toString().replaceFirst('Exception: ', '');
        routePoints = [
          driverLocation,
          destination,
        ];
      });
    } finally {
      if (mounted) {
        setState(() => loadingRoute = false);
        await fitCameraToRoute();
      }
    }
  }

  Future<void> fitCameraToRoute() async {
    final controller = mapController;

    if (controller == null || routePoints.isEmpty) return;

    final points = [
      ...routePoints,
      driverLocation,
      receiverLocation,
      nodeLocation,
    ];

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
        LatLngBounds(
          southwest: southwest,
          northeast: northeast,
        ),
        70,
      ),
    );
  }

  Set<Marker> get markers {
    return {
      Marker(
        markerId: const MarkerId('driver'),
        position: driverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: isDriverMode ? 'You / Driver' : 'Driver: Rizky Fahmi',
          snippet: usePhoneGps ? 'Live GPS location' : 'Demo driver location',
        ),
      ),
      Marker(
        markerId: const MarkerId('receiver'),
        position: receiverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
          title: 'Receiver: Andika Sujanto',
          snippet: 'Original home delivery address',
        ),
      ),
      Marker(
        markerId: const MarkerId('pickup-node'),
        position: nodeLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: 'Indomaret Ahmad Yani',
          snippet: 'Flexi Pickup Node',
        ),
      ),
    };
  }

  Set<Polyline> get polylines {
    return {
      Polyline(
        polylineId: const PolylineId('driver-route'),
        points: routePoints,
        width: 6,
        color: demoDeliveryStore.shouldRouteToNode
            ? FlexiColors.primary
            : FlexiColors.orange,
        geodesic: true,
      ),

      // Receiver walking path to pickup node after reroute.
      if (demoDeliveryStore.shouldRouteToNode)
        Polyline(
          polylineId: const PolylineId('receiver-walk-to-node'),
          points: const [
            receiverLocation,
            nodeLocation,
          ],
          width: 4,
          color: FlexiColors.blue,
          patterns: [
            PatternItem.dash(16),
            PatternItem.gap(8),
          ],
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final store = demoDeliveryStore;

        return Scaffold(
          backgroundColor: FlexiColors.bg,
          appBar: FlexiAppBar(
            title: isDriverMode ? 'Driver Navigation' : 'Live Tracking',
            actions: [
              IconButton(
                onPressed: loadRoute,
                icon: const Icon(
                  Icons.refresh,
                  color: FlexiColors.primary,
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: demoDriverLocation,
                          zoom: 14,
                        ),
                        markers: markers,
                        polylines: polylines,
                        myLocationEnabled: usePhoneGps,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        onMapCreated: (controller) async {
                          mapController = controller;
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                          await fitCameraToRoute();
                        },
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: _MapInfoCard(
                          title: mapTitle,
                          mode: widget.mode,
                          destinationName: destinationName,
                          statusText: store.statusText,
                          distanceMeters: distanceMeters,
                          durationText: durationText,
                          usePhoneGps: usePhoneGps,
                          loadingGps: loadingGps,
                          loadingRoute: loadingRoute,
                          gpsError: gpsError,
                          routeError: routeError,
                          onUsePhoneGps: loadPhoneGps,
                          onUseDemoGps: useDemoGps,
                        ),
                      ),
                    ],
                  ),
                ),
                _BottomMapActions(
                  isDriverMode: isDriverMode,
                  store: store,
                  onSimulateTraffic: store.simulateHeavyTraffic,
                  onConfirmDropoff: store.confirmDropoff,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapInfoCard extends StatelessWidget {
  const _MapInfoCard({
    required this.title,
    required this.mode,
    required this.destinationName,
    required this.statusText,
    required this.distanceMeters,
    required this.durationText,
    required this.usePhoneGps,
    required this.loadingGps,
    required this.loadingRoute,
    required this.gpsError,
    required this.routeError,
    required this.onUsePhoneGps,
    required this.onUseDemoGps,
  });

  final String title;
  final String mode;
  final String destinationName;
  final String statusText;
  final int distanceMeters;
  final String durationText;
  final bool usePhoneGps;
  final bool loadingGps;
  final bool loadingRoute;
  final String? gpsError;
  final String? routeError;
  final VoidCallback onUsePhoneGps;
  final VoidCallback onUseDemoGps;

  @override
  Widget build(BuildContext context) {
    final distanceText = distanceMeters > 0
        ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
        : '-';

    return FlexiCard(
      color: Colors.white.withOpacity(0.95),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: mode == 'driver'
                    ? FlexiColors.lightGreen
                    : FlexiColors.blueSoft,
                child: Icon(
                  mode == 'driver'
                      ? Icons.navigation
                      : Icons.local_shipping_outlined,
                  color: mode == 'driver'
                      ? FlexiColors.primary
                      : FlexiColors.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FlexiColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (loadingRoute)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Destination: $destinationName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: FlexiColors.muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                icon: Icons.sync_alt,
                label: statusText,
                color: statusText == 'rerouted_to_node'
                    ? FlexiColors.primary
                    : FlexiColors.orange,
                background: statusText == 'rerouted_to_node'
                    ? FlexiColors.lightGreen
                    : FlexiColors.orangeSoft,
              ),
              StatusPill(
                icon: Icons.straighten,
                label: distanceText,
              ),
              StatusPill(
                icon: Icons.timer_outlined,
                label: durationText,
              ),
              StatusPill(
                icon: Icons.gps_fixed,
                label: usePhoneGps ? 'Live GPS' : 'Demo GPS',
                color: usePhoneGps ? FlexiColors.primary : FlexiColors.blue,
                background: usePhoneGps
                    ? FlexiColors.lightGreen
                    : FlexiColors.blueSoft,
              ),
            ],
          ),
          if (gpsError != null) ...[
            const SizedBox(height: 8),
            Text(
              gpsError!,
              style: const TextStyle(
                color: FlexiColors.red,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (routeError != null) ...[
            const SizedBox(height: 8),
            Text(
              'Route API fallback: $routeError',
              style: const TextStyle(
                color: FlexiColors.red,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: OutlinedButton.icon(
              onPressed: loadingGps
                  ? null
                  : usePhoneGps
                      ? onUseDemoGps
                      : onUsePhoneGps,
              icon: loadingGps
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      usePhoneGps ? Icons.gps_off : Icons.gps_fixed,
                      size: 16,
                    ),
              label: Text(
                usePhoneGps ? 'Use Demo GPS' : 'Use Phone GPS',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: FlexiColors.primary,
                side: const BorderSide(color: FlexiColors.border),
                textStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomMapActions extends StatelessWidget {
  const _BottomMapActions({
    required this.isDriverMode,
    required this.store,
    required this.onSimulateTraffic,
    required this.onConfirmDropoff,
  });

  final bool isDriverMode;
  final DemoDeliveryStore store;
  final VoidCallback onSimulateTraffic;
  final VoidCallback onConfirmDropoff;

  @override
  Widget build(BuildContext context) {
    if (isDriverMode) {
      if (!store.offerCreated) {
        return _BottomContainer(
          child: FlexiPrimaryButton(
            label: 'Simulate Heavy Traffic',
            icon: Icons.traffic,
            backgroundColor: FlexiColors.orange,
            onPressed: onSimulateTraffic,
          ),
        );
      }

      if (store.canShowOffer) {
        return _BottomContainer(
          child: FlexiPrimaryButton(
            label: 'Waiting for Receiver Approval',
            icon: Icons.hourglass_empty,
            backgroundColor: FlexiColors.orange,
            onPressed: () => Navigator.pushNamed(context, '/ai-chat'),
          ),
        );
      }

      if (!store.dropoffConfirmed) {
        return _BottomContainer(
          child: FlexiPrimaryButton(
            label: 'Confirm Drop-off',
            icon: Icons.check_circle_outline,
            onPressed: onConfirmDropoff,
          ),
        );
      }

      return _BottomContainer(
        child: FlexiPrimaryButton(
          label: 'Drop-off Completed',
          icon: Icons.inventory_2_outlined,
          onPressed: () => Navigator.pushNamed(context, '/confirmation'),
        ),
      );
    }

    return _BottomContainer(
      child: Row(
        children: [
          Expanded(
            child: FlexiPrimaryButton(
              label: store.canShowOffer ? 'View Flexi Offer' : 'Open AI Chat',
              icon: store.canShowOffer
                  ? Icons.notifications_active_outlined
                  : Icons.auto_awesome,
              onPressed: () => Navigator.pushNamed(
                context,
                store.canShowOffer ? '/flexi-offer' : '/ai-chat',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FlexiOutlineButton(
              label: 'Nearby Nodes',
              icon: Icons.storefront,
              onPressed: () => Navigator.pushNamed(context, '/nearby-nodes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomContainer extends StatelessWidget {
  const _BottomContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: FlexiColors.border),
        ),
      ),
      child: child,
    );
  }
}