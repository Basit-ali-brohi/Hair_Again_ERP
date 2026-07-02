// modules/products/models — Product catalog, categories, brands & variants.

class ProductCategory {
  String id, name, description;
  bool isActive;
  int productCount;
  String iconLabel;
  ProductCategory({required this.id, required this.name, required this.description,
    this.isActive = true, this.productCount = 0, this.iconLabel = ''});
}

class Brand {
  String id, name, description, origin;
  bool isActive;
  Brand({required this.id, required this.name, required this.description,
    this.origin = 'Pakistan', this.isActive = true});
}

class ProductVariant {
  String id, name, sku;
  double costPrice, sellingPrice;
  int stockQty;
  bool isActive;
  ProductVariant({required this.id, required this.name, required this.sku,
    required this.costPrice, required this.sellingPrice,
    this.stockQty = 0, this.isActive = true});
  double get marginPct => sellingPrice == 0 ? 0 : (sellingPrice - costPrice) / sellingPrice * 100;
}

class Product {
  String id, name, categoryId, categoryName, brandId, brandName;
  String description, sku, unit;
  double costPrice, sellingPrice;
  int stockQty, reorderLevel;
  bool isActive;
  List<ProductVariant> variants;
  Product({required this.id, required this.name, required this.categoryId,
    required this.categoryName, required this.brandId, required this.brandName,
    required this.description, required this.sku, required this.unit,
    required this.costPrice, required this.sellingPrice,
    this.stockQty = 0, this.reorderLevel = 5,
    this.isActive = true, required this.variants});

  bool get isLowStock => stockQty <= reorderLevel;
  double get marginPct => sellingPrice == 0 ? 0 : (sellingPrice - costPrice) / sellingPrice * 100;
  double get totalVariantValue => variants.fold(0, (s, v) => s + v.stockQty * v.sellingPrice);
}
