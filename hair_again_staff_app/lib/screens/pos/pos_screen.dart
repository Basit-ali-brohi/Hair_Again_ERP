import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/staff_data.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  late List<PosItem> _items;
  String _payMethod = 'Cash';
  bool _done = false;
  static const _payMethods = ['Cash', 'Card', 'JazzCash', 'EasyPaisa'];

  @override
  void initState() {
    super.initState();
    _items = staffData.posServices.map((s) => PosItem(
      id: s.id, name: s.name, category: s.category,
      price: s.price, icon: s.icon, color: s.color,
    )).toList();
  }

  double get _total => _items.fold(0, (sum, i) => sum + i.price * i.qty);
  int get _itemCount => _items.fold(0, (sum, i) => sum + i.qty);
  List<PosItem> get _cart => _items.where((i) => i.qty > 0).toList();

  void _checkout() {
    if (_cart.isEmpty) return;
    HapticFeedback.heavyImpact();
    staffData.recordSale(_total);
    setState(() => _done = true);
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() { _done = false; for (final i in _items) { i.qty = 0; } });
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    final fmt = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: p.bg,
      appBar: StaffAppBar(title: 'New Bill'),
      body: _done
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 80, height: 80,
                decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.4), blurRadius: 24)]),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.black87, size: 36)),
              const SizedBox(height: 20),
              Text('Payment Received!', style: p.display(22)),
              const SizedBox(height: 8),
              Text('Rs ${fmt.format(_total.toInt())}', style: p.display(28, color: kGold)),
              const SizedBox(height: 8),
              Text('via $_payMethod', style: p.body(14, color: p.textMuted)),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GoldButton(label: 'New Bill', icon: Icons.add_rounded, onTap: () => setState(() { _done = false; for (final i in _items) { i.qty = 0; } })),
              ),
            ]))
          : Column(children: [
              // Service list
              Expanded(child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                children: [
                  Text('Select Services', style: p.body(13, color: p.textMuted, weight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ..._items.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: p.surface, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: item.qty > 0 ? kGold.withValues(alpha: 0.35) : p.border),
                      boxShadow: [if (item.qty > 0) BoxShadow(color: kGold.withValues(alpha: 0.06), blurRadius: 8)],
                    ),
                    child: Row(children: [
                      Container(width: 42, height: 42,
                        decoration: BoxDecoration(color: item.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                        child: Icon(item.icon, color: item.color, size: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.name, style: p.body(13, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('Rs ${fmt.format(item.price.toInt())}', style: p.body(12, color: kGold, weight: FontWeight.w700)),
                      ])),
                      // Qty stepper
                      Container(
                        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          GestureDetector(
                            onTap: () { if (item.qty > 0) setState(() => item.qty--); },
                            child: Container(width: 32, height: 32,
                              child: Icon(Icons.remove_rounded, size: 16, color: item.qty > 0 ? kDanger : p.textMuted)),
                          ),
                          SizedBox(width: 28, child: Text('${item.qty}', style: p.body(14, weight: FontWeight.w700), textAlign: TextAlign.center)),
                          GestureDetector(
                            onTap: () => setState(() => item.qty++),
                            child: Container(width: 32, height: 32,
                              child: Icon(Icons.add_rounded, size: 16, color: kSuccess)),
                          ),
                        ]),
                      ),
                    ]),
                  )),
                ],
              )),

              // Bill summary + checkout
              if (_itemCount > 0) Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.border))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Cart items
                  ..._cart.map((i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      Text('${i.qty}×', style: p.body(12, color: p.textMuted, weight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(i.name, style: p.body(12), overflow: TextOverflow.ellipsis)),
                      Text('Rs ${NumberFormat('#,###').format((i.price * i.qty).toInt())}', style: p.body(12, weight: FontWeight.w600)),
                    ]),
                  )),
                  Divider(color: p.border),
                  Row(children: [
                    Text('Total', style: p.body(15, weight: FontWeight.w700)),
                    const Spacer(),
                    Text('Rs ${fmt.format(_total.toInt())}', style: p.display(18, color: kGold)),
                  ]),
                  const SizedBox(height: 14),
                  // Payment method
                  Row(children: _payMethods.map((m) {
                    final sel = m == _payMethod;
                    return Expanded(child: GestureDetector(
                      onTap: () => setState(() => _payMethod = m),
                      child: AnimatedContainer(duration: const Duration(milliseconds: 160),
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? kGold.withValues(alpha: 0.12) : p.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: sel ? kGold : p.border),
                        ),
                        child: Text(m, style: p.body(10, color: sel ? kGold : p.textMuted, weight: sel ? FontWeight.w700 : FontWeight.w400), textAlign: TextAlign.center),
                      ),
                    ));
                  }).toList()),
                  const SizedBox(height: 14),
                  GoldButton(label: 'COLLECT Rs ${fmt.format(_total.toInt())}', icon: Icons.payments_rounded, onTap: _checkout),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ]),
              ),
              if (_itemCount == 0)
                SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
                    child: Row(children: [
                      Icon(Icons.shopping_cart_outlined, color: p.textMuted, size: 22),
                      const SizedBox(width: 12),
                      Text('Add services to create a bill', style: p.body(13, color: p.textMuted)),
                    ]),
                  ),
                )),
            ]),
    );
  }
}
