import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/controllers/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final authController _authController = authController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Show a simple message for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password reset functionality will be implemented soon!'),
        backgroundColor: Colors.blue,
      ),
    );
    
    setState(() {
      _isLoading = false;
    });
    
    // Navigate back to login
    Navigator.pop(context);
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
                          "Forgot Password?",
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
                          "Enter your email to receive a reset link",
                          style: GoogleFonts.getFont(
                            'Lato',
                            color: Color(0xFF647DEE),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 30),

                        // Email Input
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Email",
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
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
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
                            labelText: "Enter your email",
                            labelStyle: GoogleFonts.getFont(
                              'Nunito Sans',
                              fontSize: 14,
                              letterSpacing: 0.1,
                              color: Color(0xFF7F53AC),
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset(
                                "assets/icons/email.png",
                                height: 20,
                                width: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),

                        // Send Reset Email Button
                        InkWell(
                          onTap: _isLoading ? null : _sendResetEmail,
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
                                          "Send Reset Email",
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
                                Navigator.pop(context);
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