import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/provider/cart_provider.dart';
import 'package:untitled/views/screens/main_screen.dart';
import 'package:untitled/views/screens/detail/screens/checkout_screen.dart';
import 'package:untitled/views/screens/nav_screens/widgets/empty_state_widget.dart';
import 'package:untitled/views/screens/nav_screens/widgets/modern_card_widget.dart';

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
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartData = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: _C.cream,
      appBar: AppBar(
        backgroundColor: _C.cream,
        elevation: 0,
        title: Text(
          'Shopping Cart',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: _C.charcoal,
            fontSize: 28,
            height: 1.1,
          ),
        ),
        centerTitle: false,
      ),
      body: cartData.isEmpty
          ? EmptyStateWidget(
              title: 'Your Cart is Empty',
              subtitle: 'Looks like you haven\'t added anything to your cart yet.',
              icon: Icons.shopping_cart_outlined,
              actionText: 'Start Shopping',
              onActionPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 0,)),
                (route) => false,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
              itemCount: cartData.length,
              itemBuilder: (context, index) {
                final product = cartData.values.elementAt(index);
                return _buildModernCartCard(product);
              },
            ),
      bottomNavigationBar: cartData.isNotEmpty ? _buildCheckoutSection(cartData) : null,
    );
  }

  Widget _buildModernCartCard(dynamic product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _C.ink.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 110,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              image: DecorationImage(
                image: NetworkImage(product.image[0]),
                fit: BoxFit.cover,
              ),
              color: _C.sand,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _C.charcoal,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.productPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: _C.terracotta,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onPressed: () {
                          if (product.quantity > 1) {
                            ref.read(cartProvider.notifier).decrementCartItem(product.productId);
                          } else {
                            ref.read(cartProvider.notifier).removeProductFromCart(product.productId);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          product.quantity.toString(),
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: _C.charcoal,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add,
                        onPressed: () => ref.read(cartProvider.notifier).IncrementCartItem(product.productId),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => ref.read(cartProvider.notifier).removeProductFromCart(product.productId),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _C.terracottaLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete_outline, color: _C.terracotta, size: 18),
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
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _C.sand,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _C.cardBorder, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, size: 14, color: _C.terracotta),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCheckoutSection(Map<String, dynamic> cartData) {
    final total = cartData.values.fold<double>(0, (sum, item) => sum + item.productPrice * item.quantity);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: _C.cardBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: _C.ink.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Price',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: _C.slate,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _C.terracotta,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.terracotta,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: _C.terracotta.withOpacity(0.25),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Checkout',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          color: _C.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: _C.white, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
