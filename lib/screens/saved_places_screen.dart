import 'package:flutter/material.dart';
import '../core.dart';
import '../services/app_state.dart';
import 'all_destinations_screen.dart';
import 'destination_screen.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});
  @override
  Widget build(BuildContext context) => SubPage('Saved places',
      child: ValueListenableBuilder<List<String>>(
        valueListenable: AppState.saved,
        builder: (_, saved, __) {
          final list = places.where((p) => saved.contains(p.name)).toList();
          if (list.isEmpty) {
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.favorite_border, size: 56, color: C.sage),
                      const SizedBox(height: 12),
                      Text('Nothing saved yet', style: head(22)),
                      const SizedBox(height: 6),
                      Text('Tap the heart on a destination to keep it here.', textAlign: TextAlign.center, style: body(15)),
                      const SizedBox(height: 20),
                      Btn('Browse destinations', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllDestinationsScreen()))),
                    ])));
          }
          return ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
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
                      Tooltip(
                          message: 'Remove from saved',
                          child: Tap(
                              radius: 22,
                              onTap: () => AppState.toggleSaved(p.name),
                              child: Container(
                                  width: 44, height: 44,
                                  decoration: const BoxDecoration(color: Color(0x1FC4472E), shape: BoxShape.circle),
                                  child: const Icon(Icons.favorite, color: C.rust)))),
                    ])),
              ),
          ]);
        },
      ));
}
