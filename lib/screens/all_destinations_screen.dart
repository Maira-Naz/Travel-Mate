import 'package:flutter/material.dart';
import '../core.dart';
import '../services/app_state.dart';
import 'destination_screen.dart';

/// Gradient destination card (used on Home and in See all).
class DestinationCard extends StatelessWidget {
  final Place place;
  final double? width;
  final double height;
  const DestinationCard(this.place, {super.key, this.width, this.height = 260});
  @override
  Widget build(BuildContext context) => Tap(
        radius: 28,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DestinationScreen(place))),
        child: Container(
          width: width, height: height,
          padding: const EdgeInsets.all(20),
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: place.colors)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(place.name, style: head(26, c: C.cream)),
            Text(place.region, style: body(14, c: const Color(0xFFE3E8E0))),
            const SizedBox(height: 10),
            Text('From ${place.price}', style: body(16, c: C.cream, w: FontWeight.w600)),
          ]),
        ),
      );
}

class AllDestinationsScreen extends StatefulWidget {
  const AllDestinationsScreen({super.key});
  @override
  State<AllDestinationsScreen> createState() => _AllDestinationsScreenState();
}

class _AllDestinationsScreenState extends State<AllDestinationsScreen> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final list = places.where((p) => '${p.name} ${p.region}'.toLowerCase().contains(q.toLowerCase())).toList();
    return SubPage('All destinations',
        sub: '${places.length} places to explore',
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
          TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: InputDecoration(
              hintText: 'Search destinations', prefixIcon: const Icon(Icons.search, color: C.sage),
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: const BorderSide(color: C.line)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: const BorderSide(color: C.line)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: const BorderSide(color: C.forest, width: 1.4)),
            ),
          ),
          const SizedBox(height: 16),
          if (list.isEmpty) Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('No places match "$q"', style: body(16)))),
          for (final p in list)
            Padding(padding: const EdgeInsets.only(bottom: 14), child: DestinationCard(p, height: 170)),
        ]));
  }
}
