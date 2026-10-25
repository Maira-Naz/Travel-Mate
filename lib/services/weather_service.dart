import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_keys.dart';
import 'storage.dart';

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
}

// ---- parsing helpers (WeatherAPI sends times like "2026-10-25 14:05") ----
DateTime _dt(String s) {
  final p = s.trim().split(RegExp(r'[ T]'));
  final d = p[0].split('-').map(int.parse).toList();
  final t = p.length > 1 ? p[1].split(':').map(int.parse).toList() : [0, 0];
  return DateTime(d[0], d[1], d[2], t[0], t[1]);
}

double _d(dynamic v) => v is num ? v.toDouble() : (double.tryParse('$v') ?? 0);
int _i(dynamic v) => v is num ? v.round() : (int.tryParse('$v') ?? 0);

class WHour {
  final DateTime time;
  final double temp;
  final String text;
  final int code, rain;
  final bool isDay;
  WHour(this.time, this.temp, this.text, this.code, this.rain, this.isDay);
  factory WHour.fromJson(Map<String, dynamic> j) => WHour(_dt(j['time']), _d(j['temp_c']), j['condition']['text'],
      _i(j['condition']['code']), _i(j['chance_of_rain']), _i(j['is_day']) == 1);
}

class WDay {
  final DateTime date;
  final double max, min, maxWind, uv, precip, avgVis;
  final int avgHumidity, rain, code;
  final String text, sunrise, sunset;
  final List<WHour> hours;
  WDay(this.date, this.max, this.min, this.maxWind, this.uv, this.precip, this.avgVis, this.avgHumidity, this.rain,
      this.code, this.text, this.sunrise, this.sunset, this.hours);
  factory WDay.fromJson(Map<String, dynamic> j) {
    final day = j['day'], astro = j['astro'];
    return WDay(
        _dt(j['date']), _d(day['maxtemp_c']), _d(day['mintemp_c']), _d(day['maxwind_kph']), _d(day['uv']),
        _d(day['totalprecip_mm']), _d(day['avgvis_km']), _i(day['avghumidity']), _i(day['daily_chance_of_rain']),
        _i(day['condition']['code']), day['condition']['text'], astro['sunrise'], astro['sunset'],
        (j['hour'] as List).map((h) => WHour.fromJson(Map<String, dynamic>.from(h))).toList());
  }
}

class Weather {
  final String place, region, country, text;
  final DateTime localTime, fetched;
  final double temp, feels, wind, gust, uv, vis, pressure, precip;
  final int humidity, cloud, code;
  final bool isDay;
  final List<WDay> days;
  Weather(this.place, this.region, this.country, this.text, this.localTime, this.fetched, this.temp, this.feels,
      this.wind, this.gust, this.uv, this.vis, this.pressure, this.precip, this.humidity, this.cloud, this.code,
      this.isDay, this.days);
  factory Weather.fromJson(Map<String, dynamic> j) {
    final l = j['location'], c = j['current'];
    return Weather(
        l['name'], l['region'] ?? '', l['country'] ?? '', c['condition']['text'], _dt(l['localtime']),
        j['_fetched'] == null ? DateTime.now() : DateTime.parse(j['_fetched']),
        _d(c['temp_c']), _d(c['feelslike_c']), _d(c['wind_kph']), _d(c['gust_kph']), _d(c['uv']), _d(c['vis_km']),
        _d(c['pressure_mb']), _d(c['precip_mm']), _i(c['humidity']), _i(c['cloud']), _i(c['condition']['code']),
        _i(c['is_day']) == 1,
        (j['forecast']['forecastday'] as List).map((d) => WDay.fromJson(Map<String, dynamic>.from(d))).toList());
  }
}

/// Real weather from WeatherAPI.com (free plan: 3-day forecast).
/// The last answer for each place is saved on the phone so it can be shown offline.
class WeatherService {
  static String _k(String q) => 'weather_${q.toLowerCase().trim()}';

  static Weather? cached(String q) {
    final s = Store.localGet(_k(q));
    if (s == null) return null;
    try {
      return Weather.fromJson(Map<String, dynamic>.from(jsonDecode(s)));
    } catch (_) {
      return null;
    }
  }

  static Future<Weather> fetch(String q) async {
    if (weatherApiKey.isEmpty || weatherApiKey.startsWith('PASTE')) {
      throw WeatherException('Add your WeatherAPI key in lib/api_keys.dart.');
    }
    http.Response res;
    try {
      res = await http
          .get(Uri.https('api.weatherapi.com', '/v1/forecast.json', {'key': weatherApiKey, 'q': q, 'days': '3', 'aqi': 'no', 'alerts': 'no'}))
          .timeout(const Duration(seconds: 12));
    } catch (_) {
      throw WeatherException('No internet connection.');
    }
    Map<String, dynamic> j;
    try {
      j = Map<String, dynamic>.from(jsonDecode(res.body));
    } catch (_) {
      throw WeatherException('The weather service sent an unexpected answer.');
    }
    if (res.statusCode != 200) {
      final code = _i((j['error'] as Map?)?['code']);
      if (code == 1006) throw WeatherException('We could not find "$q". Try a nearby city.');
      if (code == 2006 || code == 2008) throw WeatherException('The weather key is not valid. Check lib/api_keys.dart.');
      if (code == 2007) throw WeatherException('The daily weather limit was reached. Try again later.');
      throw WeatherException('The weather service had a problem (code $code).');
    }
    j['_fetched'] = DateTime.now().toIso8601String();
    try {
      final w = Weather.fromJson(j);
      await Store.localSet(_k(q), jsonEncode(j));
      return w;
    } catch (_) {
      throw WeatherException('Could not read the weather data.');
    }
  }
}
