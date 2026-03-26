import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/provider/user_provider.dart';
import 'package:untitled/views/screens/authentication_screens/login_screen.dart';
import 'package:untitled/views/screens/main_screen.dart';

class _C {
  static const cream = Color(0xFFF5F0E8);
  static const sand = Color(0xFFEDE7D9);
  static const terracotta = Color(0xFFBF6B4A);
  static const terracottaLight = Color(0xFFF0D5C8);
  static const charcoal = Color(0xFF1E1E1E);
  static const slate = Color(0xFF6B6560);
  static const white = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFDDD6CB);
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Wait briefly so the splash is visible
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user');

      if (token != null && userJson != null) {
        ref.read(userProvider.notifier).setUser(userJson);
        _goTo(const MainScreen(initialIndex: 0));
      } else {
        ref.read(userProvider.notifier).signOut();
        _goTo(const LoginScreen());
      }
    } catch (e) {
      debugPrint('Splash auth error: $e');
      _goTo(const LoginScreen());
    }
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.cream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: _C.sand,
                  shape: BoxShape.circle,
                  border: Border.all(color: _C.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: _C.charcoal.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'N',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: _C.terracotta,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'NOVA SHOP',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: _C.charcoal,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover Your Style',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: _C.slate,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 46),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_C.terracotta),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 84,
                height: 3,
                decoration: BoxDecoration(
                  color: _C.terracottaLight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 34,
                    height: 3,
                    decoration: BoxDecoration(
                      color: _C.terracotta,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
