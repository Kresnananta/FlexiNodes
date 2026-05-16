import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationText,
    required this.durationSeconds,
    required this.staticDurationSeconds,
    required this.delayMinutes,
  });

  final List<LatLng> points;
  final int distanceMeters;
  final String durationText;
  final int durationSeconds;
  final int staticDurationSeconds;
  final int delayMinutes;
}

class RoutesApiService {
  RoutesApiService({required this.apiKey});

  final String apiKey;

  Future<RouteResult> getDrivingRoute({
    required LatLng origin,
    required LatLng destination,
    String routingPreference = 'TRAFFIC_AWARE',
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('Google Routes API key is empty.');
    }

    final uri = Uri.parse(
      'https://routes.googleapis.com/directions/v2:computeRoutes',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'routes.distanceMeters,routes.duration,routes.staticDuration,routes.polyline.encodedPolyline',
      },
      body: jsonEncode({
        'origin': {
          'location': {
            'latLng': {
              'latitude': origin.latitude,
              'longitude': origin.longitude,
            },
          },
        },
        'destination': {
          'location': {
            'latLng': {
              'latitude': destination.latitude,
              'longitude': destination.longitude,
            },
          },
        },
        'travelMode': 'DRIVE',
        'routingPreference': routingPreference,
        'computeAlternativeRoutes': false,
        'languageCode': 'en-US',
        'units': 'METRIC',
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Routes API failed: ${response.statusCode} ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = body['routes'] as List<dynamic>?;

    if (routes == null || routes.isEmpty) {
      throw Exception('Routes API returned no routes.');
    }

    final firstRoute = routes.first as Map<String, dynamic>;
    final encodedPolyline =
        firstRoute['polyline']?['encodedPolyline'] as String?;

    if (encodedPolyline == null || encodedPolyline.isEmpty) {
      throw Exception('Routes API returned no encoded polyline.');
    }

    final distanceMeters = (firstRoute['distanceMeters'] as num?)?.toInt() ?? 0;
    final durationRaw = firstRoute['duration'] as String? ?? '0s';
    final staticDurationRaw =
        firstRoute['staticDuration'] as String? ?? durationRaw;
    final durationSeconds = parseDurationSeconds(durationRaw);
    final staticDurationSeconds = parseDurationSeconds(staticDurationRaw);
    final delaySeconds = durationSeconds - staticDurationSeconds;
    final delayMinutes = delaySeconds <= 0 ? 0 : (delaySeconds / 60).round();

    return RouteResult(
      points: decodeEncodedPolyline(encodedPolyline),
      distanceMeters: distanceMeters,
      durationText: _formatDuration(durationRaw),
      durationSeconds: durationSeconds,
      staticDurationSeconds: staticDurationSeconds,
      delayMinutes: delayMinutes,
    );
  }

  static String _formatDuration(String raw) {
    final seconds = parseDurationSeconds(raw);
    if (seconds <= 0) return '-';
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  static int parseDurationSeconds(String raw) {
    final normalized = raw.trim().replaceAll('s', '');
    final seconds = double.tryParse(normalized) ?? 0;
    return seconds.round();
  }

  static List<LatLng> decodeEncodedPolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
