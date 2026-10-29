import 'dart:convert';
import 'package:http/http.dart' as http;

class GeoPlace {
  final String name, subtitle;
  final double lat, lon;
  GeoPlace(this.name, this.subtitle, this.lat, this.lon);
}

/// Place search (name -> coordinates) and "what is here?" (coordinates -> name)
/// using Nominatim, the free search service of OpenStreetMap. No API key needed.
/// Rules of the free service: max 1 request per second, no search-as-you-type,
/// send an app name, show "OpenStreetMap contributors". The app follows these
/// by searching only when the user presses search, and by remembering results.
class MapService {
  static const _headers = {'User-Agent': 'RoamTravelApp/1.0 (student project, Flutter)', 'Accept-Language': 'en'};
  static final Map<String, List<GeoPlace>> _cache = {};

  static GeoPlace _fromJson(Map<String, dynamic> m) {
    final parts = (m['display_name'] as String? ?? '').split(', ');
    final n = (m['name'] as String?)?.trim() ?? '';
    return GeoPlace(n.isNotEmpty ? n : (parts.isNotEmpty ? parts.first : 'Place'), parts.skip(1).take(3).join(', '),
        double.parse('${m['lat']}'), double.parse('${m['lon']}'));
  }

  static Future<List<GeoPlace>> search(String q) async {
    q = q.trim();
    if (q.length < 2) return [];
    final key = q.toLowerCase();
    if (_cache.containsKey(key)) return _cache[key]!;
    final res = await http
        .get(Uri.https('nominatim.openstreetmap.org', '/search', {'q': q, 'format': 'jsonv2', 'limit': '6'}), headers: _headers)
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) throw Exception('search failed');
    final list = (jsonDecode(res.body) as List).map((e) => _fromJson(Map<String, dynamic>.from(e))).toList();
    _cache[key] = list;
    return list;
  }

  static Future<GeoPlace?> reverse(double lat, double lon) async {
    final res = await http
        .get(Uri.https('nominatim.openstreetmap.org', '/reverse', {'lat': '$lat', 'lon': '$lon', 'format': 'jsonv2', 'zoom': '16'}), headers: _headers)
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) return null;
    final m = Map<String, dynamic>.from(jsonDecode(res.body));
    if (m.containsKey('error')) return null;
    return _fromJson(m);
  }
}
