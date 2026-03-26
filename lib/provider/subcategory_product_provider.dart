import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/product.dart';

class SubcategoryProductProvider extends StateNotifier<List<Product>> {
  SubcategoryProductProvider() : super([]);

  // Method to set the list of products
  void setProducts(List<Product> products) {
    state = products;
  }
}

final subcategoryProductProvider = StateNotifierProvider<SubcategoryProductProvider, List<Product>>(
  (ref) => SubcategoryProductProvider(),
); 