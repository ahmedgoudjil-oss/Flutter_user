import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/globale_variables.dart';
import 'package:untitled/models/order.dart';
import 'package:untitled/services/manage_http_response.dart';
import 'package:untitled/services/shared_preferences_service.dart';

class OrderController {
  uploadOrders({
    required String id,
    required String fullName,
    required String email,
    required String state,
    required String city,
    required String locality,
    required String productName,
    required String productId,
    required int productPrice,
    required int quantity,
    required String category,
    required String image,
    required String buyerId,
    required String vendorId,
    required bool processing,
    required bool delivered,
    required String paymentStatus,
    required String paymentIntentId,
    required String paymentMethod,
    required context,
  }) async {
    try {
      String? token = SharedPreferencesService.getAuthToken();
      if (token == null) {
        showSnackBar(context, "Authentication token not found");
        return;
      }
      
      final Order order = Order(
        id: id,
        fullName: fullName,
        email: email,
        state: state,
        city: city,
        locality: locality,
        productName: productName,
        productId: productId,
        productPrice: productPrice,
        quantity: quantity,
        category: category,
        image: image,
        buyerId: buyerId,
        vendorId: vendorId,
        processing: processing,
        delivered: delivered,
        paymentStatus: paymentStatus,
        paymentIntentId: paymentIntentId,
        paymentMethod: paymentMethod,
      );

      http.Response response = await http.post(
        Uri.parse("$uri/api/orders"),
        headers: {'Content-Type': 'application/json',
        'x-auth-token': token
        },
        body: jsonEncode(order.toJson()),
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Order placed successfully");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
      print("Error uploading order: $e");
    }
  }

  //Method to get all orders by buyer ID
  Future<List<Order>> getOrdersByBuyerId({required String buyerId }) async {
    try {
      String? token = SharedPreferencesService.getAuthToken();
      if (token == null) {
        print("Authentication token not found");
        return [];
      }
      
      http.Response response = await http.get(
        Uri.parse("$uri/api/orders/buyer/$buyerId"),
        headers: <String,String>{'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token},
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['orders'] is List) {
          data = decoded['orders'] as List<dynamic>;
        } else {
          data = [];
        }

        List<Order> orders = data
            .whereType<Map<String, dynamic>>()
            .map((order) => Order.fromJson(order))
            .toList();
        
        // Cache the orders data
        await SharedPreferencesService.saveOrdersData(jsonEncode(data));
        
        return orders;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (e) {
      return [];
    }
  }
  //method to delete an order by ID
  Future<void> deleteOrderById({required String id, required context}) async {
    try {
      String? token = SharedPreferencesService.getAuthToken();
      if (token == null) {
        showSnackBar(context, "Authentication token not found");
        return;
      }
      
      http.Response response = await http.delete(
        Uri.parse("$uri/api/orders/$id"),
        headers: <String,String>{'Content-Type': 'application/json',
        'x-auth-token': token},
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Order deleted successfully");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
      print("Error deleting order: $e");
    }
  }

  // Method to get delivered orders count by buyer ID
  Future<int> getDeliveredCount(String buyerId) async {
    try {
      // Get all orders for the buyer
      final List<Order> orders = await getOrdersByBuyerId(buyerId: buyerId);
      
      // Count delivered orders
      final int deliveredCount = orders.where((order) => order.delivered).length;
      
      return deliveredCount;
    } catch (e) {
      print("Error fetching delivered count: $e");
      return 0;
    }
  }

// create payment intent method
Future<Map<String, dynamic>> createPaymentIntent({
  required int amount,
  required String currency,
}) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("auth_token");
    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found");
    }
    http.Response response = await http.post(
      Uri.parse("$uri/api/payment"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({
        'amount': amount,
        'currency': currency,
      }),
    );
   if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create payment intent");
    }
  } catch (e) {
    throw Exception("Error creating payment intent: $e");
  }
}

//retrieve payment to know if payment is successful or not
Future<Map<String, dynamic>> getPaymentIntentStatus({
  required BuildContext context,
  required String paymentIntentId,
}) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("auth_token");
    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found");
    }
    http.Response response = await http.get(
      Uri.parse("$uri/api/payment/$paymentIntentId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to retrieve payment intent");
    }
  } catch (e) {
    throw Exception("Error retrieving payment intent: $e");
  }
}
}

