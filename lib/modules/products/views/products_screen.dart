import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/product_models.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 5, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenScaffold(
      title: 'PRODUCTS & CATALOGUE',
      subtitle: 'Product categories, brands, catalogue management & pricing',
      actions: [
        Container(height: 42,
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
          child: TabBar(controller: _tab, isScrollable: true, dividerColor: Colors.transparent,
            indicatorColor: p.gold, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: p.body(12.5, weight: FontWeight.w600), unselectedLabelStyle: p.body(12.5),
            labelColor: p.gold, unselectedLabelColor: p.textMuted, tabAlignment: TabAlignment.start,
            tabs: const [Tab(text: 'Products'), Tab(text: 'Categories'), Tab(text: 'Brands'), Tab(text: 'Pricing'), Tab(text: 'Images')]),
        ),
      ],
      child: EagerTabBarView(controller: _tab, children: const [
        _ProductsTab(), _CategoriesTab(), _BrandsTab(), _PricingTab(), _ImagesTab(),
      ]),
    );
  }
}

// ── Products ─────────────────────────────────────────────────────────────────
class _ProductsTab extends StatefulWidget {
  const _ProductsTab();
  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  String _q = '';
  String? _catFilter;
  bool? _lowStockFilter;

  void _showDetail(Product pr) {
    final p = appState.palette;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 620, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 52, height: 52, alignment: Alignment.center,
              decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.inventory_outlined, size: 26, color: p.gold)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pr.name, style: p.display(20)),
              Text('${pr.categoryName} · ${pr.brandName} · SKU: ${pr.sku}', style: p.body(12.5, color: p.textMuted)),
            ])),
            if (pr.isLowStock) StatusChip(label: 'Low Stock', color: p.danger),
            const SizedBox(width: 8),
            StatusChip(label: pr.isActive ? 'Active' : 'Inactive', color: pr.isActive ? p.success : p.textMuted),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => Navigator.pop(ctx), child: MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.close, size: 20, color: p.textMuted))),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PRICING', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)), const SizedBox(height: 10),
              _kv(p, 'Cost Price', money(pr.costPrice)), _kv(p, 'Selling Price', money(pr.sellingPrice)),
              _kv(p, 'Margin', '${pr.marginPct.toStringAsFixed(1)}%'), _kv(p, 'Unit', pr.unit),
            ]))),
            const SizedBox(width: 12),
            Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('STOCK', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)), const SizedBox(height: 10),
              _kv(p, 'In Stock', '${pr.stockQty}'), _kv(p, 'Reorder Level', '${pr.reorderLevel}'),
              _kv(p, 'Variants', '${pr.variants.length}'),
              _kv(p, 'Stock Value', money(pr.stockQty * pr.sellingPrice)),
            ]))),
          ]),
          if (pr.description.isNotEmpty) ...[const SizedBox(height: 14), Text('DESCRIPTION', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)), const SizedBox(height: 6), Text(pr.description, style: p.body(13))],
          if (pr.variants.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('VARIANTS (${pr.variants.length})', style: p.body(11, weight: FontWeight.w700, spacing: 1.0, color: p.textMuted)),
            const SizedBox(height: 10),
            ...pr.variants.map((v) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
              Expanded(child: Text(v.name, style: p.body(12.5, weight: FontWeight.w500))),
              Text('SKU: ${v.sku}', style: p.body(11.5, color: p.textMuted)), const SizedBox(width: 12),
              Text(money(v.sellingPrice), style: p.body(12.5, weight: FontWeight.w600)), const SizedBox(width: 12),
              Text('Qty: ${v.stockQty}', style: p.body(12, color: v.stockQty <= 0 ? p.danger : p.success)),
            ]))),
          ],
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [GhostButton(label: 'Close', onTap: () => Navigator.pop(ctx))]),
        ])),
      ),
    )));
  }

  Widget _kv(AppPalette p, String k, String v) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(child: Text(k, style: p.body(12, color: p.textMuted))), Text(v, style: p.body(12.5, weight: FontWeight.w600))]));

  void _showAddProduct() {
    final p = appState.palette;
    final nameCtrl = TextEditingController(); final skuCtrl = TextEditingController(); final descCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'pcs');
    String? catId; String? brandId;
    double cost = 0; double selling = 0; int stock = 0; int reorder = 5;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 560, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ADD PRODUCT', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          Row(children: [Expanded(child: FormField2(label: 'Product Name *', controller: nameCtrl, hint: 'e.g. PRP Serum')), const SizedBox(width: 14), SizedBox(width: 140, child: FormField2(label: 'SKU', controller: skuCtrl, hint: 'e.g. PRP-001'))]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Dropdown2<String?>(label: 'Category', value: catId, items: appState.productCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (v) => ss(() => catId = v))),
            const SizedBox(width: 14),
            Expanded(child: Dropdown2<String?>(label: 'Brand', value: brandId, items: appState.brands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(), onChanged: (v) => ss(() => brandId = v))),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Cost Price (PKR)', controller: TextEditingController(), hint: '0', keyboard: TextInputType.number, onChanged: (v) => cost = double.tryParse(v) ?? 0)),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Selling Price (PKR)', controller: TextEditingController(), hint: '0', keyboard: TextInputType.number, onChanged: (v) => selling = double.tryParse(v) ?? 0)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FormField2(label: 'Initial Stock', controller: TextEditingController(), hint: '0', keyboard: TextInputType.number, onChanged: (v) => stock = int.tryParse(v) ?? 0)),
            const SizedBox(width: 14),
            Expanded(child: FormField2(label: 'Reorder Level', controller: TextEditingController(text: '5'), hint: '5', keyboard: TextInputType.number, onChanged: (v) => reorder = int.tryParse(v) ?? 5)),
            const SizedBox(width: 14),
            SizedBox(width: 80, child: FormField2(label: 'Unit', controller: unitCtrl, hint: 'pcs')),
          ]),
          const SizedBox(height: 14),
          FormField2(label: 'Description', controller: descCtrl, hint: 'Product details…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: 'Add Product', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              final cat = appState.productCategories.where((c) => c.id == catId).firstOrNull;
              final brand = appState.brands.where((b) => b.id == brandId).firstOrNull;
              appState.addProduct(Product(
                id: appState.createProductId(), name: nameCtrl.text, sku: skuCtrl.text,
                categoryId: catId ?? '', categoryName: cat?.name ?? '', brandId: brandId ?? '',
                brandName: brand?.name ?? '', description: descCtrl.text, unit: unitCtrl.text,
                costPrice: cost, sellingPrice: selling, stockQty: stock, reorderLevel: reorder, variants: [],
              ));
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ])),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var list = appState.products;
    if (_q.isNotEmpty) list = list.where((pr) => pr.name.toLowerCase().contains(_q.toLowerCase()) || pr.sku.toLowerCase().contains(_q.toLowerCase())).toList();
    if (_catFilter != null) list = list.where((pr) => pr.categoryId == _catFilter).toList();
    if (_lowStockFilter == true) list = list.where((pr) => pr.isLowStock).toList();

    final lowStockCount = appState.products.where((pr) => pr.isLowStock).length;

    return Column(children: [
      Row(children: [
        MetricCard(title: 'Total Products', value: '${appState.products.length}', icon: Icons.inventory_outlined, delta: ''),
        const SizedBox(width: 14),
        MetricCard(title: 'Low Stock', value: '$lowStockCount', icon: Icons.warning_amber_outlined, delta: lowStockCount > 0 ? 'attention' : '', deltaUp: false),
        const SizedBox(width: 14),
        MetricCard(title: 'Categories', value: '${appState.productCategories.length}', icon: Icons.category_outlined, delta: ''),
      ]),
      const SizedBox(height: 16),
      Panel(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          FilterDropdown<String?>(value: _catFilter,
            items: [const DropdownMenuItem(value: null, child: Text('All Categories')), ...appState.productCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))],
            onChanged: (v) => setState(() => _catFilter = v)),
          const SizedBox(width: 10),
          FilterDropdown<bool?>(value: _lowStockFilter,
            items: const [DropdownMenuItem(value: null, child: Text('All Stock')), DropdownMenuItem(value: true, child: Text('Low Stock Only')), DropdownMenuItem(value: false, child: Text('In Stock'))],
            onChanged: (v) => setState(() => _lowStockFilter = v)),
          const Spacer(),
          Text('${list.length} products', style: p.body(12, color: p.textMuted, weight: FontWeight.w500)),
          const SizedBox(width: 8),
          GhostButton(label: 'Clear', icon: Icons.refresh, onTap: () => setState(() { _q = ''; _catFilter = null; _lowStockFilter = null; })),
          const SizedBox(width: 10),
          GoldButton(label: 'Add Product', icon: Icons.add, onTap: _showAddProduct),
        ]),
        const SizedBox(height: 10),
        SearchBox(hint: 'Search products by name or SKU…', onChanged: (v) => setState(() => _q = v)),
      ])),
      const SizedBox(height: 12),
      Expanded(child: list.isEmpty
        ? Center(child: Text('No products found.', style: p.body(13, color: p.textMuted)))
        : Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
            headingRowColor: WidgetStateProperty.all(p.surfaceAlt), columnSpacing: 20, horizontalMargin: 20,
            columns: ['Product', 'Category', 'SKU', 'Cost', 'Price', 'Margin', 'Stock', 'Status'].map((t) => DataColumn(label: Text(t, style: p.body(12, weight: FontWeight.w700)))).toList(),
            rows: list.map((pr) => DataRow(
              onSelectChanged: (_) => _showDetail(pr),
              color: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.hovered) ? p.surfaceAlt : Colors.transparent),
              cells: [
                DataCell(Text(pr.name, style: p.body(13, weight: FontWeight.w600))),
                DataCell(Text(pr.categoryName, style: p.body(12.5))),
                DataCell(Text(pr.sku, style: p.body(12, color: p.textMuted))),
                DataCell(Text(money(pr.costPrice), style: p.body(12.5))),
                DataCell(Text(money(pr.sellingPrice), style: p.body(12.5))),
                DataCell(Text('${pr.marginPct.toStringAsFixed(1)}%', style: p.body(12.5, color: pr.marginPct > 30 ? p.success : p.warning))),
                DataCell(Text('${pr.stockQty}', style: p.body(12.5, weight: FontWeight.w600, color: pr.isLowStock ? p.danger : p.text))),
                DataCell(StatusChip(label: pr.isActive ? 'Active' : 'Inactive', color: pr.isActive ? p.success : p.textMuted)),
              ],
            )).toList(),
          )))))),
    ]);
  }
}

// ── Categories ────────────────────────────────────────────────────────────────
class _CategoriesTab extends StatefulWidget {
  const _CategoriesTab();
  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab> {
  void _showForm({ProductCategory? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 440, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT CATEGORY' : 'ADD CATEGORY', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Category Name *', controller: nameCtrl, hint: 'e.g. Hair Care'),
          const SizedBox(height: 14),
          FormField2(label: 'Description', controller: descCtrl, hint: 'What products are in this category?', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Add Category', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              if (editing) { existing!.name = nameCtrl.text; existing.description = descCtrl.text; appState.touch(); }
              else { appState.addProductCategory(ProductCategory(id: appState.createCategoryId(), name: nameCtrl.text, description: descCtrl.text)); }
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final cats = appState.productCategories;
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'Add Category', icon: Icons.add, onTap: () => _showForm())]),
      const SizedBox(height: 12),
      Expanded(child: cats.isEmpty
        ? Center(child: Text('No categories yet.', style: p.body(13, color: p.textMuted)))
        : ScrollArea(builder: (sc) => GridView.builder(
            controller: sc, padding: const EdgeInsets.only(right: 12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300, mainAxisExtent: 160, crossAxisSpacing: 14, mainAxisSpacing: 14),
            itemCount: cats.length,
            itemBuilder: (_, i) {
              final c = cats[i];
              return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 38, height: 38, alignment: Alignment.center,
                    decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.category_outlined, size: 18, color: p.gold)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(c.name, style: p.body(14, weight: FontWeight.w700))),
                ]),
                const SizedBox(height: 8),
                if (c.description.isNotEmpty) Text(c.description, style: p.body(12, color: p.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Row(children: [
                  Text('${appState.products.where((pr) => pr.categoryId == c.id).length} products', style: p.body(12, color: p.textMuted)),
                  const Spacer(),
                  _sqBtn(p, Icons.edit_outlined, p.text, () => _showForm(existing: c)),
                ]),
              ]));
            },
          ))),
    ]);
  }
  Widget _sqBtn(AppPalette p, IconData ic, Color c, VoidCallback fn) => GestureDetector(onTap: fn, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 28, height: 28, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(7)), child: Icon(ic, size: 14, color: c))));
}

// ── Brands ───────────────────────────────────────────────────────────────────
class _BrandsTab extends StatefulWidget {
  const _BrandsTab();
  @override
  State<_BrandsTab> createState() => _BrandsTabState();
}

class _BrandsTabState extends State<_BrandsTab> {
  void _showForm({Brand? existing}) {
    final editing = existing != null;
    final p = appState.palette;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final originCtrl = TextEditingController(text: existing?.origin ?? 'Pakistan');
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 440, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editing ? 'EDIT BRAND' : 'ADD BRAND', style: p.display(22, spacing: 1.0)),
          const SizedBox(height: 20),
          FormField2(label: 'Brand Name *', controller: nameCtrl, hint: 'e.g. Kérastase'),
          const SizedBox(height: 14),
          FormField2(label: 'Country of Origin', controller: originCtrl, hint: 'e.g. France'),
          const SizedBox(height: 14),
          FormField2(label: 'Description', controller: descCtrl, hint: 'About the brand…', maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GhostButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            const SizedBox(width: 12),
            GoldButton(label: editing ? 'Save Changes' : 'Add Brand', onTap: () {
              if (nameCtrl.text.isEmpty) return;
              if (editing) { existing!.name = nameCtrl.text; existing.description = descCtrl.text; existing.origin = originCtrl.text; appState.touch(); }
              else { appState.addBrand(Brand(id: appState.createBrandId(), name: nameCtrl.text, description: descCtrl.text, origin: originCtrl.text)); }
              Navigator.pop(ctx); setState(() {});
            }),
          ]),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final brands = appState.brands;
    return Column(children: [
      Row(children: [const Spacer(), GoldButton(label: 'Add Brand', icon: Icons.add, onTap: () => _showForm())]),
      const SizedBox(height: 12),
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
        headingRowColor: WidgetStateProperty.all(p.surfaceAlt), columnSpacing: 20, horizontalMargin: 20,
        columns: ['Brand', 'Origin', 'Products', 'Status', 'Action'].map((t) => DataColumn(label: Text(t, style: p.body(12, weight: FontWeight.w700)))).toList(),
        rows: brands.map((b) => DataRow(cells: [
          DataCell(Text(b.name, style: p.body(13, weight: FontWeight.w600))),
          DataCell(Text(b.origin, style: p.body(12.5))),
          DataCell(Text('${appState.products.where((pr) => pr.brandId == b.id).length}', style: p.body(12.5))),
          DataCell(StatusChip(label: b.isActive ? 'Active' : 'Inactive', color: b.isActive ? p.success : p.textMuted)),
          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
            _sqBtn(p, Icons.edit_outlined, p.text, () => _showForm(existing: b)),
            const SizedBox(width: 6),
            _sqBtn(p, b.isActive ? Icons.toggle_on_outlined : Icons.toggle_off_outlined, b.isActive ? p.success : p.textMuted, () { b.isActive = !b.isActive; appState.touch(); setState(() {}); }),
          ])),
        ])).toList(),
      )))))),
    ]);
  }
  Widget _sqBtn(AppPalette p, IconData ic, Color c, VoidCallback fn) => GestureDetector(onTap: fn, child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(8)), child: Icon(ic, size: 15, color: c))));
}

// ── Pricing ──────────────────────────────────────────────────────────────────
class _PricingTab extends StatefulWidget {
  const _PricingTab();
  @override
  State<_PricingTab> createState() => _PricingTabState();
}

class _PricingTabState extends State<_PricingTab> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    var list = appState.products.where((pr) => pr.isActive).toList();
    if (_q.isNotEmpty) list = list.where((pr) => pr.name.toLowerCase().contains(_q.toLowerCase())).toList();

    return Column(children: [
      FilterBar(searchHint: 'Filter products by name…', onSearch: (v) => setState(() => _q = v),
        filters: [], countText: '${list.length} products', onClear: () => setState(() => _q = '')),
      const SizedBox(height: 12),
      Expanded(child: Panel(padding: EdgeInsets.zero, child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, child: FullWidthDataTable(child: DataTable(
        headingRowColor: WidgetStateProperty.all(p.surfaceAlt), columnSpacing: 20, horizontalMargin: 20,
        columns: ['Product', 'Cost (PKR)', 'Selling (PKR)', 'Margin %', 'Stock Value'].map((t) => DataColumn(label: Text(t, style: p.body(12, weight: FontWeight.w700)))).toList(),
        rows: list.map((pr) => DataRow(cells: [
          DataCell(Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pr.name, style: p.body(13, weight: FontWeight.w600)),
            Text(pr.categoryName, style: p.body(11, color: p.textMuted)),
          ])),
          DataCell(Text(money(pr.costPrice), style: p.body(12.5))),
          DataCell(Text(money(pr.sellingPrice), style: p.body(12.5, weight: FontWeight.w600, color: p.gold))),
          DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: (pr.marginPct > 30 ? p.success : p.warning).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Text('${pr.marginPct.toStringAsFixed(1)}%', style: p.body(12.5, weight: FontWeight.w700, color: pr.marginPct > 30 ? p.success : p.warning)))),
          DataCell(Text(money(pr.stockQty * pr.sellingPrice), style: p.body(12.5))),
        ])).toList(),
      )))))),
    ]);
  }
}

// ── Product Images ────────────────────────────────────────────────────────────
class _ImagesTab extends StatefulWidget {
  const _ImagesTab();
  @override
  State<_ImagesTab> createState() => _ImagesTabState();
}

class _ImagesTabState extends State<_ImagesTab> {
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final products = appState.products.where((pr) => _search.isEmpty || pr.name.toLowerCase().contains(_search.toLowerCase())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: 14, right: 12), child: Row(children: [
        Expanded(child: FormField2(label: '', controller: TextEditingController(text: _search), hint: 'Search products...', onChanged: (v) => setState(() => _search = v))),
      ])),
      Expanded(child: ScrollArea(builder: (sc) => SingleChildScrollView(controller: sc, padding: const EdgeInsets.only(right: 12, bottom: 28),
        child: Wrap(spacing: 14, runSpacing: 14, children: products.map((pr) {
          return SizedBox(width: 200, child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 120, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(6)), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.image_outlined, size: 36, color: p.textMuted),
              const SizedBox(height: 6),
              Text('No image', style: p.body(11, color: p.textMuted)),
            ]))),
            const SizedBox(height: 10),
            Text(pr.name, style: p.body(13, weight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(pr.categoryName, style: p.body(11, color: p.textMuted)),
            const SizedBox(height: 10),
            GoldButton(label: 'Upload Image', icon: Icons.upload_outlined, onTap: () => toast(context, 'Image upload coming soon')),
          ])));
        }).toList()),
      ))),
    ]);
  }
}
