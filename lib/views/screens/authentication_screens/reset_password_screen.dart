import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/controllers/auth_controller.dart';
import 'package:untitled/views/screens/authentication_screens/login_screen.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Here you would typically call your backend API to reset the password
      // For now, we'll simulate the process
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reset password: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 18,
                color: Colors.white.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Header
                        Text(
                          "Reset Password",
                          style: GoogleFonts.getFont(
                            'Lato',
                            color: Color(0xFF7F53AC),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                            fontSize: 23,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Enter your new password",
                          style: GoogleFonts.getFont(
                            'Lato',
                            color: Color(0xFF647DEE),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 30),

                        // New Password Input
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "New Password",
                            style: GoogleFonts.getFont(
                              'Nunito Sans',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                              color: Color(0xFF7F53AC),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.white.withOpacity(0.95),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF7F53AC), width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF647DEE), width: 1),
                            ),
                            labelText: "Enter new password",
                            labelStyle: GoogleFonts.getFont(
                              'Nunito Sans',
                              fontSize: 14,
                              letterSpacing: 0.1,
                              color: Color(0xFF7F53AC),
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset(
                                "assets/icons/password.png",
                                height: 20,
                                width: 20,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                              icon: Icon(
                                _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                                color: Color(0xFF647DEE),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Confirm Password Input
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Confirm Password",
                            style: GoogleFonts.getFont(
                              'Nunito Sans',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                              color: Color(0xFF7F53AC),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.white.withOpacity(0.95),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF7F53AC), width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF647DEE), width: 1),
                            ),
                            labelText: "Confirm new password",
                            labelStyle: GoogleFonts.getFont(
                              'Nunito Sans',
                              fontSize: 14,
                              letterSpacing: 0.1,
                              color: Color(0xFF7F53AC),
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset(
                                "assets/icons/password.png",
                                height: 20,
                                width: 20,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                color: Color(0xFF647DEE),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),

                        // Reset Password Button
                        InkWell(
                          onTap: _isLoading ? null : _resetPassword,
                          child: Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Decorative elements
                                Positioned(
                                  left: 20,
                                  top: 15,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 20,
                                  bottom: 15,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: _isLoading
                                      ? CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                          "Reset Password",
                                          style: GoogleFonts.getFont(
                                            'Lato',
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Back to Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Remember your password? ",
                              style: GoogleFonts.getFont(
                                'Lato',
                                color: Color(0xFF7F53AC),
                                fontSize: 14,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginScreen()),
                                  (route) => false,
                                );
                              },
                              child: Text(
                                "Login",
                                style: GoogleFonts.getFont(
                                  'Lato',
                                  color: Color(0xFF647DEE),
                                  fontWeight: FontWeight.bold,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
} 