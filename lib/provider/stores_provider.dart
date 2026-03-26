import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/vendor.dart';
import 'package:untitled/models/product.dart';
import 'package:untitled/services/shared_preferences_service.dart';

// Provider for stores with SharedPreferences persistence
final storesProvider = StateNotifierProvider<StoresNotifier, Map<String, dynamic>>(
  (ref) => StoresNotifier(),
);

class StoresNotifier extends StateNotifier<Map<String, dynamic>> {
  StoresNotifier() : super({
    'vendors': [],
    'vendorProducts': {},
    'lastFetchTime': null,
  }) {
    print('🏪 StoresNotifier constructor called');
    _loadStoresData(); // Load stores data from SharedPreferences on initialization
  }

  // Load stores data from SharedPreferences
  Future<void> _loadStoresData() async {
    print('📥 _loadStoresData called - loading from SharedPreferences');
    try {
      final storesString = SharedPreferencesService.getStoresData();
      final vendorProductsString = SharedPreferencesService.getVendorProductsData();
      final lastFetchTimeString = SharedPreferencesService.getStoresLastFetchTime();
      
      print('📊 SharedPreferences data found:');
      print('   - stores_data: ${storesString != null ? 'Available' : 'Not found'}');
      print('   - vendor_products_data: ${vendorProductsString != null ? 'Available' : 'Not found'}');
      print('   - stores_last_fetch_time: ${lastFetchTimeString ?? 'Not found'}');

      if (storesString != null) {
        final Map<String, dynamic> storesMap = jsonDecode(storesString);
        final List<dynamic> vendorsList = storesMap['vendors'] ?? [];
        final vendors = vendorsList.map((vendorMap) => Vendor.fromJson(vendorMap)).toList();

        // Load vendor products
        Map<String, List<Product>> vendorProducts = {};
        if (vendorProductsString != null) {
          final Map<String, dynamic> productsMap = jsonDecode(vendorProductsString);
          productsMap.forEach((vendorId, productsList) {
            final products = (productsList as List)
                .map((productMap) => Product.fromJson(productMap))
                .toList();
            vendorProducts[vendorId] = products;
          });
        }

        state = {
          'vendors': vendors,
          'vendorProducts': vendorProducts,
          'lastFetchTime': lastFetchTimeString,
        };
        
        print('📦 ✅ Successfully loaded from SharedPreferences:');
        print('   - ${vendors.length} vendors');
        print('   - ${vendorProducts.length} vendor products');
        print('   - Last fetch: ${lastFetchTimeString ?? 'Never'}');
      } else {
        print('📦 ❌ No cached stores data found in SharedPreferences');
      }
    } catch (e) {
      print('❌ Error loading stores data from SharedPreferences: $e');
    }
  }

  // Save stores data to SharedPreferences
  Future<void> _saveStoresData() async {
    print('💾 _saveStoresData called - saving to SharedPreferences');
    try {
      // Save vendors
      final vendors = state['vendors'] as List<Vendor>;
      final vendorsMap = vendors.map((vendor) => vendor.toMap()).toList();
      final storesData = {'vendors': vendorsMap};
      await SharedPreferencesService.saveStoresData(jsonEncode(storesData));

      // Save vendor products
      final vendorProducts = state['vendorProducts'] as Map<String, List<Product>>;
      final Map<String, dynamic> productsData = {};
      vendorProducts.forEach((vendorId, products) {
        productsData[vendorId] = products.map((product) => product.toMap()).toList();
      });
      await SharedPreferencesService.saveVendorProductsData(jsonEncode(productsData));

      // Save last fetch time
      await SharedPreferencesService.saveStoresLastFetchTime(DateTime.now().toIso8601String());

      print('💾 ✅ Successfully saved to SharedPreferences:');
      print('   - ${vendors.length} vendors');
      print('   - ${vendorProducts.length} vendor products');
      print('   - Timestamp: ${DateTime.now().toIso8601String()}');
    } catch (e) {
      print('❌ Error saving stores data to SharedPreferences: $e');
    }
  }

  // Update vendors
  void updateVendors(List<Vendor> vendors) {
    print('🔄 updateVendors called with ${vendors.length} vendors');
    state = {
      ...state,
      'vendors': vendors,
    };
    _saveStoresData();
  }

  // Update vendor products
  void updateVendorProducts(Map<String, List<Product>> vendorProducts) {
    print('🔄 updateVendorProducts called with ${vendorProducts.length} vendor products');
    state = {
      ...state,
      'vendorProducts': vendorProducts,
    };
    _saveStoresData();
  }

  // Update all stores data
  void updateStoresData(List<Vendor> vendors, Map<String, List<Product>> vendorProducts) {
    print('🔄 updateStoresData called:');
    print('   - ${vendors.length} vendors');
    print('   - ${vendorProducts.length} vendor products');
    state = {
      'vendors': vendors,
      'vendorProducts': vendorProducts,
      'lastFetchTime': DateTime.now().toIso8601String(),
    };
    _saveStoresData();
  }

  // Get vendors
  List<Vendor> get vendors {
    final vendorsList = state['vendors'];
    if (vendorsList == null) return [];
    
    if (vendorsList is List<Vendor>) {
      return vendorsList;
    } else if (vendorsList is List<dynamic>) {
      try {
        return vendorsList.map((item) {
          if (item is Vendor) {
            return item;
          } else if (item is Map<String, dynamic>) {
            return Vendor.fromJson(item);
          } else {
            throw Exception('Invalid vendor data type: ${item.runtimeType}');
          }
        }).toList();
      } catch (e) {
        print('❌ Error converting vendors data: $e');
        return [];
      }
    }
    return [];
  }

  // Get vendor products
  Map<String, List<Product>> get vendorProducts {
    final productsMap = state['vendorProducts'];
    if (productsMap == null) return {};
    
    if (productsMap is Map<String, List<Product>>) {
      return productsMap;
    } else if (productsMap is Map<String, dynamic>) {
      try {
        final Map<String, List<Product>> result = {};
        productsMap.forEach((vendorId, productsList) {
          if (productsList is List<Product>) {
            result[vendorId] = productsList;
          } else if (productsList is List<dynamic>) {
            result[vendorId] = productsList.map((item) {
              if (item is Product) {
                return item;
              } else if (item is Map<String, dynamic>) {
                return Product.fromJson(item);
              } else {
                throw Exception('Invalid product data type: ${item.runtimeType}');
              }
            }).toList();
          }
        });
        return result;
      } catch (e) {
        print('❌ Error converting vendor products data: $e');
        return {};
      }
    }
    return {};
  }

  // Get last fetch time
  String? get lastFetchTime {
    return state['lastFetchTime'] as String?;
  }

  // Check if cache is expired (2 days for better UX)
  bool get isCacheExpired {
    return SharedPreferencesService.isStoresDataStale();
  }

  // Clear all stores data
  void clearStoresData() {
    print('🗑️ clearStoresData called - clearing all cached data');
    state = {
      'vendors': [],
      'vendorProducts': {},
      'lastFetchTime': null,
    };
    _saveStoresData();
    print('🗑️ ✅ Cleared all stores data from SharedPreferences');
  }

  // Get stores with products only
  List<Vendor> get vendorsWithProducts {
    final vendorsList = vendors;
    final productsMap = vendorProducts;
    
    return vendorsList.where((vendor) {
      final vendorProducts = productsMap[vendor.id] ?? [];
      return vendorProducts.isNotEmpty;
    }).toList();
  }

  // Get cache info
  Map<String, dynamic> get cacheInfo {
    final vendorsList = vendors;
    final productsMap = vendorProducts;
    int totalProducts = 0;
    
    productsMap.forEach((vendorId, products) {
      totalProducts += products.length;
    });

    return {
      'vendorCount': vendorsList.length,
      'vendorsWithProductsCount': vendorsWithProducts.length,
      'totalProducts': totalProducts,
      'lastFetchTime': lastFetchTime,
      'isExpired': isCacheExpired,
    };
  }
} 