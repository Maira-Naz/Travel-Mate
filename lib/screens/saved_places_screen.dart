import 'package:flutter/material.dart';
import '../core.dart';
import '../services/app_state.dart';
import 'all_destinations_screen.dart';
import 'destination_screen.dart';
import 'map_screen.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  Widget _removeBtn(String tip, VoidCallback f) => Tooltip(
      message: tip,
      child: Tap(
          radius: 22,
          onTap: f,
          child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(color: Color(0x1FC4472E), shape: BoxShape.circle),
              child: const Icon(Icons.favorite, color: C.rust))));

  @override
  Widget build(BuildContext context) => SubPage('Saved places',
      child: AnimatedBuilder(
        animation: Listenable.merge([AppState.saved, AppState.savedMap]),
        builder: (_, __) {
          final list = places.where((p) => AppState.saved.value.contains(p.name)).toList();
          final maps = AppState.savedMap.value;
          if (list.isEmpty && maps.isEmpty) {
            return EmptyState(Icons.favorite_border, 'Nothing saved yet',
                'Tap the heart on a destination, or choose Add to favourites on a place in the map.',
                action: Btn('Browse destinations', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllDestinationsScreen()))));
          }
          return ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
            if (list.isNotEmpty) ...[
              Text('Destinations', style: head(20)),
              const SizedBox(height: 10),
              for (final p in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Box(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DestinationScreen(p))),
                      child: Row(children: [
                        PlaceThumb(p.colors, size: 64),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, style: body(17, c: C.forest, w: FontWeight.w800)),
                          Text(p.region, style: body(13)),
                          Text('From ${p.price}', style: body(14, c: C.forest, w: FontWeight.w700)),
                        ])),
                        _removeBtn('Remove from saved', () => AppState.toggleSaved(p.name)),
                      ])),
                ),
              const SizedBox(height: 10),
            ],
            if (maps.isNotEmpty) ...[
              Text('Places from the map', style: head(20)),
              const SizedBox(height: 4),
              Text('Tap a place to see it on the map.', style: body(13)),
              const SizedBox(height: 10),
              for (final m in maps)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Box(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MapScreen(
                                  focusName: m['name'] as String, focusSub: m['sub'] as String? ?? '',
                                  focusLat: (m['lat'] as num).toDouble(), focusLon: (m['lon'] as num).toDouble()))),
                      child: Row(children: [
                        Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(color: const Color(0xFFE3EEE7), borderRadius: BorderRadius.circular(18)),
                            child: const Icon(Icons.place, color: C.forest, size: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m['name'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: body(17, c: C.forest, w: FontWeight.w800)),
                          if (((m['sub'] as String?) ?? '').isNotEmpty) Text(m['sub'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: body(13)),
                          Row(children: [
                            const Icon(Icons.map_outlined, size: 15, color: Color(0xFF356A8A)),
                            const SizedBox(width: 4),
                            Text('Open on map', style: body(13, c: const Color(0xFF356A8A), w: FontWeight.w700)),
                          ]),
                        ])),
                        _removeBtn('Remove from favourites', () {
                          AppState.toggleMapSaved(m['name'] as String, (m['sub'] as String?) ?? '', (m['lat'] as num).toDouble(), (m['lon'] as num).toDouble());
                        }),
                      ])),
                ),
            ],
            const SizedBox(height: 16),
          ]);
        },
      ));
}
