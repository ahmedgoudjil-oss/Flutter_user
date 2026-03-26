import 'dart:convert' show jsonEncode;

import 'package:http/http.dart' as http;
import 'package:untitled/globale_variables.dart';
import 'package:untitled/models/product_review.dart';
import 'package:untitled/services/manage_http_response.dart';
import 'package:untitled/services/shared_preferences_service.dart';

class ProductReviewController {
  uploadReview({
    required String buyerId,
    required String email,
    required String fullName,
    required String productId,
    required double rating,
    required String review,
    required context,
  }) async {
    try {
      final String? token = SharedPreferencesService.getAuthToken();
      if (token == null || token.isEmpty) {
        showSnackBar(context, "Please login to submit a review");
        return;
      }

      final productReview = ProductReview(
        id: '',
        buyerId: buyerId,
        email: email,
        fullName: fullName,
        productId: productId,
        rating: rating,
        review: review,
      );
      http.Response response = await http.post(
        Uri.parse("$uri/api/product-review"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(productReview.toJson()),
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Your review has been submitted successfully");
        },
      );
    } catch (e) {
      throw Exception("Error submitting review: $e");
    }
  }
}
