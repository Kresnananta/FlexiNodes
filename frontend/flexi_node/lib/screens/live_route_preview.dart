import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/demo_delivery_store.dart';
import '../services/routes_api_service.dart';
import 'flexi_ui.dart';
import 'map_marker_icons.dart';

class LiveRoutePreview extends StatefulWidget {
  const LiveRoutePreview({
    super.key,
    this.height = 180,
    this.mode = 'receiver',
    this.showOpenButton = false,
    this.forceDestinationToSelectedNode = false,
  });

  final double height;
  final String mode; // receiver or driver
  final bool showOpenButton;

  /// Use this on NearbyNodesPage so the preview always routes to the selected node,
  /// even before the receiver officially accepts the reroute offer.
  final bool forceDestinationToSelectedNode;

  @override
  State<LiveRoutePreview> createState() => _LiveRoutePreviewState();
}

class _LiveRoutePreviewState extends State<LiveRoutePreview> {
  GoogleMapController? mapController;

  static const String routesApiKey = String.fromEnvironment(
    'GOOGLE_ROUTES_API_KEY',
  );

  final RoutesApiService routesApi = RoutesApiService(apiKey: routesApiKey);

  static const LatLng fallbackDriverLocation = LatLng(-7.2756, 112.7420);
  static const LatLng fallbackReceiverLocation = LatLng(-7.2818, 112.7580);

  List<LatLng> routePoints = const [
    fallbackDriverLocation,
    fallbackReceiverLocation,
  ];

  bool loadingRoute = false;
  String? routeError;

  BitmapDescriptor driverMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueAzure,
  );
  BitmapDescriptor receiverMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueOrange,
  );
  BitmapDescriptor nodeMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueGreen,
  );

  LatLng get selectedNodeLocation {
    return LatLng(
      demoDeliveryStore.nodeLatitude,
      demoDeliveryStore.nodeLongitude,
    );
  }

  LatLng get driverLocation {
    return LatLng(
      demoDeliveryStore.driverLatitude,
      demoDeliveryStore.driverLongitude,
    );
  }

  LatLng get receiverLocation {
    return LatLng(
      demoDeliveryStore.receiverLatitude,
      demoDeliveryStore.receiverLongitude,
    );
  }

  LatLng get destination {
    if (widget.forceDestinationToSelectedNode ||
        demoDeliveryStore.shouldRouteToNode) {
      return selectedNodeLocation;
    }

    return receiverLocation;
  }

  bool get isDriverMode => widget.mode == 'driver';

  @override
  void initState() {
    super.initState();
    demoDeliveryStore.addListener(_onDeliveryChanged);
    _loadMarkerIcons();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadRoute();
    });
  }

  @override
  void dispose() {
    demoDeliveryStore.removeListener(_onDeliveryChanged);
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMarkerIcons() async {
    final icons = await Future.wait([
      FlexiMapMarkerIcon.build(
        shape: FlexiMapMarkerShape.circle,
        color: FlexiColors.blue,
        icon: Icons.local_shipping_outlined,
      ),
      FlexiMapMarkerIcon.build(
        shape: FlexiMapMarkerShape.diamond,
        color: FlexiColors.orange,
        icon: Icons.person_pin_circle_outlined,
      ),
      FlexiMapMarkerIcon.build(
        shape: FlexiMapMarkerShape.square,
        color: FlexiColors.primary,
        icon: Icons.storefront,
      ),
    ]);

    if (!mounted) return;

    setState(() {
      driverMarkerIcon = icons[0];
      receiverMarkerIcon = icons[1];
      nodeMarkerIcon = icons[2];
    });
  }

  void _onDeliveryChanged() {
    if (!mounted) return;
    loadRoute();
  }

  Future<void> loadRoute() async {
    if (loadingRoute) return;

    setState(() {
      loadingRoute = true;
      routeError = null;
    });

    try {
      final result = await routesApi.getDrivingRoute(
        origin: driverLocation,
        destination: destination,
      );

      if (!mounted) return;

      setState(() {
        routePoints = result.points;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        routeError = e.toString().replaceFirst('Exception: ', '');
        routePoints = [driverLocation, destination];
      });
    } finally {
      if (!mounted) return;

      setState(() => loadingRoute = false);
      await fitCamera();
    }
  }

  Future<void> fitCamera() async {
    final controller = mapController;
    if (controller == null || routePoints.isEmpty) return;

    final points = [
      ...routePoints,
      driverLocation,
      receiverLocation,
      selectedNodeLocation,
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
        LatLngBounds(southwest: southwest, northeast: northeast),
        58,
      ),
    );
  }

  Set<Marker> get markers {
    return {
      Marker(
        markerId: const MarkerId('driver'),
        position: driverLocation,
        icon: driverMarkerIcon,
        infoWindow: InfoWindow(
          title: 'Driver: ${demoDeliveryStore.driverName}',
          snippet: 'Package courier',
        ),
      ),
      Marker(
        markerId: const MarkerId('receiver'),
        position: receiverLocation,
        icon: receiverMarkerIcon,
        infoWindow: InfoWindow(
          title: 'Receiver: ${demoDeliveryStore.receiverName}',
          snippet: 'Original delivery destination',
        ),
      ),
      Marker(
        markerId: const MarkerId('selected-node'),
        position: selectedNodeLocation,
        icon: nodeMarkerIcon,
        infoWindow: InfoWindow(
          title: demoDeliveryStore.nodeName,
          snippet: 'Selected pickup node • ${demoDeliveryStore.nodeDistance}',
        ),
      ),
    };
  }

  Set<Polyline> get polylines {
    return {
      Polyline(
        polylineId: const PolylineId('live-preview-route'),
        points: routePoints,
        width: 5,
        color:
            widget.forceDestinationToSelectedNode ||
                demoDeliveryStore.shouldRouteToNode
            ? FlexiColors.primary
            : FlexiColors.orange,
      ),
      if (widget.forceDestinationToSelectedNode ||
          demoDeliveryStore.shouldRouteToNode)
        Polyline(
          polylineId: const PolylineId('receiver-to-node-walk'),
          points: [receiverLocation, selectedNodeLocation],
          width: 3,
          color: FlexiColors.blue,
          patterns: [PatternItem.dash(16), PatternItem.gap(8)],
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demoDeliveryStore,
      builder: (context, _) {
        final bool routingToNode =
            widget.forceDestinationToSelectedNode ||
            demoDeliveryStore.shouldRouteToNode;

        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: fallbackDriverLocation,
                    zoom: 14,
                  ),
                  markers: markers,
                  polylines: polylines,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  onMapCreated: (controller) async {
                    mapController = controller;
                    await Future.delayed(const Duration(milliseconds: 300));
                    await fitCamera();
                  },
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _MapSmallChip(
                    icon: Icons.local_shipping_outlined,
                    label: 'Driver',
                    color: FlexiColors.blue,
                    background: Colors.white,
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _MapSmallChip(
                    icon: routingToNode
                        ? Icons.storefront
                        : Icons.warning_amber,
                    label: routingToNode
                        ? demoDeliveryStore.nodeDistance
                        : 'Heavy traffic',
                    color: routingToNode
                        ? FlexiColors.primary
                        : FlexiColors.orange,
                    background: Colors.white,
                  ),
                ),
                if (loadingRoute)
                  const Positioned(
                    left: 12,
                    bottom: 12,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                if (routeError != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Route fallback: $routeError',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: FlexiColors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (widget.showOpenButton)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: routeError == null ? 12 : 48,
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/real-map',
                          arguments: {
                            'mode': widget.mode,
                            'usePhoneGps': isDriverMode,
                          },
                        ),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('View Live Route Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlexiColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
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

class _MapSmallChip extends StatelessWidget {
  const _MapSmallChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background.withOpacity(0.94),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
