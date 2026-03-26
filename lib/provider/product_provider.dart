import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/controllers/product_controller.dart';
import 'package:untitled/models/product.dart';



// StateNotifier لإدارة حالة قائمة المنتجات
class ProductListNotifier extends StateNotifier<List<Product>> {
  ProductListNotifier() : super([]);

  void setProducts(List<Product> products) => state = products;
  void clearProducts() => state = [];
}

final productProvider = StateNotifierProvider<ProductListNotifier, List<Product>>((ref) {
  return ProductListNotifier();
});

// يمكنك أيضًا إنشاء Provider للتحكم في controller فقط
final productControllerProvider = Provider<ProductController>((ref) {
  return ProductController();
});

