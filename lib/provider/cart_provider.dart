//A notifier class to manage the cart state,
// extending from StateNotifier with an initial empty state. of an empty map

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/cart.dart';
import 'package:untitled/services/shared_preferences_service.dart';
// A provider to expose the CartNotifier to the rest of the app
// This allows other parts of the app to access and modify the cart state.
// It uses a StateNotifierProvider to create an instance of CartNotifier.

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, Cart>>(
  (ref) => CartNotifier(),
);


class CartNotifier extends StateNotifier<Map<String, Cart>> {
  // Clear all items from the cart
  void clearCart() {
    state = {};
  }
  CartNotifier() : super({}){
    _loadCartItems(); // Load cart items from SharedPreferences on initialization
  }
  // Load cart items from SharedPreferences
  // This method retrieves the cart items stored in SharedPreferences
  Future<void> _loadCartItems() async {
    final cartString = SharedPreferencesService.getCartData();
    if (cartString != null) {
      final Map<String, dynamic> cartMap = jsonDecode(cartString);

      // تحويل كل عنصر من Map إلى Favorite باستخدام fromMap
      final cartItems = cartMap.map(
        (key, value) => MapEntry(key, Cart.fromMap(value)),
      );

      state = cartItems;
    } else {
      state = {};
    }
  } 
  // Save the current state of the cart to SharedPreferences
   Future<void> _saveCartItems() async {
    // نحول Map<String, Favorite> إلى Map<String, Map>
    final encodedMap = state.map(
      (key, fav) => MapEntry(key, fav.toMap()),
    );

    final cartString = jsonEncode(encodedMap);
    await SharedPreferencesService.saveCartData(cartString);
  }

  // Method to add an item to the cart
  void addProductToCart({
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
  }) async {
    //check if the product already exists in the cart
    if (state.containsKey(productId)) {
      // If it exists, update the quantity
      final existingCartItem = state[productId]!; // Get the existing cart item
      state = {
        // Create a new state with the updated quantity
        ...state,
        productId: Cart(
          productName:
              existingCartItem.productName, // Keep the existing product name
          productPrice:
              existingCartItem.productPrice, // Keep the existing product price
          category: existingCartItem.category, // Keep the existing category
          image: existingCartItem.image, //

          vendorId: existingCartItem.vendorId,
          productQuantity: existingCartItem.productQuantity,
          quantity:
              existingCartItem.quantity + 1, // Increment the quantity

          // Use the existing productId
          productId: existingCartItem.productId,
          description: existingCartItem.description,
          fullName: existingCartItem.fullName,
        ),
        
      };
      _saveCartItems();
    } else {
      // If it doesn't exist, add a new item to the cart
      state = {
        ...state,
        productId: Cart(
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
        ),
      };
      _saveCartItems();
    }
  }
  // Method to increment the quantity of an existing item in the cart
  void IncrementCartItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity++;
      state = { ...state };
      _saveCartItems();
    }
  }
  // Method to decrement the quantity of an existing item in the cart
  void decrementCartItem(String productId) {
    if (state.containsKey(productId)) {
      if (state[productId]!.quantity > 1) {
        state[productId]!.quantity--;
        state = { ...state };
        _saveCartItems();
      } else {
        state.remove(productId);
        state = { ...state };
        _saveCartItems();
      }
    }
}
// Method to remove an item from the cart
  void removeProductFromCart(String productId) {
    if (state.containsKey(productId)) {
      state.remove(productId);
      state = { ...state };
      _saveCartItems();
    }
}
// Method calculate the total price of items in the cart
  double calculateTotalAmount() {
    double totalAmount = 0.0;
    state.forEach((productId, cartItem) {
      totalAmount += cartItem.productPrice * cartItem.quantity; // Calculate total price
    });
    return totalAmount;
  }

  Map<String, Cart> get getCartItems => state;
 
}