import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/globale_variables.dart';

import 'dart:convert';

import 'package:untitled/models/product.dart';
import 'package:untitled/services/manage_http_response.dart';
import 'package:untitled/services/shared_preferences_service.dart';

class ProductController {
 Future < List <Product> > loadPopularProduct ()async{
    try{
      // Check cache first
      String? cachedData = SharedPreferencesService.getPopularProducts();
      if (cachedData != null && !SharedPreferencesService.isDataStale('popular_products', 1)) {
        final data = jsonDecode(cachedData);
        if (data is List) {
          List<Product> products = data.map((product) => Product.fromJson(product as Map<String,dynamic>)).toList();
          return products;
        } else {
          throw Exception("Cached data is not a list");
        }
      }
      
      // send http get request
      http.Response response =await http.get(Uri.parse("$uri/api/popular-product"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },

      );
      if(response.statusCode==200){
        final data = jsonDecode(response.body);
        if (data is List) {
          List<Product> products  =     data.map((product)=> Product.fromJson(product as Map<String,dynamic>)).toList();
          
          // Cache the data
          await SharedPreferencesService.saveDataWithTimestamp('popular_products', jsonEncode(data));
          
          return products;
        } else {
          throw Exception("Response data is not a list");
        }
      } else if(response.statusCode==404){
        return [];
      } else{
        throw Exception("Failed to load popular products");
      }
    }catch(e){
      throw Exception("Error loading products: $e");
    }

  }

  Future < List <Product> > loadProductByCategory ( String category)async{
    try{
      // Check cache first
      String? cachedData = SharedPreferencesService.getProductsByCategory(category);
      if (cachedData != null && !SharedPreferencesService.isDataStale('products_category_$category', 1)) {
        final data = jsonDecode(cachedData);
        if (data is List) {
          List<Product> products = data.map((product) => Product.fromJson(product as Map<String,dynamic>)).toList();
          return products;
        } else {
          throw Exception("Cached data is not a list");
        }
      }
      
      // send http get request
      http.Response response =await http.get(Uri.parse("$uri/api/products-by-categroy/$category"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },

      );
      if(response.statusCode==200){
        final data = jsonDecode(response.body);
        if (data is List) {
          List<Product> products  =     data.map((product)=> Product.fromJson(product as Map<String,dynamic>)).toList();
          
          // Cache the data
          await SharedPreferencesService.saveDataWithTimestamp('products_category_$category', jsonEncode(data));
          
          return products;
        } else {
          throw Exception("Response data is not a list");
        }
      } else if(response.statusCode==404){
        return [];
      } else{
        throw Exception("Failed to load products");
      }
    } catch (e) {
      throw Exception("Error loading products: $e");
    }
  }

  Future < List <Product> > loadRelatedProductBySubCategory ( String productId)async{
    try{
      // send http get request
      http.Response response =await http.get(Uri.parse("$uri/api/related-products-by-subcategory/$productId"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },

      );
      if(response.statusCode==200){
        final data = jsonDecode(response.body);
        if (data is List) {
          List<Product> relatedProducts  =     data.map((product)=> Product.fromJson(product as Map<String,dynamic>)).toList();
          return relatedProducts;
        } else {
          throw Exception("Response data is not a list");
        }
      } else if(response.statusCode==404){
        return [];
      } else{
        throw Exception("Failed to load related products");
      }
    } catch (e) {
      throw Exception("Error loading related products: $e");
    }
  }

  Future < List <Product> > loadTopRatedProduct ()async{
    try{
      // Check cache first
      String? cachedData = SharedPreferencesService.getTopRatedProducts();
      if (cachedData != null && !SharedPreferencesService.isDataStale('top_rated_products', 1)) {
        final data = jsonDecode(cachedData);
        if (data is List) {
          List<Product> products = data.map((product) => Product.fromJson(product as Map<String,dynamic>)).toList();
          return products;
        } else {
          throw Exception("Cached data is not a list");
        }
      }
      
      // send http get request
      http.Response response =await http.get(Uri.parse("$uri/api/top-rated-products"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },

      );
      if(response.statusCode==200){
        final data = jsonDecode(response.body);
        if (data is List) {
          List<Product> vedorsProducts  =     data.map((product)=> Product.fromJson(product as Map<String,dynamic>)).toList();
          
          // Cache the data
          await SharedPreferencesService.saveDataWithTimestamp('top_rated_products', jsonEncode(data));
          
          return vedorsProducts;
        } else {
          throw Exception("Response data is not a list");
        }
      } else if(response.statusCode==404){
        return [];
      } else{
        throw Exception("Failed to load top rated products");
      }
    } catch (e) {
      throw Exception("Error loading top rated products: $e");
    }
  }

  Future < List <Product> > loadProductBySubCategory ( String subCategory)async{
    try{
      // Check cache first
      String? cachedData = SharedPreferencesService.getProductsBySubCategory(subCategory);
      if (cachedData != null && !SharedPreferencesService.isDataStale('products_subcategory_$subCategory', 1)) {
        final data = jsonDecode(cachedData);
        if (data is List) {
          List<Product> products = data.map((product) => Product.fromJson(product as Map<String,dynamic>)).toList();
          return products;
        } else {
          throw Exception("Cached data is not a list");
        }
      }
      
      // send http get request
      http.Response response =await http.get(Uri.parse("$uri/api/product-by-subcategory/$subCategory"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },

      );
      if(response.statusCode==200){
        final data = jsonDecode(response.body);
        if (data is List) {
          List<Product> products  =     data.map((product)=> Product.fromJson(product as Map<String,dynamic>)).toList();
          
          // Cache the data
          await SharedPreferencesService.saveDataWithTimestamp('products_subcategory_$subCategory', jsonEncode(data));
          
          return products;
        } else {
          throw Exception("Response data is not a list");
        }
      } else if(response.statusCode==404){
        return [];
      } else{
        throw Exception("Failed to load products by subcategory");
      }
    } catch (e) {
      throw Exception("Error loading products by subcategory: $e");
    }

  }

  // Method to search for products by name or description
  Future < List <Product> > searchProducts ( String query)async{
    try{
      print('🔍 Searching for: "$query"');
      
      // Since search endpoint doesn't exist, we'll get all popular products and filter locally
      final List<Product> popularProducts = await loadPopularProduct();
      final List<Product> topRatedProducts = await loadTopRatedProduct();
      
      // Combine all products and remove duplicates
      final Map<String, Product> allProductsMap = {};
      for (var product in popularProducts) {
        allProductsMap[product.id] = product;
      }
      for (var product in topRatedProducts) {
        allProductsMap[product.id] = product;
      }
      
      final List<Product> allProducts = allProductsMap.values.toList();
      print('📦 Loaded ${allProducts.length} unique products');
      
      // Filter products by name, description, or category
      List<Product> searchedProducts = allProducts.where((product) {
        final searchQuery = query.toLowerCase();
        final productName = product.productName.toLowerCase();
        final description = product.description.toLowerCase();
        final category = product.category.toLowerCase();
        
        return productName.contains(searchQuery) || 
               description.contains(searchQuery) || 
               category.contains(searchQuery);
      }).toList();
      
      print('✅ Found ${searchedProducts.length} matching products');
      return searchedProducts;
      
    }catch(e){
      print('💥 Exception: $e');
      throw Exception("Error loading searched products: $e");
    }

  }

  // Method to load products by vendor ID
  Future < List <Product> > loadProductByVendor ( String vendorId)async{
    try{
      print('🛍️ Fetching products for vendor: $vendorId');
      
      // Check cache first
      String? cachedData = SharedPreferencesService.getProductsByVendor(vendorId);
      if (cachedData != null && !SharedPreferencesService.isDataStale('products_vendor_$vendorId', 1)) {
        final data = jsonDecode(cachedData);
        if (data is List) {
          List<Product> products = data.map((product) => Product.fromJson(product as Map<String,dynamic>)).toList();
          print('✅ Found ${products.length} cached products for vendor $vendorId');
          return products;
        } else {
          throw Exception("Cached data is not a list");
        }
      }
      
      // Try multiple possible endpoints
      final List<String> endpoints = [
        "$uri/api/products-by-vendor/$vendorId",
        "$uri/api/products/vendor/$vendorId",
        "$uri/api/vendor/$vendorId/products",
        "$uri/api/products?vendorId=$vendorId",
      ];
      
      for (String endpoint in endpoints) {
        try {
          print('🔗 Trying endpoint: $endpoint');
          
          http.Response response = await http.get(
            Uri.parse(endpoint),
            headers: {
              "Content-Type": "application/json; charset=UTF-8",
            },
          );
          
          print('📡 Response status: ${response.statusCode}');
          
          if(response.statusCode == 200){
            final data = jsonDecode(response.body);
            if (data is List) {
              List<Product> products = data.map((product) => Product.fromJson(product as Map<String,dynamic>)).toList();
              print('✅ Found ${products.length} products for vendor $vendorId using endpoint: $endpoint');
              
              // Cache the data
              await SharedPreferencesService.saveDataWithTimestamp('products_vendor_$vendorId', jsonEncode(data));
              
              return products;
            } else {
              throw Exception("Response data is not a list");
            }
          } else if(response.statusCode == 404){
            print('⚠️ No products found for vendor $vendorId using endpoint: $endpoint');
            continue; // Try next endpoint
          } else{
            print('❌ Failed to load products by vendor. Status: ${response.statusCode} for endpoint: $endpoint');
            continue; // Try next endpoint
          }
        } catch (e) {
          print('💥 Error with endpoint $endpoint: $e');
          continue; // Try next endpoint
        }
      }
      
      // If all endpoints fail, use fallback
      print('🔄 All endpoints failed, using fallback method');
      return await _getProductsByVendorFallback(vendorId);
      
    }catch(e){
      print('💥 Error loading products by vendor: $e');
      // Fallback: try to get products from other endpoints and filter by vendor
      return await _getProductsByVendorFallback(vendorId);
    }

  }

  // Fallback method to get products by vendor ID from existing endpoints
  Future<List<Product>> _getProductsByVendorFallback(String vendorId) async {
    try {
      print('🔄 Using fallback method to get products for vendor: $vendorId');
      
      // Get products from multiple endpoints
      final List<Product> popularProducts = await loadPopularProduct();
      final List<Product> topRatedProducts = await loadTopRatedProduct();
      
      // Combine all products and remove duplicates
      final Map<String, Product> allProductsMap = {};
      for (var product in popularProducts) {
        allProductsMap[product.id] = product;
      }
      for (var product in topRatedProducts) {
        allProductsMap[product.id] = product;
      }
      
      final List<Product> allProducts = allProductsMap.values.toList();
      print('📦 Loaded ${allProducts.length} total products for filtering');
      
      // Filter products by vendor ID
      List<Product> vendorProducts = allProducts.where((product) {
        return product.vendorId == vendorId;
      }).toList();
      
      print('✅ Found ${vendorProducts.length} products for vendor $vendorId using fallback');
      return vendorProducts;
      
    } catch (e) {
      print('💥 Error in fallback method: $e');
      return [];
    }
  }
}