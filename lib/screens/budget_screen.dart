import 'package:flutter/material.dart';
import '../core.dart';

// ---------------- BUDGET ----------------
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  static const total = 120000;
  final cats = {'Stay': [32000, 40000], 'Transport': [24000, 35000], 'Food': [12500, 25000], 'Activities': [6000, 20000]};
  String f(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  int get spent => cats.values.fold(0, (a, b) => a + b[0]);

  Future<void> _add() async {
    final amt = TextEditingController();
    String cat = cats.keys.first;
    final ok = await showDialog<bool>(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (ctx, set) => AlertDialog(
                  title: const Text('Add expense'),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    DropdownButton<String>(
                        value: cat, isExpanded: true,
                        items: [for (final k in cats.keys) DropdownMenuItem(value: k, child: Text(k))],
                        onChanged: (v) => set(() => cat = v!)),
                    TextField(controller: amt, keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Amount (PKR)')),
                  ]),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
                  ],
                )));
    final v = int.tryParse(amt.text);
    if (ok == true && v != null) setState(() => cats[cat]![0] += v);
  }

  @override
  Widget build(BuildContext context) => SubPage('Budget plan',
      bottom: SizedBox(width: double.infinity, child: Btn('Add expense', _add, icon: Icons.add)),
      child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: C.forest, borderRadius: BorderRadius.circular(30)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hunza trip, 5 days', style: body(15, c: const Color(0xFFD5DDD6))),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('PKR ${f(spent)}', style: head(38, c: C.cream)),
              const SizedBox(width: 8),
              Padding(padding: const EdgeInsets.only(bottom: 6),
                  child: Text('of ${f(total)}', style: body(16, c: const Color(0xFFD5DDD6)))),
            ]),
            const SizedBox(height: 12),
            Bar(spent / total, color: C.sky, track: const Color(0xFF586F66)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${(spent * 100 / total).round()}% spent', style: body(15, c: C.cream)),
              Text('PKR ${f(total - spent)} left', style: body(15, c: C.cream, w: FontWeight.w800)),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        Text('By category', style: head(22)),
        const SizedBox(height: 10),
        for (final e in cats.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Box(
                child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(e.key, style: body(17, c: C.forest, w: FontWeight.w800)),
                Text('PKR ${f(e.value[0])} / ${f(e.value[1])}', style: body(15)),
              ]),
              const SizedBox(height: 10),
              Bar(e.value[0] / e.value[1], color: e.value[0] > e.value[1] ? C.rust : C.sage),
            ])),
          ),
      ]));
}
