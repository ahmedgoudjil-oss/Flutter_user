// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/controllers/order_controller.dart';
import 'package:untitled/models/order.dart';
import 'package:untitled/models/user.dart';
import 'package:untitled/provider/order_provider.dart';
import 'package:untitled/provider/user_provider.dart';
import 'package:untitled/views/screens/detail/screens/order_detail_screen.dart';

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

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  ProviderSubscription<User?>? _userSubscription;

  Color _statusColor(bool delivered, bool processing) {
    if (delivered) return _C.charcoal;
    if (processing) return _C.slate;
    return _C.terracotta;
  }

  @override
  void initState() {
    super.initState();

    _userSubscription = ref.listenManual<User?>(userProvider, (previous, next) {
      final previousId = previous?.id.trim() ?? '';
      final nextId = next?.id.trim() ?? '';

      if (nextId.isEmpty) {
        ref.read(orderProvider.notifier).clearOrders();
        return;
      }

      if (nextId != previousId) {
        _fetchOrders();
      }
    });

    _fetchOrders();
  }

  @override
  void dispose() {
    _userSubscription?.close();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    final user = ref.read(userProvider);
    final buyerId = user?.id.trim() ?? '';

    if (buyerId.isEmpty) {
      return;
    }

    final OrderController orderController = OrderController();
    try {
      final orders = await orderController.getOrdersByBuyerId(buyerId: buyerId);
      if (!mounted) return;
      ref.read(orderProvider.notifier).setOrders(orders);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _C.cream,
        iconTheme: const IconThemeData(color: _C.charcoal),
        title: Text(
          'My Orders',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _C.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: _C.cream,
      body: Column(
        children: [
          // User info header (if available)
          if (user != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: _C.sand,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border.all(color: _C.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: _C.charcoal.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _C.terracottaLight,
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: _C.terracotta,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.fullName,
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _C.charcoal,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _C.terracotta,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.list_alt,
                                    size: 16,
                                    color: _C.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${orders.length} Orders',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: _C.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: _C.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: _C.slateLight,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No orders found',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _C.charcoal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You haven\'t placed any orders yet.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: _C.slate,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildOrderList(orders),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    // Separate orders by status
    final pendingOrders = orders
        .where((order) => !order.delivered && !order.processing)
        .toList();
    final processingOrders = orders
        .where((order) => order.processing && !order.delivered)
        .toList();
    final deliveredOrders = orders.where((order) => order.delivered).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Pending Orders Section
        if (pendingOrders.isNotEmpty) ...[
          _buildSectionHeader(
            'Pending Orders',
            pendingOrders.length,
            _C.terracotta,
          ),
          ...pendingOrders.map((order) => _buildOrderCard(order)).toList(),
          const SizedBox(height: 20),
        ],

        // Processing Orders Section
        if (processingOrders.isNotEmpty) ...[
          _buildSectionHeader(
            'Processing Orders',
            processingOrders.length,
            _C.slate,
          ),
          ...processingOrders.map((order) => _buildOrderCard(order)).toList(),
          const SizedBox(height: 20),
        ],

        // Delivered Orders Section
        if (deliveredOrders.isNotEmpty) ...[
          _buildSectionHeader(
            'Delivered Orders',
            deliveredOrders.length,
            _C.charcoal,
          ),
          ...deliveredOrders.map((order) => _buildOrderCard(order)).toList(),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _C.charcoal,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _statusColor(order.delivered, order.processing);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: _C.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: _C.cardBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          leading: order.image.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    order.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image, size: 40, color: _C.slateLight),
                  ),
                )
              : Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _C.sand,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image,
                    size: 40,
                    color: _C.slateLight,
                  ),
                ),
          title: Text(
            order.productName,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.charcoal,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.category, size: 14, color: _C.slateLight),
                  const SizedBox(width: 4),
                  Text(
                    order.category,
                    style: GoogleFonts.dmSans(fontSize: 13, color: _C.slate),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    size: 14,
                    color: _C.terracotta,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Price: ${order.productPrice}',
                    style: GoogleFonts.dmSans(fontSize: 13, color: _C.charcoal),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.shopping_cart,
                    size: 14,
                    color: _C.terracotta,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Qty: ${order.quantity}',
                    style: GoogleFonts.dmSans(fontSize: 13, color: _C.slate),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: _C.terracotta),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${order.state}, ${order.city}, ${order.locality}',
                      style: GoogleFonts.dmSans(fontSize: 13, color: _C.slate),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    order.delivered ? Icons.check_circle : Icons.local_shipping,
                    size: 14,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.delivered
                        ? 'Delivered'
                        : (order.processing ? 'Processing' : 'Pending'),
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    // Remove order from provider
                    final notifier = ref.read(orderProvider.notifier);
                    notifier.removeOrderById(order.id);
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
                },
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: _C.slateLight,
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              ),
            );
          },
        ),
      ),
    );
  }
}
