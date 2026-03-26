import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/banner_model.dart';
import 'package:untitled/models/vendor.dart';
import 'package:untitled/models/product.dart';
  
class VendorProvider extends StateNotifier<List<Vendor>> {
  VendorProvider() : super([]);

  // Method to add a banner
  void addVendor(List<Vendor> vendors) {
    state = vendors;
  }

 
}
final vendorProvider = StateNotifierProvider<VendorProvider, List<Vendor>>(
  (ref) => VendorProvider(),
);

// Provider for vendor products
class VendorProductsProvider extends StateNotifier<Map<String, List<Product>>> {
  VendorProductsProvider() : super({});

  // Method to set products for a specific vendor
  void setVendorProducts(String vendorId, List<Product> products) {
    state = {...state, vendorId: products};
  }

  // Method to get products for a specific vendor
  List<Product> getVendorProducts(String vendorId) {
    return state[vendorId] ?? [];
  }

  // Method to clear all vendor products
  void clearVendorProducts() {
    state = {};
  }
}

final vendorProductsProvider = StateNotifierProvider<VendorProductsProvider, Map<String, List<Product>>>(
  (ref) => VendorProductsProvider(),
);