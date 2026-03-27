import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/globale_variables.dart';
import 'package:untitled/provider/user_provider.dart';
import 'package:untitled/services/manage_http_response.dart';
import 'package:untitled/services/shared_preferences_service.dart';

import 'package:untitled/views/screens/authentication_screens/login_screen.dart';

import '../views/screens/main_screen.dart';
import 'package:untitled/provider/delivered_order_count_provider.dart';
import 'package:untitled/provider/cart_provider.dart';
import 'package:untitled/provider/favorite_provider.dart';

class authController {
  Future<void> signUpUsers({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      User user = User(
        id: '',
        fullName: fullName,
        email: email,
        password: password,
        state: '',
        city: '',
        locality: '',
        token: '',
      );
      http.Response response = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
          showSnackBar(context, "Account has been created");
        },
      );
    } catch (e) {
      print("Registration Error: $e");
      showSnackBar(context, "Something went wrong. Please try again.");
    }
  }

  Future<void> signInUsers({
    required BuildContext context,
    required WidgetRef ref,
    required String email,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          // Get token from response
          String token = jsonDecode(response.body)['token'];
          // Save token using SharedPreferences service
          await SharedPreferencesService.saveAuthToken(token);
          
          // Encode the user data received from the backend as json
          final userJson = jsonEncode(jsonDecode(response.body)['user']);

          // Update the application state with the user data using riverpod
          ref.read(userProvider.notifier).setUser(userJson);

          // Store the data in shared preferences for future use
          await SharedPreferencesService.saveUserData(userJson);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0,)),
            (route) => false,
          );
          showSnackBar(context, "Logged In ");
        },
      );
    } catch (e) {
      print('Error:$e');
    }
  }



  //signout
  Future<void> signOutUser({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      // Clear all data using SharedPreferences service
      await SharedPreferencesService.clearAllData();
      
      // Clear the user state
      ref.read(userProvider.notifier).signOut();
      // Reset the delivered order count
      ref.read(deliveredOrderCountProvider.notifier).resetCount();
      // Clear cart provider
      ref.read(cartProvider.notifier).clearCart();
      // Clear favorites provider
      ref.read(FavoriteProvider.notifier).clearAllFavorites();
      
      // Navigate the user back to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
      showSnackBar(context, "Sign Out Successfully");
    } catch (e) {
      showSnackBar(context, "Error signing out: $e");
    }
  }

  // update user state , city, locality,
  Future<void> updateUser({
    required BuildContext context,
    required WidgetRef ref,
    required String id,
    required String state,
    required String city,
    required String locality,
  }) async {
    try {
      http.Response response = await http.put(
        Uri.parse('$uri/api/users/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'state': state, 'city': city, 'locality': locality}),
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          final updatedUser = jsonDecode(response.body);
          final userJson = jsonEncode(updatedUser);
          
          // Update the user state in riverpod
          ref.read(userProvider.notifier).setUser(userJson);
          
          // Update the user data in shared preferences
          await SharedPreferencesService.saveUserData(userJson);
          
          showSnackBar(context, "User updated successfully");
          // Optionally, you can refresh the user data here
        },
      );
    } catch (e) {
      showSnackBar(context, "Error updating user: $e");
    }
  }
}
