import 'package:flutter/material.dart';
import '../core.dart';

// ---------------- CONFIRM BOOKING ----------------
class BookingScreen extends StatefulWidget {
  final Place place;
  const BookingScreen(this.place, {super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int pay = 0;
  int travellers = 2;
  final name = TextEditingController();
  final phone = TextEditingController();

  InputDecoration _dec(String hint) => InputDecoration(
      hintText: hint, filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: const BorderSide(color: C.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: const BorderSide(color: C.line)));

  @override
  Widget build(BuildContext context) {
    final unit = int.parse(widget.place.price.replaceAll(RegExp(r'[^0-9]'), ''));
    final total = unit * travellers;
    String fmt(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return SubPage('Confirm booking',
        bottom: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total for $travellers', style: body(16)),
            Text('PKR ${fmt(total)}', style: body(22, c: C.forest, w: FontWeight.w800)),
          ]),
          const SizedBox(height: 10),
          SizedBox(
              width: double.infinity,
              child: Btn('Confirm and pay', () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: const Text('Booking confirmed'),
                          content: Text('${widget.place.name} for $travellers travellers. (Demo only, no payment taken.)'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                                child: const Text('Done'))
                          ],
                        ));
              })),
        ]),
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
          Box(
              child: Row(children: [
            const PlaceThumb([Color(0xFF6E927F), Color(0xFF2F4A43)], size: 66),
            const SizedBox(width: 14),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${widget.place.name.split(' ').first} Valley, 5 days',
                  style: body(18, c: C.forest, w: FontWeight.w800)),
              Text('12 Nov to 16 Nov', style: body(14)),
              Row(children: [
                Text('$travellers travellers', style: body(14)),
                IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: () => setState(() => travellers = travellers > 1 ? travellers - 1 : 1)),
                IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.add_circle_outline, size: 20),
                    onPressed: () => setState(() => travellers++)),
              ]),
            ])),
          ])),
          const SizedBox(height: 22),
          Text('Traveller details', style: head(22)),
          const SizedBox(height: 10),
          Text('Full name', style: body(14)),
          const SizedBox(height: 6),
          TextField(controller: name, decoration: _dec('Your name')),
          const SizedBox(height: 14),
          Text('Phone', style: body(14)),
          const SizedBox(height: 6),
          TextField(controller: phone, keyboardType: TextInputType.phone, decoration: _dec('+92')),
          const SizedBox(height: 22),
          Text('Payment', style: head(22)),
          const SizedBox(height: 10),
          Row(children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => pay = i),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                          color: pay == i ? C.forest : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: C.line)),
                      child: Center(
                          child: Text(['Card', 'Mobile wallet', 'Pay later'][i],
                              style: body(14, c: pay == i ? C.cream : C.forest,
                                  w: pay == i ? FontWeight.w800 : FontWeight.w400)))),
                ),
              )),
          ]),
        ]));
  }
}
