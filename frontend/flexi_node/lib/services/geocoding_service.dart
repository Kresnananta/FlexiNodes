import 'dart:convert';

import 'package:http/http.dart' as http;

class GeocodingService {
  const GeocodingService({required this.apiKey});

  final String apiKey;

  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (apiKey.trim().isEmpty) return null;

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$latitude,$longitude',
      'key': apiKey,
      'language': 'id',
      'region': 'id',
    });

    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Geocoding API failed: ${response.statusCode} ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['status'] != 'OK') {
      throw Exception('Geocoding API returned ${body['status']}');
    }

    final results = body['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    final first = results.first as Map<String, dynamic>;
    return first['formatted_address'] as String?;
  }
}
