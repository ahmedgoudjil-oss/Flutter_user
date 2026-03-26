import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferences? _prefs;
  
  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return _prefs!;
  }
  
  // Auth related methods
  static Future<void> saveAuthToken(String token) async {
    await prefs.setString('auth_token', token);
  }
  
  static String? getAuthToken() {
    return prefs.getString('auth_token');
  }
  
  static Future<void> saveUserData(String userJson) async {
    await prefs.setString('user', userJson);
  }
  
  static String? getUserData() {
    return prefs.getString('user');
  }
  
  static Future<void> clearAuthData() async {
    await prefs.remove('auth_token');
    await prefs.remove('user');
  }
  
  // Cart related methods
  static Future<void> saveCartData(String cartJson) async {
    await prefs.setString('cart_item', cartJson);
  }
  
  static String? getCartData() {
    return prefs.getString('cart_item');
  }
  
  static Future<void> clearCartData() async {
    await prefs.remove('cart_item');
  }
  
  // Favorites related methods
  static Future<void> saveFavoritesData(String favoritesJson) async {
    await prefs.setString('favorites', favoritesJson);
  }
  
  static String? getFavoritesData() {
    return prefs.getString('favorites');
  }
  
  static Future<void> clearFavoritesData() async {
    await prefs.remove('favorites');
  }
  
  // Orders related methods
  static Future<void> saveOrdersData(String ordersJson) async {
    await prefs.setString('orders', ordersJson);
  }
  
  static String? getOrdersData() {
    return prefs.getString('orders');
  }
  
  static Future<void> clearOrdersData() async {
    await prefs.remove('orders');
  }
  
  // Products cache methods
  static Future<void> savePopularProducts(String productsJson) async {
    await prefs.setString('popular_products', productsJson);
  }
  
  static String? getPopularProducts() {
    return prefs.getString('popular_products');
  }
  
  static Future<void> saveTopRatedProducts(String productsJson) async {
    await prefs.setString('top_rated_products', productsJson);
  }
  
  static String? getTopRatedProducts() {
    return prefs.getString('top_rated_products');
  }
  
  static Future<void> saveProductsByCategory(String category, String productsJson) async {
    await prefs.setString('products_category_$category', productsJson);
  }
  
  static String? getProductsByCategory(String category) {
    return prefs.getString('products_category_$category');
  }
  
  static Future<void> saveProductsBySubCategory(String subCategory, String productsJson) async {
    await prefs.setString('products_subcategory_$subCategory', productsJson);
  }
  
  static String? getProductsBySubCategory(String subCategory) {
    return prefs.getString('products_subcategory_$subCategory');
  }
  
  static Future<void> saveProductsByVendor(String vendorId, String productsJson) async {
    await prefs.setString('products_vendor_$vendorId', productsJson);
  }
  
  static String? getProductsByVendor(String vendorId) {
    return prefs.getString('products_vendor_$vendorId');
  }
  
  // Categories cache methods
  static Future<void> saveCategories(String categoriesJson) async {
    await prefs.setString('categories', categoriesJson);
  }
  
  static String? getCategories() {
    return prefs.getString('categories');
  }
  
  static Future<void> saveSubCategories(String categoryName, String subCategoriesJson) async {
    await prefs.setString('subcategories_$categoryName', subCategoriesJson);
  }
  
  static String? getSubCategories(String categoryName) {
    return prefs.getString('subcategories_$categoryName');
  }
  
  // Banners cache methods
  static Future<void> saveBanners(String bannersJson) async {
    await prefs.setString('banners', bannersJson);
  }
  
  static String? getBanners() {
    return prefs.getString('banners');
  }
  
  // Vendors cache methods
  static Future<void> saveVendors(String vendorsJson) async {
    await prefs.setString('vendors', vendorsJson);
  }
  
  static String? getVendors() {
    return prefs.getString('vendors');
  }
  
  // Stores data methods (for 2-day caching)
  static Future<void> saveStoresData(String storesJson) async {
    await prefs.setString('stores_data', storesJson);
  }
  
  static String? getStoresData() {
    return prefs.getString('stores_data');
  }
  
  static Future<void> saveVendorProductsData(String vendorProductsJson) async {
    await prefs.setString('vendor_products_data', vendorProductsJson);
  }
  
  static String? getVendorProductsData() {
    return prefs.getString('vendor_products_data');
  }
  
  static Future<void> saveStoresLastFetchTime(String timestamp) async {
    await prefs.setString('stores_last_fetch_time', timestamp);
  }
  
  static String? getStoresLastFetchTime() {
    return prefs.getString('stores_last_fetch_time');
  }
  
  // Check if stores data is stale (older than 2 days)
  static bool isStoresDataStale() {
    String? timestamp = getStoresLastFetchTime();
    if (timestamp == null) return true;
    
    try {
      DateTime savedTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();
      Duration difference = now.difference(savedTime);
      
      return difference.inDays >= 2; // Cache expires after 2 days
    } catch (e) {
      return true;
    }
  }
  
  // Search history methods
  static Future<void> saveSearchHistory(List<String> searchTerms) async {
    await prefs.setStringList('search_history', searchTerms);
  }
  
  static List<String> getSearchHistory() {
    return prefs.getStringList('search_history') ?? [];
  }
  
  static Future<void> addSearchTerm(String term) async {
    List<String> history = getSearchHistory();
    if (!history.contains(term)) {
      history.insert(0, term);
      if (history.length > 10) { // Keep only last 10 searches
        history = history.take(10).toList();
      }
      await saveSearchHistory(history);
    }
  }
  
  static Future<void> clearSearchHistory() async {
    await prefs.remove('search_history');
  }
  
  // Shipping address methods
  static Future<void> saveShippingAddress(String addressJson) async {
    await prefs.setString('shipping_address', addressJson);
  }
  
  static String? getShippingAddress() {
    return prefs.getString('shipping_address');
  }
  
  static Future<void> clearShippingAddress() async {
    await prefs.remove('shipping_address');
  }
  
  // App settings methods
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await prefs.setString('app_settings', jsonEncode(settings));
  }
  
  static Map<String, dynamic> getAppSettings() {
    String? settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      return jsonDecode(settingsJson);
    }
    return {};
  }
  
  // Clear all data (for logout)
  static Future<void> clearAllData() async {
    await prefs.clear();
  }
  
  // Clear cache data only (keep auth data)
  static Future<void> clearCacheData() async {
    // Keep auth-related data
    String? authToken = getAuthToken();
    String? userData = getUserData();
    
    await prefs.clear();
    
    // Restore auth data
    if (authToken != null) await saveAuthToken(authToken);
    if (userData != null) await saveUserData(userData);
  }
  
  // Check if data is stale (older than specified hours)
  static bool isDataStale(String key, int hours) {
    String? timestampKey = '${key}_timestamp';
    String? timestamp = prefs.getString(timestampKey);
    
    if (timestamp == null) return true;
    
    try {
      DateTime savedTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();
      Duration difference = now.difference(savedTime);
      
      return difference.inHours > hours;
    } catch (e) {
      return true;
    }
  }
  
  // Save data with timestamp
  static Future<void> saveDataWithTimestamp(String key, String data) async {
    await prefs.setString(key, data);
    await prefs.setString('${key}_timestamp', DateTime.now().toIso8601String());
  }
} 