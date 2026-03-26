// ignore_for_file: file_names

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/product.dart';

class TopratedProductProvider extends StateNotifier <List<Product>> {
  TopratedProductProvider() : super([]);

  // Method to set the list of products
  void setProducts(List<Product> products) {
    state = products;
  }

 
}
final topratedProductProvider = StateNotifierProvider<TopratedProductProvider, List<Product>>(
  (ref) => TopratedProductProvider(),
);