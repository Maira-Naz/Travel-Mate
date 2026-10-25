import 'package:flutter/material.dart';
import '../core.dart';
import '../services/place_service.dart';
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

/// Search all places. Unknown place? We save a request and tell the user we will find it.
class AllDestinationsScreen extends StatefulWidget {
  const AllDestinationsScreen({super.key});
  @override
  State<AllDestinationsScreen> createState() => _AllDestinationsScreenState();
}

class _AllDestinationsScreenState extends State<AllDestinationsScreen> {
  String q = '';

  @override
  void initState() {
    super.initState();
    PlaceService.refreshRemote(); // pick up places added to the cloud database
  }

  Widget _notFound() => ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: PlaceService.requests,
        builder: (_, __, ___) {
          final asked = PlaceService.isRequested(q);
          return Box(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(asked ? Icons.mark_email_read_outlined : Icons.travel_explore, color: C.sage, size: 30),
                  const SizedBox(width: 12),
                  Expanded(child: Text(asked ? 'Request sent' : 'No details for "${q.trim()}" yet', style: head(20))),
                ]),
                const SizedBox(height: 8),
                Text(
                    asked
                        ? "We're finding the details for this place. We'll notify you in Notifications as soon as they are ready."
                        : "We'll find the details for this place and notify you when they are ready. Want us to look for it?",
                    style: body(15)),
                if (!asked) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                      width: double.infinity,
                      child: Btn('Request details', () async {
                        await PlaceService.request(q);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request sent. We'll notify you when it's ready.")));
                        }
                      }, icon: Icons.send_outlined)),
                ],
              ]));
        },
      );

  @override
  Widget build(BuildContext context) => SubPage('All destinations',
      sub: 'Search any place in Pakistan',
      child: ValueListenableBuilder<List<Place>>(
        valueListenable: PlaceService.remote,
        builder: (_, __, ___) {
          final list = PlaceService.all.where((p) => '${p.name} ${p.region}'.toLowerCase().contains(q.trim().toLowerCase())).toList();
          return ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
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
            if (list.isEmpty && q.trim().length >= 2) _notFound(),
            if (list.isEmpty && q.trim().length < 2) Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Type at least 2 letters', style: body(15)))),
            for (final p in list) Padding(padding: const EdgeInsets.only(bottom: 14), child: DestinationCard(p, height: 170)),
            const SizedBox(height: 16),
          ]);
        },
      ));
}
