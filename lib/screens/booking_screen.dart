import 'package:flutter/material.dart';
import '../core.dart';
import '../models/models.dart';
import '../services/trip_store.dart';
import 'booking_detail_screen.dart';

// ---------------- CONFIRM BOOKING (book a trip inside Roam) ----------------
class BookingScreen extends StatefulWidget {
  final Place place;
  const BookingScreen(this.place, {super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const payments = ['Card', 'Mobile wallet', 'Pay later'];
  int pay = 0, travellers = 2;
  DateTime start = dateOnly(DateTime.now()).add(const Duration(days: 14));
  final name = TextEditingController(), phone = TextEditingController();

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _confirm(int total) async {
    if (name.text.trim().length < 2) return _msg('Enter the traveller name');
    if (phone.text.trim().length < 7) return _msg('Enter a valid phone number');
    final b = TripStore.i.bookPlace(widget.place, start, travellers, payments[pay], total);
    final nav = Navigator.of(context);
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              title: const Text('Booking confirmed'),
              content: Text('${widget.place.name}, ${rangeText(start, start.add(const Duration(days: 4)))}.\nReference ${b.reference}. We also created a trip for it in your Trips tab. (Demo only, no payment taken.)'),
              actions: [
                TextButton(onPressed: () { Navigator.pop(ctx); nav.popUntil((r) => r.isFirst); }, child: const Text('Done')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      nav.popUntil((r) => r.isFirst);
                      TabNav.index.value = 2;
                      nav.push(MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: b.id)));
                    },
                    child: const Text('View booking')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final unit = int.parse(widget.place.price.replaceAll(RegExp(r'[^0-9]'), ''));
    final total = unit * travellers;
    final end = start.add(const Duration(days: 4));
    return SubPage('Confirm booking',
        bottom: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total for $travellers', style: body(16)),
            Text(money(total), style: body(22, c: C.forest, w: FontWeight.w800)),
          ]),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: Btn('Confirm and pay', () => _confirm(total))),
        ]),
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
          Box(
              child: Row(children: [
            PlaceThumb(widget.place.colors, size: 66),
            const SizedBox(width: 14),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${widget.place.name}, 5 days', style: body(18, c: C.forest, w: FontWeight.w800)),
              Text(rangeText(start, end), style: body(14)),
              Row(children: [
                Text('$travellers travellers', style: body(14)),
                IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => setState(() => travellers = travellers > 1 ? travellers - 1 : 1)),
                IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => setState(() => travellers++)),
              ]),
            ])),
          ])),
          const SizedBox(height: 14),
          DateTile('Travel start date', start, () async {
            final d = await pickDate(context, start, first: dateOnly(DateTime.now()));
            if (d != null) setState(() => start = dateOnly(d));
          }),
          const SizedBox(height: 22),
          Text('Traveller details', style: head(22)),
          const SizedBox(height: 10),
          AppField(name, 'Full name', Icons.badge_outlined, action: TextInputAction.next),
          const SizedBox(height: 14),
          AppField(phone, 'Phone (+92...)', Icons.phone_outlined, type: TextInputType.phone),
          const SizedBox(height: 22),
          Text('Payment', style: head(22)),
          const SizedBox(height: 10),
          Row(children: [
            for (var i = 0; i < payments.length; i++)
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tap(
                  radius: 22,
                  onTap: () => setState(() => pay = i),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(color: pay == i ? C.forest : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: C.line)),
                      child: Center(child: Text(payments[i], style: body(14, c: pay == i ? C.cream : C.forest, w: pay == i ? FontWeight.w800 : FontWeight.w400)))),
                ),
              )),
          ]),
          const SizedBox(height: 16),
        ]));
  }
}
