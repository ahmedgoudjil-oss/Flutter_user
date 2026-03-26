import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../provider/user_provider.dart';
import '../services/shared_preferences_service.dart';
import '../views/screens/main_screen.dart';
import '../views/screens/authentication_screens/login_screen.dart';
import '../globale_variables.dart';
import '../services/manage_http_response.dart';

class AuthController {

  // ================= SIGN UP =================
  Future<bool> signUpUsers({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.sendEmailVerification();

      showSnackBar(context, "Check your email to verify your account");
      return true;
    } catch (e) {
      showSnackBar(context, e.toString());
      return false;
    }
  }

  // ================= SIGN IN =================
  Future<void> signInUsers({
    required BuildContext context,
    required WidgetRef ref,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (!user!.emailVerified) {
        showSnackBar(context, "⚠️ Please verify your email first");
        return;
      }

      final idToken = await user.getIdToken();

      http.Response response = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({'idToken': idToken}),
        headers: {"Content-Type": 'application/json; charset=UTF-8'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        String token = data['token'];

        await SharedPreferencesService.saveAuthToken(token);

        final userJson = jsonEncode(data['user']);
        ref.read(userProvider.notifier).setUser(userJson);
        await SharedPreferencesService.saveUserData(userJson);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0)),
          (route) => false,
        );

        showSnackBar(context, "Logged In");
      } else {
        showSnackBar(context, data['msg'] ?? "Something went wrong");
      }
    } catch (e) {
      showSnackBar(context, "Error: $e");
    }
  }

  // ================= SIGN OUT =================
  Future<void> signOutUser({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      await FirebaseAuth.instance.signOut();
      await SharedPreferencesService.clearAllData();
      ref.read(userProvider.notifier).signOut();

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
}