import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/models/vendor.dart';
import 'package:untitled/models/product.dart';

class CacheService {
  static const String _vendorsKey = 'cached_vendors';
  static const String _vendorProductsKey = 'cached_vendor_products';
  static const String _lastFetchTimeKey = 'last_fetch_time';
  static const Duration _cacheExpiryDuration = Duration(hours: 1); // Cache for 1 hour

  // Save vendors to cache
  static Future<void> saveVendors(List<Vendor> vendors) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorsJson = vendors.map((vendor) => vendor.toMap()).toList();
      await prefs.setString(_vendorsKey, jsonEncode(vendorsJson));
      await prefs.setString(_lastFetchTimeKey, DateTime.now().toIso8601String());
      print('💾 Saved ${vendors.length} vendors to cache');
    } catch (e) {
      print('❌ Error saving vendors to cache: $e');
    }
  }

  // Get cached vendors
  static Future<List<Vendor>> getCachedVendors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorsJson = prefs.getString(_vendorsKey);
      
      if (vendorsJson != null) {
        final List<dynamic> vendorsList = jsonDecode(vendorsJson);
        final vendors = vendorsList.map((vendorMap) => Vendor.fromJson(vendorMap)).toList();
        print('📦 Retrieved ${vendors.length} vendors from cache');
        return vendors;
      }
    } catch (e) {
      print('❌ Error retrieving vendors from cache: $e');
    }
    return [];
  }

  // Save vendor products to cache
  static Future<void> saveVendorProducts(String vendorId, List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = products.map((product) => product.toMap()).toList();
      final key = '${_vendorProductsKey}_$vendorId';
      await prefs.setString(key, jsonEncode(productsJson));
      print('💾 Saved ${products.length} products for vendor $vendorId to cache');
    } catch (e) {
      print('❌ Error saving vendor products to cache: $e');
    }
  }

  // Get cached vendor products
  static Future<List<Product>> getCachedVendorProducts(String vendorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_vendorProductsKey}_$vendorId';
      final productsJson = prefs.getString(key);
      
      if (productsJson != null) {
        final List<dynamic> productsList = jsonDecode(productsJson);
        final products = productsList.map((productMap) => Product.fromJson(productMap)).toList();
        print('📦 Retrieved ${products.length} products for vendor $vendorId from cache');
        return products;
      }
    } catch (e) {
      print('❌ Error retrieving vendor products from cache: $e');
    }
    return [];
  }

  // Save all vendor products at once
  static Future<void> saveAllVendorProducts(Map<String, List<Product>> vendorProducts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> allProductsMap = {};
      
      vendorProducts.forEach((vendorId, products) {
        final productsJson = products.map((product) => product.toMap()).toList();
        allProductsMap[vendorId] = productsJson;
      });
      
      await prefs.setString(_vendorProductsKey, jsonEncode(allProductsMap));
      await prefs.setString(_lastFetchTimeKey, DateTime.now().toIso8601String());
      print('💾 Saved products for ${vendorProducts.length} vendors to cache');
    } catch (e) {
      print('❌ Error saving all vendor products to cache: $e');
    }
  }

  // Get all cached vendor products
  static Future<Map<String, List<Product>>> getAllCachedVendorProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString(_vendorProductsKey);
      
      if (productsJson != null) {
        final Map<String, dynamic> allProductsMap = jsonDecode(productsJson);
        final Map<String, List<Product>> vendorProducts = {};
        
        allProductsMap.forEach((vendorId, productsList) {
          final products = (productsList as List)
              .map((productMap) => Product.fromJson(productMap))
              .toList();
          vendorProducts[vendorId] = products;
        });
        
        print('📦 Retrieved products for ${vendorProducts.length} vendors from cache');
        return vendorProducts;
      }
    } catch (e) {
      print('❌ Error retrieving all vendor products from cache: $e');
    }
    return {};
  }

  // Check if cache is expired
  static Future<bool> isCacheExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchTimeString = prefs.getString(_lastFetchTimeKey);
      
      if (lastFetchTimeString != null) {
        final lastFetchTime = DateTime.parse(lastFetchTimeString);
        final now = DateTime.now();
        final difference = now.difference(lastFetchTime);
        
        return difference > _cacheExpiryDuration;
      }
    } catch (e) {
      print('❌ Error checking cache expiry: $e');
    }
    return true; // Consider expired if no timestamp found
  }

  // Clear all cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_vendorsKey);
      await prefs.remove(_vendorProductsKey);
      await prefs.remove(_lastFetchTimeKey);
      
      // Clear individual vendor product keys
      final keys = prefs.getKeys();
      for (String key in keys) {
        if (key.startsWith(_vendorProductsKey)) {
          await prefs.remove(key);
        }
      }
      
      print('🗑️ Cleared all cache');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  // Get cache info
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchTimeString = prefs.getString(_lastFetchTimeKey);
      final vendorsJson = prefs.getString(_vendorsKey);
      final productsJson = prefs.getString(_vendorProductsKey);
      
      int vendorCount = 0;
      int productCount = 0;
      
      if (vendorsJson != null) {
        final vendorsList = jsonDecode(vendorsJson);
        vendorCount = vendorsList.length;
      }
      
      if (productsJson != null) {
        final allProductsMap = jsonDecode(productsJson);
        productCount = allProductsMap.values.fold(0, (sum, products) => sum + (products as List).length);
      }
      
      return {
        'lastFetchTime': lastFetchTimeString,
        'vendorCount': vendorCount,
        'productCount': productCount,
        'isExpired': await isCacheExpired(),
      };
    } catch (e) {
      print('❌ Error getting cache info: $e');
      return {};
    }
  }
} 