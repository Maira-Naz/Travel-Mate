import 'package:flutter/material.dart';
import '../core.dart';
import '../models/models.dart';
import '../services/trip_store.dart';

/// Create or edit a trip (university trip, family trip, anything).
class AddTripScreen extends StatefulWidget {
  final Trip? trip;
  const AddTripScreen({super.key, this.trip});
  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  static const types = ['Family', 'University', 'Friends', 'Solo', 'Work', 'Other'];
  late final name = TextEditingController(text: widget.trip?.name ?? '');
  late final dest = TextEditingController(text: widget.trip?.destination ?? '');
  late final budget = TextEditingController(text: (widget.trip?.budget ?? 0) > 0 ? '${widget.trip!.budget}' : '');
  late final notes = TextEditingController(text: widget.trip?.notes ?? '');
  late String type = types.contains(widget.trip?.type) ? widget.trip!.type : 'Family';
  late DateTime? start = widget.trip?.start;
  late DateTime? end = widget.trip?.end;
  late int travellers = widget.trip?.travellers ?? 1;
  Map<String, String> err = {};

  Future<void> _pick(bool isStart) async {
    final base = (isStart ? start : end) ?? start ?? dateOnly(DateTime.now());
    final d = await pickDate(context, base);
    if (d == null) return;
    setState(() {
      if (isStart) {
        start = dateOnly(d);
        if (end != null && end!.isBefore(start!)) end = start;
      } else {
        end = dateOnly(d);
      }
      err.remove('dates');
    });
  }

  void _save() {
    final errs = <String, String>{};
    if (name.text.trim().isEmpty) errs['name'] = 'Give your trip a name';
    if (dest.text.trim().isEmpty) errs['dest'] = 'Where are you going?';
    if (start == null || end == null) {
      errs['dates'] = 'Choose the start and end dates';
    } else if (end!.isBefore(start!)) {
      errs['dates'] = 'The end date must be after the start date';
    } else if (daysBetween(start!, end!) > 120) {
      errs['dates'] = 'Trips can be up to 120 days long';
    }
    final b = budget.text.trim().isEmpty ? 0 : int.tryParse(budget.text.trim());
    if (b == null || b < 0) errs['budget'] = 'Enter a valid amount';
    setState(() => err = errs);
    if (errs.isNotEmpty) return;
    final t = widget.trip;
    if (t == null) {
      TripStore.i.addTrip(Trip(
          id: newId(), name: name.text.trim(), destination: dest.text.trim(), type: type,
          start: start!, end: end!, travellers: travellers, budget: b!, notes: notes.text.trim()));
    } else {
      t.name = name.text.trim();
      t.destination = dest.text.trim();
      t.type = type;
      t.start = start!;
      t.end = end!;
      t.travellers = travellers;
      t.budget = b!;
      t.notes = notes.text.trim();
      TripStore.i.updateTrip(t);
    }
    Navigator.pop(context);
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(top: 18, bottom: 8), child: Text(t, style: head(18)));

  @override
  Widget build(BuildContext context) => SubPage(widget.trip == null ? 'Add a trip' : 'Edit trip',
      sub: 'Track the days, expenses and places',
      bottom: SizedBox(width: double.infinity, child: Btn('Save trip', _save)),
      child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
        AppField(name, 'Trip name (e.g. Class trip to Murree)', Icons.flag_outlined, error: err['name'], action: TextInputAction.next, onChanged: (_) => setState(() => err.remove('name'))),
        const SizedBox(height: 14),
        AppField(dest, 'Destination', Icons.place_outlined, error: err['dest'], action: TextInputAction.next, onChanged: (_) => setState(() => err.remove('dest'))),
        _label('Trip type'),
        ChipRow(types, type, (v) => setState(() => type = v)),
        _label('Dates'),
        DateTile('Start date', start, () => _pick(true)),
        const SizedBox(height: 10),
        DateTile('End date', end, () => _pick(false)),
        if (err['dates'] != null) Padding(padding: const EdgeInsets.only(top: 8, left: 8), child: Text(err['dates']!, style: body(13, c: C.rust, w: FontWeight.w700))),
        _label('Travellers'),
        Box(
            radius: 22, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(children: [
              const Icon(Icons.group_outlined, color: C.sage),
              const SizedBox(width: 12),
              Expanded(child: Text('$travellers ${travellers == 1 ? 'person' : 'people'}', style: body(16, c: C.forest, w: FontWeight.w700))),
              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() => travellers = travellers > 1 ? travellers - 1 : 1)),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => travellers++)),
            ])),
        _label('Budget (optional)'),
        AppField(budget, 'Total budget in PKR', Icons.account_balance_wallet_outlined, type: TextInputType.number, error: err['budget'], onChanged: (_) => setState(() => err.remove('budget'))),
        const SizedBox(height: 14),
        AppField(notes, 'Notes (optional)', Icons.notes_outlined, maxLines: 3),
        const SizedBox(height: 16),
      ]));
}
