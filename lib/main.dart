import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:untitled/provider/user_provider.dart';
import 'package:untitled/services/shared_preferences_service.dart';
import 'package:untitled/views/screens/authentication_screens/login_screen.dart';
import 'package:untitled/views/screens/main_screen.dart';
import 'package:untitled/views/screens/splash_screen.dart';
import 'package:untitled/views/screens/nav_screens/home_screen.dart';
import 'package:untitled/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  Stripe.publishableKey = 'pk_test_51TC53XJZpmq0OtxdshDPH9YNwoyC2YJaVO16Vp8nEK77IcljMfUXhqTV3eDllAdhxBNYUjWshr2QLXpdByNKhVcc002oeXtEn2';
  await Stripe.instance.applySettings();
  // Initialize SharedPreferences service
  await SharedPreferencesService.init();
  
  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: true,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  //method to check if user exists
  Future<void> _checkTokenAndSetUser(WidgetRef ref) async {
    //access sharedprefernce for token and user data storage
    String? token = SharedPreferencesService.getAuthToken();
    String? userJson = SharedPreferencesService.getUserData();
    if (token != null && userJson != null) {
      ref.read(userProvider.notifier).setUser(userJson);
    }else{
       ref.read(userProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.light(),
      home: const SplashScreen(), // Start with splash screen
    );
  }
}
