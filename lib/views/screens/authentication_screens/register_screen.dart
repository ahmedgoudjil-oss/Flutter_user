import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/controllers/auth_controller.dart';
import 'package:untitled/views/screens/authentication_screens/login_screen.dart';

class _C {
  static const cream = Color(0xFFF5F0E8);
  static const sand = Color(0xFFEDE7D9);
  static const terracotta = Color(0xFFBF6B4A);
  static const terracottaLight = Color(0xFFF0D5C8);
  static const charcoal = Color(0xFF1E1E1E);
  static const ink = Color(0xFF2D2926);
  static const slate = Color(0xFF6B6560);
  static const slateLight = Color(0xFF9B948C);
  static const white = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFDDD6CB);
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final authController _authController = authController();
  late String email;
  late String fullName;
  late String password;
  bool isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: _C.cream,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  registerUser() async {
    setState(() {
      isLoading = true;
    });

    await _authController.signUpUsers(
      context: context,
      fullName: fullName,
      email: email,
      password: password,
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _C.sand,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _C.cardBorder),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: _C.terracotta,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Create\nAccount',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: _C.charcoal,
                        height: 1.05,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(width: 32, height: 2, color: _C.terracotta),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 2,
                          color: _C.terracottaLight,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Join us and start your shopping adventure',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: _C.slate,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _C.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _C.cardBorder),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign Up',
                              style: GoogleFonts.dmSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: _C.ink,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildTextField(
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              icon: Icons.person_outlined,
                              onChanged: (value) => fullName = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                if (value.length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            _buildTextField(
                              label: 'Email',
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                              onChanged: (value) => email = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            _buildTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.lock_outlined,
                              obscureText: _obscurePassword,
                              onChanged: (value) => password = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: _C.slate,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          registerUser();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _C.terracotta,
                                  foregroundColor: _C.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: _C.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Sign Up',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: GoogleFonts.dmSans(
                                    color: _C.slateLight,
                                    fontSize: 14,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: GoogleFonts.dmSans(
                                      color: _C.terracotta,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _C.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(color: _C.slateLight, fontSize: 14),
            prefixIcon: Icon(icon, color: _C.slate, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: _C.sand,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.cardBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.terracotta, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
