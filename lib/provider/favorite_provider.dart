import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/favorite.dart';
import 'package:untitled/services/shared_preferences_service.dart';

final FavoriteProvider = StateNotifierProvider<FavoriteNotifier, Map<String, Favorite>>(
  (ref) => FavoriteNotifier(),
);

// Wishlist count provider that watches the favorite provider
final wishlistCountProvider = Provider<int>((ref) {
  final favorites = ref.watch(FavoriteProvider);
  return favorites.length;
});

class FavoriteNotifier extends StateNotifier<Map<String, Favorite>> {
  FavoriteNotifier() : super({}) {
    _loadFavorites(); // Load favorites on init
  }

  Future<void> _loadFavorites() async {
    final favoriteString = SharedPreferencesService.getFavoritesData();
    if (favoriteString != null) {
      final Map<String, dynamic> favoriteMap = jsonDecode(favoriteString);

      // تحويل كل عنصر من Map إلى Favorite باستخدام fromMap
      final favorites = favoriteMap.map(
        (key, value) => MapEntry(key, Favorite.fromMap(value)),
      );

      state = favorites;
    } else {
      state = {};
    }
  }

  Future<void> _saveFavorites() async {
    // نحول Map<String, Favorite> إلى Map<String, Map>
    final encodedMap = state.map(
      (key, fav) => MapEntry(key, fav.toMap()),
    );

    final favoriteString = jsonEncode(encodedMap);
    await SharedPreferencesService.saveFavoritesData(favoriteString);
  }

  void addProductToFavorites({
    required String productName,
    required int productPrice,
    required String category,
    required List<String> image,
    required String vendorId,
    required int productQuantity,
    required int quantity,
    required String productId,
    required String description,
    required String fullName,
    double? averageRating,
    int? totalRatings,
  }) {
    state[productId] = Favorite(
      productName: productName,
      productPrice: productPrice,
      category: category,
      image: image,
      vendorId: vendorId,
      productQuantity: productQuantity,
      quantity: quantity,
      productId: productId,
      description: description,
      fullName: fullName,
      averageRating: averageRating ?? 0.0,
      totalRatings: totalRatings ?? 0,
    );
    state = {...state};
    _saveFavorites();
  }

  void removeProductFromFavorite(String productId) {
    if (state.containsKey(productId)) {
      state.remove(productId);
      state = {...state};
      _saveFavorites();
    }
  }

  void clearAllFavorites() {
    state = {};
    _saveFavorites();
  }

  Map<String, Favorite> get getFavoriteItems => state;
}
