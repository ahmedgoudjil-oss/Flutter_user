// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/controllers/auth_controller.dart';
import 'package:untitled/controllers/order_controller.dart';
import 'package:untitled/provider/cart_provider.dart';
import 'package:untitled/provider/user_provider.dart';
import 'package:untitled/views/screens/main_screen.dart';
import 'package:untitled/views/screens/nav_screens/cart_screen.dart';
import 'package:untitled/views/screens/detail/screens/shipping_adress_screen.dart';

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

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final AuthController _authController = AuthController();
  String shippingMethod = 'Deliver to your address';
  String paymentMethod = 'Cash on Delivery';
  late AnimationController _controller;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _cartProvider = cartProvider;
  final _orderController = OrderController();
  late String city;
  late String state;
  late String locality;
  bool isLoading = false;

  Future<bool> handleStripePayment(BuildContext context) async {
    final cartData = ref.read(cartProvider);
    final user = ref.read(userProvider);

    // Check if cart is empty
    if (cartData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your cart is empty! Please add items to proceed.',
            style: GoogleFonts.dmSans(fontSize: 13),
          ),
          backgroundColor: _C.terracotta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return false;
    }

    // Check if user is null
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User session expired. Please login again.',
            style: GoogleFonts.dmSans(fontSize: 13),
          ),
          backgroundColor: _C.terracotta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return false;
    }

    try {
      setState(() => isLoading = true);

      // Calculate total amount
      final totalAmount = cartData.values.fold(
        0.0,
        (sum, item) => sum + item.productPrice * item.quantity,
      );

      // Check if total amount is valid
      if (totalAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid total amount. Please check your cart items.',
              style: GoogleFonts.dmSans(fontSize: 13),
            ),
            backgroundColor: _C.terracotta,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return false;
      }

      // Create payment intent
      final paymentIntentData = await _orderController.createPaymentIntent(
        amount: (totalAmount * 100).toInt(),
        currency: 'USD',
      );

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'Nova Shop',
        ),
      );

      // Present payment sheet to user
      await Stripe.instance.presentPaymentSheet();
      // verify payment status 
      final paymentIntentStatus = await _orderController.getPaymentIntentStatus(
        context: context,
        paymentIntentId: paymentIntentData['id'],
      );
     

      // Upload each cart item as an order after successful payment
      if (paymentIntentStatus['status'] != 'succeeded') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment was not completed. Please try again.',
              style: GoogleFonts.dmSans(fontSize: 13),
            ),
            backgroundColor: _C.terracotta,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return false;
      }

      for (final entry in cartData.entries) {
        final item = entry.value;
        await _orderController.uploadOrders(
          id: '',
          fullName: user.fullName,
          email: user.email,
          state: _stateController.text.isNotEmpty
              ? _stateController.text
              : user.state,
          city: _cityController.text.isNotEmpty
              ? _cityController.text
              : user.city,
          locality: _localityController.text.isNotEmpty
              ? _localityController.text
              : user.locality,
          productName: item.productName,
            productId: item.productId,
          productPrice: item.productPrice,
          quantity: item.quantity,
          category: item.category,
          image: item.image[0],
          buyerId: user.id,
          vendorId: item.vendorId,
          processing: true,
          delivered: false,
          context: context,
          paymentStatus: paymentIntentStatus['status']?.toString() ?? 'pending',
          paymentIntentId: paymentIntentData['id']?.toString() ?? '',
          paymentMethod: 'card',
        );
      }


      return true;
    } on StripeException catch (e) {
      // User cancelled — don't show an error, just return false quietly
      if (e.error.code == FailureCode.Canceled) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment failed: ${e.error.localizedMessage}',
            style: GoogleFonts.dmSans(fontSize: 13),
          ),
          backgroundColor: _C.terracotta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment failed: ${e.toString()}',
            style: GoogleFonts.dmSans(fontSize: 13),
          ),
          backgroundColor: _C.terracotta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return false;
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
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
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: _C.terracottaLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: _C.terracotta,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Order Confirmed!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _C.charcoal,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your order has been placed successfully. You will receive a confirmation email shortly.',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: _C.slateLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(cartProvider.notifier).clearCart();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(initialIndex: 0),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.terracotta,
                    foregroundColor: _C.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue Shopping',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _controller.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartData = ref.watch(cartProvider);
    final _cartProvider = ref.watch(cartProvider.notifier);
    final products = cartData.values.toList();
    final user = ref.watch(userProvider);
    final total = products.fold<double>(
      0,
      (sum, item) => sum + item.productPrice * item.quantity,
    );

    return Scaffold(
      backgroundColor: _C.cream,
      appBar: AppBar(
        backgroundColor: _C.cream,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _C.sand,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.cardBorder, width: 1),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: _C.ink,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: _C.charcoal,
            fontSize: 28,
            height: 1.1,
          ),
        ),
        centerTitle: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: _C.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _C.cardBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: _C.ink.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildProgressStep(1, 'Cart', true, Icons.shopping_cart),
                      _buildProgressLine(true),
                      _buildProgressStep(2, 'Checkout', true, Icons.payment),
                      _buildProgressLine(false),
                      _buildProgressStep(
                        3,
                        'Done',
                        false,
                        Icons.check_circle_outline,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Shipping Information Card
                _buildSectionCard(
                  title: 'Shipping Information',
                  icon: Icons.location_on_outlined,
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Name',
                        _nameController.text.isNotEmpty
                            ? _nameController.text
                            : 'Not provided',
                      ),
                      _buildInfoRow(
                        'Address',
                        _addressController.text.isNotEmpty
                            ? _addressController.text
                            : 'Not provided',
                      ),
                      _buildInfoRow(
                        'Phone',
                        _phoneController.text.isNotEmpty
                            ? _phoneController.text
                            : 'Not provided',
                      ),
                      _buildInfoRow(
                        'Location',
                        '${_stateController.text.isNotEmpty ? _stateController.text : 'State'}, ${_cityController.text.isNotEmpty ? _cityController.text : 'City'}, ${_localityController.text.isNotEmpty ? _localityController.text : 'Locality'}',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            final oldAddress = _addressController.text;
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShippingAddressScreen(
                                  nameController: _nameController,
                                  addressController: _addressController,
                                  phoneController: _phoneController,
                                  stateController: _stateController,
                                  cityController: _cityController,
                                  localityController: _localityController,
                                ),
                                settings: RouteSettings(
                                  arguments: {'address': oldAddress},
                                ),
                              ),
                            );
                            if (result is Map<String, String>) {
                              setState(() {
                                _nameController.text = result['name'] ?? '';
                                _addressController.text =
                                    result['address'] ?? '';
                                _phoneController.text = result['phone'] ?? '';
                                _stateController.text = result['state'] ?? '';
                                _cityController.text = result['city'] ?? '';
                                _localityController.text =
                                    result['locality'] ?? '';
                              });
                              if (oldAddress.isNotEmpty &&
                                  oldAddress != (result['address'] ?? '')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Address updated!',
                                      style: GoogleFonts.dmSans(),
                                    ),
                                    backgroundColor: _C.terracotta,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: Text(
                            'Edit Address',
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.terracotta,
                            foregroundColor: _C.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                              horizontal: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: _C.terracotta.withOpacity(0.25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Shipping Method Card
                _buildSectionCard(
                  title: 'Shipping Method',
                  icon: Icons.local_shipping_outlined,
                  child: Column(
                    children: [
                      _buildRadioOption(
                        'Deliver to your address',
                        'Standard delivery to your doorstep',
                        Icons.home_outlined,
                        shippingMethod,
                        (value) => setState(() => shippingMethod = value!),
                      ),
                      const SizedBox(height: 12),
                      _buildRadioOption(
                        'Company delivering',
                        'Pickup from our store location',
                        Icons.store_outlined,
                        shippingMethod,
                        (value) => setState(() => shippingMethod = value!),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Order Summary Card
                _buildSectionCard(
                  title: 'Order Summary',
                  icon: Icons.receipt_long_outlined,
                  child: Column(
                    children: [
                      ...products.map((product) => _buildProductItem(product)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              '${total.toStringAsFixed(2)} DA',
                              style: GoogleFonts.quicksand(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF7F53AC),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Payment Method Card
                _buildSectionCard(
                  title: 'Payment Method',
                  icon: Icons.payment_outlined,
                  child: Column(
                    children: [
                      _buildRadioOption(
                        'Cash on Delivery',
                        'Pay when you receive your order',
                        Icons.money_outlined,
                        paymentMethod,
                        (value) => setState(() => paymentMethod = value!),
                      ),
                      const SizedBox(height: 12),
                      _buildRadioOption(
                        'Stripe',
                        'Pay securely with card',
                        Icons.credit_card_outlined,
                        paymentMethod,
                        (value) => setState(() => paymentMethod = value!),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Confirm Order Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            HapticFeedback.mediumImpact();

                            if (_addressController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please add your shipping address!',
                                    style: GoogleFonts.dmSans(fontSize: 13),
                                  ),
                                  backgroundColor: _C.terracotta,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              return;
                            }

                            if (paymentMethod == 'Stripe') {
                              // ── Stripe path ──────────────────────────────
                              final stripeSuccess =
                                  await handleStripePayment(context);
                              if (!stripeSuccess) return;
                              // Success: show dialog (cart is cleared inside it)
                              _showSuccessDialog();
                            } else {
                              // ── Cash on Delivery path ────────────────────
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: _C.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _C.cardBorder,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _C.ink.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            _C.terracotta,
                                          ),
                                          backgroundColor: _C.terracottaLight,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Processing your order...',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: _C.charcoal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              final currentUser = ref.read(userProvider);
                              if (currentUser == null) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'User session expired. Please login again.',
                                      style: GoogleFonts.dmSans(fontSize: 13),
                                    ),
                                    backgroundColor: _C.terracotta,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                return;
                              }

                              await Future.forEach(
                                _cartProvider.getCartItems.entries,
                                (entry) async {
                                  final cartItem = entry.value;
                                  await _orderController.uploadOrders(
                                    id: '',
                                    fullName: currentUser.fullName,
                                    email: currentUser.email,
                                    state: _stateController.text,
                                    city: _cityController.text,
                                    locality: _localityController.text,
                                    productName: cartItem.productName,
                                    productId: cartItem.productId,
                                    productPrice: cartItem.productPrice,
                                    quantity: cartItem.quantity,
                                    category: cartItem.category,
                                    image: cartItem.image[0],
                                    buyerId: currentUser.id,
                                    vendorId: cartItem.vendorId,
                                    processing: true,
                                    delivered: false,
                                    paymentStatus: 'pending',
                                    paymentIntentId: 'cash on delivery',
                                    paymentMethod: 'Cash on Delivery',
                                    context: context,
                                  );
                                },
                              );

                              Navigator.pop(context); // Close loading dialog
                              _showSuccessDialog();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.terracotta,
                      disabledBackgroundColor: _C.terracotta.withOpacity(0.6),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      shadowColor: _C.terracotta.withOpacity(0.3),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: _C.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _C.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  paymentMethod == 'Stripe'
                                      ? Icons.credit_card_outlined
                                      : Icons.lock_outline,
                                  color: _C.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                paymentMethod == 'Stripe'
                                    ? 'Pay with Stripe • \$${total.toStringAsFixed(2)}'
                                    : 'Place Order • \$${total.toStringAsFixed(2)}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _C.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(
    int step,
    String title,
    bool isActive,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? _C.terracotta : _C.sand,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: _C.terracotta.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: isActive ? _C.white : _C.slate, size: 22),
          ),
          const SizedBox(height: 10),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? _C.terracotta : _C.slate,
              letterSpacing: 0.3,
            ),
            child: Text(title),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      height: 1.5,
      width: 28,
      color: isActive ? _C.terracotta : _C.cardBorder,
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _C.terracottaLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _C.terracotta, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _C.charcoal,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _C.slate,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: _C.charcoal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(
    String title,
    String subtitle,
    IconData icon,
    String groupValue,
    Function(String?) onChanged,
  ) {
    final isSelected = groupValue == title;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _C.terracottaLight : _C.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _C.terracotta : _C.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _C.terracotta.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _C.terracotta : _C.cardBorder,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _C.terracotta,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? _C.terracotta : _C.sand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? _C.white : _C.slate,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _C.terracotta : _C.charcoal,
                    ),
                    child: Text(title),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: isSelected ? _C.slate : _C.slateLight,
                    ),
                    child: Text(subtitle),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(dynamic product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.sand,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.image.isNotEmpty
                ? Image.network(
                    product.image[0],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: _C.parchment,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: _C.slate,
                      ),
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    color: _C.parchment,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: _C.slate,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _C.charcoal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${product.quantity}',
                  style: GoogleFonts.dmSans(fontSize: 11, color: _C.slate),
                ),
              ],
            ),
          ),
          Text(
            '${(product.productPrice * product.quantity).toStringAsFixed(2)} DA',
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w700,
              color: _C.terracotta,
              fontSize: 13,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}