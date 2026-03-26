// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/controllers/order_controller.dart';
import 'package:untitled/controllers/product_review_controller.dart';
import 'package:untitled/models/order.dart';

class _C {
  static const cream = Color(0xFFF5F0E8);
  static const sand = Color(0xFFEDE7D9);
  static const terracotta = Color(0xFFBF6B4A);
  static const terracottaLight = Color(0xFFF0D5C8);
  static const charcoal = Color(0xFF1E1E1E);
  static const slate = Color(0xFF6B6560);
  static const slateLight = Color(0xFF9B948C);
  static const white = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFDDD6CB);
}

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ProductReviewController productReviewController =
      ProductReviewController();

  String _statusLabel(Order order) {
    if (order.delivered) return 'Delivered';
    if (order.processing) return 'Processing';
    return 'Pending';
  }

  Color _statusColor(Order order) {
    if (order.delivered) return _C.charcoal;
    if (order.processing) return _C.slate;
    return _C.terracotta;
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final statusColor = _statusColor(order);

    return Scaffold(
      backgroundColor: _C.cream,
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: _C.charcoal,
          ),
        ),
        backgroundColor: _C.cream,
        foregroundColor: _C.charcoal,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: _C.terracotta),
            tooltip: 'Delete Order',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: _C.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: _C.cardBorder),
                  ),
                  title: Text(
                    'Delete Order',
                    style: GoogleFonts.playfairDisplay(
                      color: _C.charcoal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to delete this order?',
                    style: GoogleFonts.dmSans(color: _C.slate),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.dmSans(color: _C.slate),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.dmSans(
                          color: _C.terracotta,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                // Call controller to delete order
                final controller = OrderController();
                await controller.deleteOrderById(
                  id: order.id,
                  context: context,
                );
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: _C.charcoal,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      content: Row(
                        children: [
                          const Icon(
                            Icons.delete_forever,
                            color: _C.terracotta,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Order deleted',
                              style: GoogleFonts.dmSans(
                                color: _C.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _C.cardBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: _C.charcoal.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: order.image.isNotEmpty
                      ? Image.network(order.image, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 80, color: _C.slateLight),
                ),
              ),
              const SizedBox(height: 24),
              // Product Name
              Text(
                order.productName,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: _C.charcoal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Category
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _C.sand,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _C.cardBorder, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.category, size: 16, color: _C.slate),
                    const SizedBox(width: 6),
                    Text(
                      order.category,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _C.slate,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Price & Quantity
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _C.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _C.cardBorder, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Price',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: _C.slate,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${order.productPrice}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            color: _C.charcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: _C.cardBorder),
                    Column(
                      children: [
                        Text(
                          'Quantity',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: _C.slate,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.quantity}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            color: _C.charcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Delivery Address
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                  child: Text(
                    'Delivery Address',
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: _C.charcoal,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _C.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _C.cardBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.person, 'Name', order.fullName),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.location_on,
                      'Address',
                      '${order.state}, ${order.city}, ${order.locality}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Status
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _C.terracottaLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _C.cardBorder, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      order.delivered
                          ? Icons.check_circle
                          : Icons.local_shipping,
                      color: statusColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _statusLabel(order),
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (order.delivered == true)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.terracotta,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.rate_review, color: _C.white),
                    label: Text(
                      'Leave a Review',
                      style: GoogleFonts.dmSans(
                        color: _C.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      double _reviewRating = 5.0;
                      TextEditingController _reviewController =
                          TextEditingController();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                backgroundColor: _C.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Row(
                                  children: [
                                    const Icon(
                                      Icons.rate_review,
                                      color: _C.terracotta,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Leave a Review',
                                      style: GoogleFonts.playfairDisplay(
                                        color: _C.charcoal,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rating:',
                                        style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.w700,
                                          color: _C.charcoal,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          5,
                                          (index) => IconButton(
                                            icon: Icon(
                                              index < _reviewRating.round()
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: const Color(0xFFD4A843),
                                              size: 32,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _reviewRating = (index + 1)
                                                    .toDouble();
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Your Review:',
                                        style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.w700,
                                          color: _C.charcoal,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _reviewController,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          hintText: 'Write your review here...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: _C.sand,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.dmSans(
                                        color: _C.slate,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _C.terracotta,
                                    ),
                                    onPressed: () async {
                                      // Here you would save the review
                                      await productReviewController
                                          .uploadReview(
                                            buyerId: order.buyerId,
                                            email: order.email,
                                            fullName: order.fullName,
                                            productId: order.productId,
                                            rating: _reviewRating,
                                            review: _reviewController.text,
                                            context: context,
                                          )
                                          .whenComplete(() {
                                            Navigator.of(context).pop();
                                          });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Thank you for your review!',
                                            style: GoogleFonts.dmSans(
                                              color: _C.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor: _C.charcoal,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Submit',
                                      style: GoogleFonts.dmSans(
                                        color: _C.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              // Buyer & Vendor IDs (optional, for admin/info)
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _C.slate),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(fontSize: 12, color: _C.slateLight),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _C.charcoal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
