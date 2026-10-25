import 'package:flutter/material.dart';
import '../core.dart';
import '../models/models.dart';
import '../services/trip_store.dart';
import '../services/weather_service.dart';

// ---------------- helpers: icons, colours, advice ----------------
String weatherKind(int c) {
  if (c == 1000) return 'clear';
  if (c == 1003) return 'partly';
  if (c == 1006 || c == 1009) return 'cloudy';
  if ({1030, 1135, 1147}.contains(c)) return 'fog';
  if ({1087, 1273, 1276, 1279, 1282}.contains(c)) return 'thunder';
  if ({1066, 1069, 1072, 1114, 1117, 1204, 1207, 1210, 1213, 1216, 1219, 1222, 1225, 1237, 1249, 1252, 1255, 1258, 1261, 1264}.contains(c)) return 'snow';
  return 'rain';
}

IconData weatherIcon(int code, bool isDay) {
  switch (weatherKind(code)) {
    case 'clear':
      return isDay ? Icons.wb_sunny_outlined : Icons.nightlight_outlined;
    case 'partly':
      return isDay ? Icons.wb_cloudy_outlined : Icons.nights_stay_outlined;
    case 'cloudy':
      return Icons.cloud_outlined;
    case 'fog':
      return Icons.blur_on;
    case 'thunder':
      return Icons.flash_on;
    case 'snow':
      return Icons.ac_unit;
    default:
      return Icons.water_drop_outlined;
  }
}

// Same green gradient as the design (slightly deeper at night).
List<Color> weatherColors(int code, bool isDay) {
  if (!isDay) return const [Color(0xFF4F6F66), Color(0xFF22362F)];
  return const [Color(0xFF6E907F), Color(0xFF2F4A43)];
}

/// Simple advice from the forecast of one day.
List<List<Object>> tipsFor(WDay d) {
  final kind = weatherKind(d.code);
  final rain = d.rain;
  final wind = d.maxWind;
  const gBg = Color(0xFFD9EBDD), gFg = Color(0xFF2A6B3C), yBg = Color(0xFFF3E8BF), yFg = Color(0xFF6B5410), rBg = Color(0xFFF7D9D2), rFg = Color(0xFF8E2A18);
  List<Object> t(String a, String b, int level) =>
      [a, b, ['Great pick', 'Good', 'Skip today'][level], [gBg, yBg, rBg][level], [gFg, yFg, rFg][level]];
  return [
    if (kind == 'thunder' || rain >= 50 || wind >= 30)
      t('Hiking and viewpoints', 'Slippery trails and strong wind. Stay low today.', 2)
    else if (rain >= 30 || wind >= 20 || d.max <= 5)
      t('Hiking and viewpoints', d.max <= 5 ? 'Very cold up high. Dress in layers.' : 'Showers or gusts possible. Carry a jacket.', 1)
    else
      t('Hiking and viewpoints', 'Clear and calm. Great views.', 0),
    if (kind == 'thunder' || rain >= 40 || wind >= 22)
      t('Lakes and boating', 'Rough water and rain. Better another day.', 2)
    else if (rain < 20 && wind < 15)
      t('Lakes and boating', 'Calm water, clear views.', 0)
    else
      t('Lakes and boating', 'Fine, but check the sky first.', 1),
    if (rain >= 50) t('Forts and old towns', 'Good shelter while it rains.', 0) else t('Forts and old towns', 'Works in any light.', 1),
    if (rain >= 60 || kind == 'snow')
      t('Mountain roads', 'Heavy rain or snow. Landslide risk. Check road status.', 2)
    else if (rain >= 35 || kind == 'fog')
      t('Mountain roads', 'Slippery or low visibility. Drive slowly.', 1)
    else
      t('Mountain roads', 'Roads should be clear. Still check the status.', 0),
  ];
}

// ---------------- screen ----------------
class _Loc {
  final String label, q;
  const _Loc(this.label, this.q);
}

const _known = {
  'hunza': '36.3167,74.6500', 'skardu': '35.2971,75.6333', 'swat': '34.7717,72.3600', 'naran': '34.9068,73.6512',
  'kaghan': '34.9068,73.6512', 'islamabad': '33.6844,73.0479', 'lahore': '31.5204,74.3587', 'chakwal': '32.9300,72.8550',
};

_Loc _resolve(String name) {
  final n = name.trim();
  final l = n.toLowerCase();
  for (final e in _known.entries) {
    if (l.contains(e.key)) return _Loc(n, e.value);
  }
  return _Loc(n, n);
}

class WeatherScreen extends StatefulWidget {
  final String? query;
  const WeatherScreen({super.key, this.query});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late _Loc loc = _resolve(widget.query ?? TripStore.i.active?.destination ?? 'Hunza');
  final search = TextEditingController();
  Weather? w;
  bool loading = false, fromCache = false;
  String? error, note;
  int dayIdx = 0;

  @override
  void initState() {
    super.initState();
    w = WeatherService.cached(loc.q);
    fromCache = w != null;
    _load();
  }

  void _go(_Loc l) {
    FocusScope.of(context).unfocus();
    setState(() {
      loc = l;
      w = WeatherService.cached(l.q);
      fromCache = w != null;
      error = null;
      note = null;
      dayIdx = 0;
    });
    _load();
  }

  Future<void> _load() async {
    final target = loc;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final r = await WeatherService.fetch(target.q);
      if (!mounted || !identical(target, loc)) return;
      setState(() {
        w = r;
        fromCache = false;
        note = null;
        loading = false;
      });
    } on WeatherException catch (e) {
      if (!mounted || !identical(target, loc)) return;
      setState(() {
        loading = false;
        if (w == null) {
          error = e.message;
        } else {
          note = e.message;
        }
      });
    }
  }

  String _dayName(int i, WDay d) => i == 0 ? 'Today' : (i == 1 ? 'Tomorrow' : fmtWeekday(d.date));

  // ---- pieces ----
  Widget _chips() {
    final names = <String>[if (TripStore.i.active != null) TripStore.i.active!.destination, 'Hunza', 'Skardu', 'Swat', 'Naran', 'Islamabad', 'Lahore'];
    final seen = <String>{};
    final list = names.where((n) => seen.add(_resolve(n).q)).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final n in list)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tap(
              radius: 20,
              onTap: () => _go(_resolve(n)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                    color: _resolve(n).q == loc.q ? C.forest : Colors.white,
                    borderRadius: BorderRadius.circular(20), border: Border.all(color: C.line)),
                child: Text(n, style: body(13, c: _resolve(n).q == loc.q ? C.cream : C.forest, w: FontWeight.w700)),
              ),
            ),
          ),
      ]),
    );
  }

  // Hero card: matches the design (place, big temp, condition, icon, divider, 3 stats).
  Widget _hero(Weather x) {
    final d0 = x.days.first;
    const soft = Color(0xFFD5DDD6);
    Widget stat(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: body(13, c: soft)),
      const SizedBox(height: 4),
      Text(value, style: body(15, c: C.cream, w: FontWeight.w800)),
    ]);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: weatherColors(x.code, x.isDay))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${loc.label}, today', maxLines: 1, overflow: TextOverflow.ellipsis, style: body(15, c: soft)),
                Text('${x.temp.round()}°', style: head(72, c: C.cream)),
                Text(x.text, style: body(18, c: C.cream, w: FontWeight.w500)),
              ])),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Icon(weatherIcon(x.code, x.isDay), key: ValueKey('${x.code}${x.isDay}'), size: 64, color: C.cream)),
          ),
        ]),
        const SizedBox(height: 14),
        Container(height: 1, color: Colors.white24),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          stat('Humidity', '${x.humidity}%'),
          stat('Wind', '${x.wind.round()} km/h'),
          stat('Rain chance', '${d0.rain}%'),
        ]),
      ]),
    );
  }

  // Day tabs: unchanged.
  Widget _days(Weather x) => Row(children: [
    for (var i = 0; i < x.days.length; i++)
      Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == x.days.length - 1 ? 0 : 10),
            child: Tap(
              radius: 22,
              onTap: () => setState(() => dayIdx = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: dayIdx == i ? C.forest : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: C.line)),
                child: Column(children: [
                  Text(_dayName(i, x.days[i]), style: body(13, c: dayIdx == i ? C.cream : C.muted, w: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Icon(weatherIcon(x.days[i].code, true), color: dayIdx == i ? C.cream : C.sage),
                  const SizedBox(height: 6),
                  Text('${x.days[i].max.round()}° / ${x.days[i].min.round()}°', style: body(14, c: dayIdx == i ? C.cream : C.forest, w: FontWeight.w800)),
                  Text('${x.days[i].rain}% rain', style: body(12, c: dayIdx == i ? const Color(0xFFD5DDD6) : const Color(0xFF356A8A))),
                ]),
              ),
            ),
          )),
  ]);

  // Hour by hour: exactly 4 cards fit the screen width, scroll for the rest.
  Widget _hourly(Weather x, WDay d) {
    var hrs = d.hours;
    if (dayIdx == 0) {
      final t = x.localTime;
      final start = DateTime(t.year, t.month, t.day, t.hour);
      hrs = hrs.where((h) => !h.time.isBefore(start)).toList();
    }
    return LayoutBuilder(builder: (context, c) {
      const gap = 10.0;
      final itemW = (c.maxWidth - gap * 3) / 4;
      return SizedBox(
        height: 126,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: hrs.length,
          separatorBuilder: (_, __) => const SizedBox(width: gap),
          itemBuilder: (_, i) {
            final h = hrs[i];
            final now = dayIdx == 0 && i == 0;
            return Container(
              width: itemW,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: now ? C.forest : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: C.line)),
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(now ? 'Now' : fmtTod(TimeOfDay.fromDateTime(h.time)).replaceAll(':00', ''), style: body(12, c: now ? C.cream : C.muted, w: FontWeight.w700)),
                Icon(weatherIcon(h.code, h.isDay), size: 24, color: now ? C.cream : C.sage),
                Text('${h.temp.round()}°', style: body(16, c: now ? C.cream : C.forest, w: FontWeight.w800)),
                Text('${h.rain}%', style: body(11, c: now ? C.sky : const Color(0xFF356A8A), w: FontWeight.w700)),
              ]),
            );
          },
        ),
      );
    });
  }

  // "Where to go in this weather" cards.
  Widget _tips(WDay d) => Column(children: [
    for (final t in tipsFor(d))
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.line)),
        child: Row(children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t[0] as String, style: body(16, c: C.forest, w: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(t[1] as String, style: body(13, c: C.muted)),
              ])),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: t[3] as Color, borderRadius: BorderRadius.circular(20)),
            child: Text(t[2] as String, style: body(12, c: t[4] as Color, w: FontWeight.w800)),
          ),
        ]),
      ),
  ]);

  Widget _banner(String text, IconData icon) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF3E8BF), borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Icon(icon, size: 20, color: const Color(0xFF6B5410)),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: body(13, c: const Color(0xFF6B5410), w: FontWeight.w600))),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final x = w;
    final d = x == null ? null : x.days[dayIdx.clamp(0, x.days.length - 1)];
    return SubPage('Weather',
        sub: x == null ? 'Live forecast' : '${x.place}${x.region.isEmpty ? '' : ', ${x.region}'}',
        child: RefreshIndicator(
          color: C.forest,
          onRefresh: _load,
          child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(22, 0, 22, 24), children: [
            TextField(
              controller: search,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) => v.trim().length >= 2 ? _go(_resolve(v)) : null,
              decoration: InputDecoration(
                hintText: 'Search any city or place',
                prefixIcon: const Icon(Icons.search, color: C.sage),
                suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward, color: C.forest), onPressed: () => search.text.trim().length >= 2 ? _go(_resolve(search.text)) : null),
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: const BorderSide(color: C.line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: const BorderSide(color: C.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: const BorderSide(color: C.forest, width: 1.4)),
              ),
            ),
            const SizedBox(height: 12),
            _chips(),
            const SizedBox(height: 16),
            if (x == null && error != null)
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: EmptyState(Icons.cloud_off_outlined, "Can't load the weather", error!, action: Btn('Try again', _load, icon: Icons.refresh)))
            else if (x == null)
              const Padding(padding: EdgeInsets.all(50), child: Center(child: CircularProgressIndicator(color: C.forest)))
            else ...[
                if (note != null) _banner('Showing saved weather from ${fmtDate(x.fetched)}, ${fmtTod(TimeOfDay.fromDateTime(x.fetched))}. $note', Icons.cloud_off_outlined)
                else if (fromCache && loading) _banner('Showing saved weather while we update it...', Icons.sync),
                _hero(x),
                const SizedBox(height: 14),
                _days(x),
                const SizedBox(height: 22),
                Text('Hour by hour  ·  ${_dayName(dayIdx.clamp(0, x.days.length - 1), d!)}', style: head(20)),
                const SizedBox(height: 10),
                _hourly(x, d),
                const SizedBox(height: 22),
                Text('Where to go in this weather', style: head(20)),
                const SizedBox(height: 10),
                _tips(d),
                const SizedBox(height: 8),
                Center(child: Text('Weather data by WeatherAPI.com. Pull down to refresh.', style: body(12))),
              ],
          ]),
        ));
  }
}