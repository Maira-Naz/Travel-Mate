import 'package:flutter/material.dart';
import '../core.dart';
import '../models/models.dart';
import '../services/trip_store.dart';

/// Track a booking made OUTSIDE Roam (hotel, flight, bus, tour...). Tracking only.
class AddBookingScreen extends StatefulWidget {
  final Booking? booking;
  const AddBookingScreen({super.key, this.booking});
  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  static const kinds = ['Hotel', 'Flight', 'Bus', 'Train', 'Car rental', 'Tour', 'Other'];
  late final title = TextEditingController(text: widget.booking?.title ?? '');
  late final place = TextEditingController(text: widget.booking?.place ?? '');
  late final amount = TextEditingController(text: (widget.booking?.amount ?? 0) > 0 ? '${widget.booking!.amount}' : '');
  late final ref = TextEditingController(text: widget.booking?.reference ?? '');
  late final notes = TextEditingController(text: widget.booking?.notes ?? '');
  late String kind = kinds.contains(widget.booking?.kind) ? widget.booking!.kind : 'Hotel';
  late DateTime? start = widget.booking?.start;
  late DateTime? end = widget.booking?.end;
  Map<String, String> err = {};

  Future<void> _pick(bool isStart) async {
    final d = await pickDate(context, (isStart ? start : end) ?? start ?? dateOnly(DateTime.now()));
    if (d == null) return;
    setState(() {
      if (isStart) {
        start = dateOnly(d);
        if (end != null && end!.isBefore(start!)) end = null;
      } else {
        end = dateOnly(d);
      }
      err.remove('dates');
    });
  }

  void _save() {
    final errs = <String, String>{};
    if (title.text.trim().isEmpty) errs['title'] = 'Give this booking a name';
    if (place.text.trim().isEmpty) errs['place'] = 'Enter the place';
    if (start == null) {
      errs['dates'] = 'Choose the start date';
    } else if (end != null && end!.isBefore(start!)) {
      errs['dates'] = 'The end date must be after the start date';
    }
    final a = amount.text.trim().isEmpty ? 0 : int.tryParse(amount.text.trim());
    if (a == null || a < 0) errs['amount'] = 'Enter a valid amount';
    setState(() => err = errs);
    if (errs.isNotEmpty) return;
    final b = widget.booking;
    if (b == null) {
      TripStore.i.addBooking(Booking(
          id: newId(), source: 'external', kind: kind, title: title.text.trim(), place: place.text.trim(),
          start: start!, end: end, createdAt: DateTime.now(), amount: a!, reference: ref.text.trim(), notes: notes.text.trim()));
    } else {
      b.title = title.text.trim();
      b.kind = kind;
      b.place = place.text.trim();
      b.start = start!;
      b.end = end;
      b.amount = a!;
      b.reference = ref.text.trim();
      b.notes = notes.text.trim();
      TripStore.i.touch(b: true);
    }
    Navigator.pop(context);
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(top: 18, bottom: 8), child: Text(t, style: head(18)));

  @override
  Widget build(BuildContext context) => SubPage(widget.booking == null ? 'Add a booking' : 'Edit booking',
      sub: 'Booked somewhere else? Keep track of it here',
      bottom: SizedBox(width: double.infinity, child: Btn('Save booking', _save)),
      child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
        AppField(title, 'Booking name (e.g. PC Hotel, Skardu)', Icons.confirmation_number_outlined, error: err['title'], action: TextInputAction.next, onChanged: (_) => setState(() => err.remove('title'))),
        _label('Type'),
        ChipRow(kinds, kind, (v) => setState(() => kind = v)),
        const SizedBox(height: 18),
        AppField(place, 'Place / destination', Icons.place_outlined, error: err['place'], action: TextInputAction.next, onChanged: (_) => setState(() => err.remove('place'))),
        _label('Dates'),
        DateTile('Start date', start, () => _pick(true)),
        const SizedBox(height: 10),
        DateTile('End date (optional)', end, () => _pick(false), empty: 'Not set'),
        if (end != null) Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () => setState(() => end = null), child: const Text('Clear end date'))),
        if (err['dates'] != null) Padding(padding: const EdgeInsets.only(top: 6, left: 8), child: Text(err['dates']!, style: body(13, c: C.rust, w: FontWeight.w700))),
        const SizedBox(height: 14),
        AppField(amount, 'Cost in PKR (optional)', Icons.payments_outlined, type: TextInputType.number, error: err['amount'], onChanged: (_) => setState(() => err.remove('amount'))),
        const SizedBox(height: 14),
        AppField(ref, 'Confirmation number (optional)', Icons.tag, action: TextInputAction.next),
        const SizedBox(height: 14),
        AppField(notes, 'Notes (optional)', Icons.notes_outlined, maxLines: 3),
        const SizedBox(height: 16),
      ]));
}
