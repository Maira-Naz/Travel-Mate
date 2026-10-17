import 'package:flutter/material.dart';
import '../core.dart';
import '../services/storage.dart';

// ---------------- BUDGET (add / edit / delete expenses) ----------------
class Expense {
  String name, cat;
  int amount;
  Expense(this.name, this.cat, this.amount);
  Map<String, dynamic> toJson() => {'n': name, 'c': cat, 'a': amount};
  factory Expense.fromJson(Map<String, dynamic> j) => Expense(j['n'], j['c'], j['a']);
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  static const total = 120000;
  static const limits = {'Stay': 40000, 'Transport': 35000, 'Food': 25000, 'Activities': 20000};
  final expenses = <Expense>[
    Expense('Hotel booking', 'Stay', 32000),
    Expense('Car rental', 'Transport', 18000),
    Expense('Fuel', 'Transport', 6000),
    Expense('Meals', 'Food', 12500),
    Expense('Fort tour and boating', 'Activities', 6000),
  ];

  @override
  void initState() {
    super.initState();
    final saved = Store.getJson('expenses');
    if (saved != null) {
      expenses
        ..clear()
        ..addAll((saved as List).map((e) => Expense.fromJson(Map<String, dynamic>.from(e))));
    }
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    Store.setJson('expenses', expenses.map((e) => e.toJson()).toList());
  }

  String f(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  int get spent => expenses.fold(0, (a, e) => a + e.amount);
  int catSpent(String c) => expenses.where((e) => e.cat == c).fold(0, (a, e) => a + e.amount);

  Future<void> _editor([Expense? e]) async {
    final name = TextEditingController(text: e?.name ?? '');
    final amt = TextEditingController(text: e == null ? '' : '${e.amount}');
    String cat = e?.cat ?? limits.keys.first;
    String? err;
    final ok = await showDialog<bool>(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (ctx, set) => AlertDialog(
                  title: Text(e == null ? 'Add expense' : 'Edit expense'),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
                    TextField(controller: amt, keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Amount (PKR)')),
                    const SizedBox(height: 12),
                    DropdownButton<String>(
                        value: cat, isExpanded: true,
                        items: [for (final k in limits.keys) DropdownMenuItem(value: k, child: Text(k))],
                        onChanged: (v) => set(() => cat = v!)),
                    if (err != null) Text(err!, style: const TextStyle(color: C.rust)),
                  ]),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          final v = int.tryParse(amt.text.trim());
                          if (name.text.trim().isEmpty || v == null || v <= 0) {
                            set(() => err = 'Enter a name and a valid amount');
                          } else {
                            Navigator.pop(ctx, true);
                          }
                        },
                        child: Text(e == null ? 'Add' : 'Save')),
                  ],
                )));
    if (ok == true) {
      setState(() {
        final v = int.parse(amt.text.trim());
        if (e == null) {
          expenses.add(Expense(name.text.trim(), cat, v));
        } else {
          e.name = name.text.trim();
          e.amount = v;
          e.cat = cat;
        }
      });
    }
  }

  void _delete(Expense e) {
    final i = expenses.indexOf(e);
    setState(() => expenses.remove(e));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
          content: Text('Deleted "${e.name}"'),
          action: SnackBarAction(label: 'Undo', onPressed: () => setState(() => expenses.insert(i.clamp(0, expenses.length), e)))));
  }

  @override
  Widget build(BuildContext context) => SubPage('Budget plan',
      bottom: SizedBox(width: double.infinity, child: Btn('Add expense', () => _editor(), icon: Icons.add)),
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
            Bar(spent / total, color: spent > total ? C.rust : C.sky, track: const Color(0xFF586F66)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${(spent * 100 / total).round()}% spent', style: body(15, c: C.cream)),
              Text(spent > total ? 'PKR ${f(spent - total)} over' : 'PKR ${f(total - spent)} left',
                  style: body(15, c: C.cream, w: FontWeight.w800)),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        Text('By category', style: head(22)),
        const SizedBox(height: 10),
        for (final k in limits.keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Box(
                child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(k, style: body(17, c: C.forest, w: FontWeight.w800)),
                Text('PKR ${f(catSpent(k))} / ${f(limits[k]!)}', style: body(15)),
              ]),
              const SizedBox(height: 10),
              Bar(catSpent(k) / limits[k]!, color: catSpent(k) > limits[k]! ? C.rust : C.sage),
            ])),
          ),
        const SizedBox(height: 12),
        Text('Expenses', style: head(22)),
        const SizedBox(height: 10),
        if (expenses.isEmpty) Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('No expenses yet. Tap Add expense.', style: body(15)))),
        for (final e in expenses)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Box(
                onTap: () => _editor(e),
                padding: const EdgeInsets.fromLTRB(18, 10, 12, 10),
                child: Row(children: [
                  Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.name, style: body(16, c: C.forest, w: FontWeight.w800)),
                    Text('${e.cat}  ·  PKR ${f(e.amount)}', style: body(14, c: C.forest, w: FontWeight.w700)),
                  ])),
                  EditDelete(
                      onEdit: () => _editor(e),
                      onDelete: () async {
                        if (await confirmDelete(context, e.name)) _delete(e);
                      }),
                ])),
          ),
        const SizedBox(height: 12),
      ]));
}
