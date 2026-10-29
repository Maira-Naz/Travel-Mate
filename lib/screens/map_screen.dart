import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core.dart';
import '../models/models.dart';
import '../services/map_service.dart';
import '../services/trip_store.dart';

class _Sel {
  final String name, sub;
  final double lat, lon;
  final TripPlace? place; // set when it is one of the trip's saved places
  _Sel(this.name, this.sub, this.lat, this.lon, {this.place});
}

// ---------------- MAP (OpenStreetMap + flutter_map) ----------------
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const pakistan = LatLng(30.3753, 69.3451);
  final controller = MapController();
  final search = TextEditingController();
  List<GeoPlace> results = [];
  bool searching = false;
  String? msg;
  _Sel? sel;

  @override
  void initState() {
    super.initState();
    _centerOnTrip();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _snack(String t) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(t)));

  /// Start on the current trip's destination (found with the free search service).
  Future<void> _centerOnTrip() async {
    final t = TripStore.i.active;
    if (t == null) return;
    await Future.delayed(const Duration(milliseconds: 400)); // let the map appear first
    try {
      final r = await MapService.search(t.destination);
      if (r.isNotEmpty && mounted) controller.move(LatLng(r.first.lat, r.first.lon), 10);
    } catch (_) {}
  }

  Future<void> _search() async {
    final q = search.text.trim();
    if (q.length < 2 || searching) return;
    FocusScope.of(context).unfocus();
    setState(() {
      searching = true;
      msg = null;
      results = [];
    });
    try {
      final r = await MapService.search(q);
      if (!mounted) return;
      setState(() {
        results = r;
        msg = r.isEmpty ? 'No places found for "$q". Try another spelling.' : null;
      });
    } catch (_) {
      if (mounted) setState(() => msg = 'Could not search. Check your internet connection.');
    }
    if (mounted) setState(() => searching = false);
  }

  void _pick(GeoPlace g) {
    setState(() {
      results = [];
      sel = _Sel(g.name, g.subtitle, g.lat, g.lon);
    });
    controller.move(LatLng(g.lat, g.lon), 13);
  }

  /// Long-press on the map: drop a pin and find out what is there.
  Future<void> _longPress(LatLng p) async {
    final coords = '${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}';
    setState(() {
      results = [];
      sel = _Sel('Dropped pin', 'Looking up the name...', p.latitude, p.longitude);
    });
    GeoPlace? g;
    try {
      g = await MapService.reverse(p.latitude, p.longitude);
    } catch (_) {}
    if (!mounted || sel?.lat != p.latitude) return;
    setState(() => sel = g == null ? _Sel('Dropped pin', coords, p.latitude, p.longitude) : _Sel(g.name, g.subtitle, p.latitude, p.longitude));
  }

  void _addToTrip(_Sel s) {
    final t = TripStore.i.active;
    if (t == null) return _snack('Add a trip first, then you can save places to it.');
    if (TripStore.i.placesFor(t.id).any((p) => p.name.toLowerCase() == s.name.toLowerCase())) {
      return _snack('"${s.name}" is already in ${t.name}.');
    }
    TripStore.i.addPlace(TripPlace(id: newId(), tripId: t.id, name: s.name, lat: s.lat, lon: s.lon));
    setState(() => sel = null);
    _snack('Added to ${t.name}. Find it under Visited.');
  }

  void _zoom(double by) {
    final c = controller.camera;
    controller.move(c.center, (c.zoom + by).clamp(3.0, 18.0).toDouble());
  }

  Widget _roundBtn(IconData i, String tip, VoidCallback f) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Tooltip(
            message: tip,
            child: Tap(
                radius: 24,
                onTap: f,
                child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: C.line), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                    child: Icon(i, color: C.forest)))),
      );

  Widget _card(_Sel s) {
    final p = s.place;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 18)]),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(s.name, style: head(22), maxLines: 2, overflow: TextOverflow.ellipsis)),
          IconButton(icon: const Icon(Icons.close, color: C.muted), onPressed: () => setState(() => sel = null)),
        ]),
        Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(s.sub, style: body(14), maxLines: 2, overflow: TextOverflow.ellipsis)),
        const SizedBox(height: 4),
        Text('${s.lat.toStringAsFixed(4)}, ${s.lon.toStringAsFixed(4)}', style: body(12)),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SizedBox(
              width: double.infinity,
              child: p == null
                  ? Btn('Add to my places', () => _addToTrip(s), icon: Icons.add_location_alt_outlined)
                  : Btn(p.visited ? 'Visited. Tap to undo' : 'Mark visited', () {
                      p.visited = !p.visited;
                      p.visitedOn = p.visited ? dateOnly(DateTime.now()).toIso8601String() : null;
                      TripStore.i.touch(p: true);
                      setState(() {});
                    }, outlined: p.visited)),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = TripStore.i.active;
    return Scaffold(
      backgroundColor: const Color(0xFFCADCC8),
      body: Stack(children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: pakistan,
            initialZoom: 5.5,
            minZoom: 3,
            maxZoom: 18,
            onLongPress: (_, p) => _longPress(p),
            onTap: (_, __) {
              FocusScope.of(context).unfocus();
              if (results.isNotEmpty || sel != null) {
                setState(() {
                  results = [];
                  sel = null;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.travel_app', // change to your applicationId
            ),
            AnimatedBuilder(
              animation: TripStore.i,
              builder: (_, __) {
                final ps = t == null ? <TripPlace>[] : TripStore.i.placesFor(t.id).where((p) => p.lat != null && p.lon != null).toList();
                return MarkerLayer(markers: [
                  for (final p in ps)
                    Marker(
                      point: LatLng(p.lat!, p.lon!),
                      width: 48, height: 48,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          results = [];
                          sel = _Sel(p.name, t?.name ?? '', p.lat!, p.lon!, place: p);
                        }),
                        child: Icon(p.visited ? Icons.where_to_vote : Icons.location_on, size: 44, color: p.visited ? C.sage : C.forest),
                      ),
                    ),
                ]);
              },
            ),
            if (sel != null && sel!.place == null)
              MarkerLayer(markers: [
                Marker(
                  point: LatLng(sel!.lat, sel!.lon),
                  width: 52, height: 52,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.location_on, size: 48, color: Color(0xFF356A8A)),
                ),
              ]),
            RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
          ],
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(children: [
              Row(children: [
                const BackDot(),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                    child: TextField(
                      controller: search,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        hintText: 'Search a place',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: C.sage),
                        suffixIcon: searching
                            ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: C.forest)))
                            : IconButton(icon: const Icon(Icons.arrow_forward, color: C.forest), onPressed: _search),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ]),
              if (msg != null)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF3E8BF), borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    const Icon(Icons.info_outline, size: 20, color: Color(0xFF6B5410)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(msg!, style: body(13, c: const Color(0xFF6B5410), w: FontWeight.w600))),
                  ]),
                ),
              if (results.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  constraints: const BoxConstraints(maxHeight: 290),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: C.line),
                      itemBuilder: (_, i) => ListTile(
                        leading: const Icon(Icons.place_outlined, color: C.sage),
                        title: Text(results[i].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: body(15, c: C.forest, w: FontWeight.w700)),
                        subtitle: Text(results[i].subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: body(12)),
                        onTap: () => _pick(results[i]),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ),
        Positioned(
          right: 16,
          bottom: sel != null ? 250 : 70,
          child: Column(children: [
            _roundBtn(Icons.add, 'Zoom in', () => _zoom(1)),
            _roundBtn(Icons.remove, 'Zoom out', () => _zoom(-1)),
            _roundBtn(Icons.flag_outlined, 'Go to my trip', _centerOnTrip),
          ]),
        ),
        if (sel == null)
          Positioned(
            left: 16, right: 80, bottom: 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.white.withAlpha(235), borderRadius: BorderRadius.circular(20)),
              child: Text('Tip: press and hold anywhere on the map to drop a pin.', style: body(13, c: C.forest, w: FontWeight.w600)),
            ),
          ),
        if (sel != null) Positioned(left: 16, right: 16, bottom: 24, child: _card(sel!)),
      ]),
    );
  }
}
