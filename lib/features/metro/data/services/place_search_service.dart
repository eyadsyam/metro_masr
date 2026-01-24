import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PlaceSearchResult {
  final String name;
  final LatLng location;

  PlaceSearchResult({required this.name, required this.location});
}

class PlaceSearchService {
  final String _baseUrl = 'https://nominatim.openstreetmap.org/search';
  final String _userAgent = 'MetroMasrApp/1.0';

  Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    if (query.length < 3) return [];

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?q=${Uri.encodeComponent(query)}&format=json&countrycodes=eg&accept-language=ar&limit=5',
        ),
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          return PlaceSearchResult(
            name: item['display_name'],
            location: LatLng(
              double.parse(item['lat']),
              double.parse(item['lon']),
            ),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
