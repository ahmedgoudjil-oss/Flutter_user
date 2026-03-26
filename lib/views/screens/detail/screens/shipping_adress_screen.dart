
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class _C {
  static const cream = Color(0xFFF5F0E8);
  static const sand = Color(0xFFEDE7D9);
  static const parchment = Color(0xFFE5DDD0);
  static const terracotta = Color(0xFFBF6B4A);
  static const terracottaLight = Color(0xFFF0D5C8);
  static const charcoal = Color(0xFF1E1E1E);
  static const ink = Color(0xFF2D2926);
  static const slate = Color(0xFF6B6560);
  static const slateLight = Color(0xFF9B948C);
  static const white = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFDDD6CB);
}

class ShippingAddressScreen extends ConsumerStatefulWidget {
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController stateController;
  final TextEditingController cityController;
  final TextEditingController localityController;

  const ShippingAddressScreen({
    super.key,
    required this.nameController,
    required this.addressController,
    required this.phoneController,
    required this.stateController,
    required this.cityController,
    required this.localityController,
  });

  @override
  _ShippingAddressScreenState createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends ConsumerState<ShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressJson = prefs.getString('shipping_address');
      if (addressJson != null) {
        final data = json.decode(addressJson);
        widget.nameController.text = data['name'] ?? '';
        widget.addressController.text = data['address'] ?? '';
        widget.phoneController.text = data['phone'] ?? '';
        widget.stateController.text = data['state'] ?? '';
        widget.cityController.text = data['city'] ?? '';
        widget.localityController.text = data['locality'] ?? '';
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAddressToPrefs(Map<String, String> address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shipping_address', json.encode(address));
  }

  @override
  Widget build(BuildContext context) {
    final updateUser = ref.read(userProvider.notifier);

    return Scaffold(
      backgroundColor: _C.cream,
      appBar: AppBar(
        title: Text(
          'Shipping Information',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: _C.charcoal,
          ),
        ),
        backgroundColor: _C.cream,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _C.ink, size: 22),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _C.sand,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.cardBorder, width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(_C.terracotta),
                backgroundColor: _C.terracottaLight,
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _C.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _C.cardBorder, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: _C.ink.withOpacity(0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _C.terracottaLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: _C.terracotta,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery Address',
                                  style: GoogleFonts.playfairDisplay(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                    color: _C.charcoal,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Enter your shipping details',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: _C.slateLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                            _buildFormField(
                              controller: widget.nameController,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                              validator: (value) => value?.isEmpty == true ? 'Full name is required' : null,
                            ),
                            const SizedBox(height: 20),
                            _buildFormField(
                              controller: widget.addressController,
                              label: 'Address',
                              icon: Icons.home_outlined,
                              maxLines: 3,
                              validator: (value) => value?.isEmpty == true ? 'Address is required' : null,
                            ),
                            const SizedBox(height: 20),
                            _buildFormField(
                              controller: widget.phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) => value?.isEmpty == true ? 'Phone number is required' : null,
                            ),
                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    controller: widget.stateController,
                                    label: 'State',
                                    icon: Icons.location_city_outlined,
                                    validator: (value) => value?.isEmpty == true ? 'State is required' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormField(
                                    controller: widget.cityController,
                                    label: 'City',
                                    icon: Icons.location_on_outlined,
                                    validator: (value) => value?.isEmpty == true ? 'City is required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildFormField(
                              controller: widget.localityController,
                              label: 'Locality',
                              icon: Icons.place_outlined,
                              validator: (value) => value?.isEmpty == true ? 'Locality is required' : null,
                            ),

                            const SizedBox(height: 40),

                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: _C.terracotta,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: _C.terracotta.withOpacity(0.28),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _isLoading = true);
                                    try {
                                      updateUser.recreateUserState(
                                        city: widget.cityController.text,
                                        locality: widget.localityController.text,
                                        state: widget.stateController.text,
                                      );
                                      final address = {
                                        'name': widget.nameController.text,
                                        'address': widget.addressController.text,
                                        'phone': widget.phoneController.text,
                                        'state': widget.stateController.text,
                                        'city': widget.cityController.text,
                                        'locality': widget.localityController.text,
                                      };
                                      await _saveAddressToPrefs(address);
                                      
                                      if (mounted) {
                                        await _showSuccessDialog();
                                        Navigator.pop(context, address);
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.save_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Save & Continue',
                                      style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.cardBorder, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _C.charcoal,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _C.slate,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _C.sand,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: _C.terracotta,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: _C.white,
            border: Border.all(color: _C.cardBorder, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _C.terracottaLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: _C.terracotta,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Address Saved!',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: _C.charcoal,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your shipping address has been saved successfully.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: _C.slateLight,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.terracotta,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 16,
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

class ShippingAddressForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController stateController;
  final TextEditingController cityController;
  final TextEditingController localityController;
  final void Function({required String state, required String city, required String locality})? onChanged;

  const ShippingAddressForm({
    super.key,
    required this.nameController,
    required this.addressController,
    required this.phoneController,
    required this.stateController,
    required this.cityController,
    required this.localityController,
    this.onChanged,
  });

  @override
  State<ShippingAddressForm> createState() => _ShippingAddressFormState();
}

class _ShippingAddressFormState extends State<ShippingAddressForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.cardBorder, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _C.terracottaLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: _C.terracotta,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Shipping Information',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _C.charcoal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: widget.nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          validator: (value) => value?.isEmpty == true ? 'Full name is required' : null,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: widget.addressController,
          label: 'Address',
          icon: Icons.home_outlined,
          maxLines: 3,
          validator: (value) => value?.isEmpty == true ? 'Address is required' : null,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: widget.phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) => value?.isEmpty == true ? 'Phone number is required' : null,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          onChanged: (value) => widget.onChanged?.call(
            state: value,
            city: widget.cityController.text,
            locality: widget.localityController.text,
          ),
          controller: widget.stateController,
          label: 'State',
          icon: Icons.location_city_outlined,
          validator: (value) => value?.isEmpty == true ? 'State is required' : null,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          onChanged: (value) => widget.onChanged?.call(
            state: widget.stateController.text,
            city: value,
            locality: widget.localityController.text,
          ),
          controller: widget.cityController,
          label: 'City',
          icon: Icons.location_on_outlined,
          validator: (value) => value?.isEmpty == true ? 'City is required' : null,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          onChanged: (value) => widget.onChanged?.call(
            state: widget.stateController.text,
            city: widget.cityController.text,
            locality: value,
          ),
          controller: widget.localityController,
          label: 'Locality',
          icon: Icons.place_outlined,
          validator: (value) => value?.isEmpty == true ? 'Locality is required' : null,
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _C.charcoal,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _C.slate,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _C.sand,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: _C.terracotta,
              size: 18,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }
}
