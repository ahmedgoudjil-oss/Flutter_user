import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/models/product.dart';
import 'package:untitled/provider/favorite_provider.dart';
import 'package:untitled/provider/cart_provider.dart';
import 'package:untitled/views/screens/main_screen.dart';
import 'package:untitled/views/screens/detail/screens/product_detail_screen.dart';

// ── Color tokens ─────────────────────────────────────────────────────────────
class _C {
  static const cream     = Color(0xFFF5F0E8);
  static const sand      = Color(0xFFEDE7D9);
  static const parchment = Color(0xFFE5DDD0);
  static const terracotta= Color(0xFFBF6B4A);
  static const terracottaLight = Color(0xFFF0D5C8);
  static const charcoal  = Color(0xFF1E1E1E);
  static const ink       = Color(0xFF2D2926);
  static const slate     = Color(0xFF6B6560);
  static const slateLight= Color(0xFF9B948C);
  static const white     = Color(0xFFFFFFFF);
  static const cardBorder= Color(0xFFDDD6CB);
}

class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});

  @override
  ConsumerState<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen>
    with TickerProviderStateMixin {

  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerFade;
  late Animation<double> _listFade;
  late Animation<Offset> _listSlide;

  final Set<String> _removingIds = {};

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: _C.cream,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _listFade = CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOut,
    );
    _listSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _listController, curve: Curves.easeOutCubic));

    _headerController.forward().then((_) => _listController.forward());
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _removeItem(String productId) async {
    setState(() => _removingIds.add(productId));
    await Future.delayed(const Duration(milliseconds: 350));
    ref.read(FavoriteProvider.notifier).removeProductFromFavorite(productId);
    setState(() => _removingIds.remove(productId));
  }

  @override
  Widget build(BuildContext context) {
    final wishItemData = ref.watch(FavoriteProvider);
    final count = wishItemData.length;

    return Scaffold(
      backgroundColor: _C.cream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _headerFade,
              child: _buildHeader(count),
            ),
          ),

          // ── Content ────────────────────────────────────────
          if (wishItemData.isEmpty)
            SliverFillRemaining(
              child: FadeTransition(
                opacity: _listFade,
                child: _buildEmptyState(),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = wishItemData.values.elementAt(index);
                    final product = _toProduct(item);
                    final isRemoving = _removingIds.contains(item.productId);

                    return FadeTransition(
                      opacity: _listFade,
                      child: SlideTransition(
                        position: _listSlide,
                        child: AnimatedOpacity(
                          opacity: isRemoving ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: EdgeInsets.only(
                              top: index == 0 ? 8 : 0,
                              bottom: 16,
                            ),
                            child: _FavoriteCard(
                              item: item,
                              product: product,
                              onRemove: () => _removeItem(item.productId),
                              onAddToCart: () => _addToCart(product),
                              onTap: () => Navigator.push(
                                context,
                                _pageRoute(ProductDetailScreen(product: product)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: wishItemData.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      color: _C.cream,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _C.sand,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.cardBorder, width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: _C.ink,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _C.terracottaLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: _C.terracotta, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '$count saved',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.terracotta,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Title
          Text(
            'Saved\nItems',
            style: GoogleFonts.playfairDisplay(
              fontSize: 44,
              fontWeight: FontWeight.w700,
              color: _C.charcoal,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Decorative rule
          Row(
            children: [
              Container(width: 32, height: 2, color: _C.terracotta),
              const SizedBox(width: 8),
              Container(width: 8, height: 2, color: _C.terracotta.withOpacity(0.4)),
              const SizedBox(width: 6),
              Container(width: 4, height: 2, color: _C.terracotta.withOpacity(0.2)),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            'Your curated collection',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: _C.slateLight,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _C.sand,
                shape: BoxShape.circle,
                border: Border.all(color: _C.cardBorder, width: 1.5),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 40,
                color: _C.slateLight,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Nothing here yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: _C.charcoal,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the heart on any product to save it to your collection.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: _C.slateLight,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 36),
            GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                _pageRoute(const MainScreen(initialIndex: 0)),
                (route) => false,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: _C.terracotta,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _C.terracotta.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  'Explore Products',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    ref.read(cartProvider.notifier).addProductToCart(
      productId: product.id,
      productName: product.productName,
      productPrice: product.productPrice,
      productQuantity: product.quantity,
      quantity: 1,
      description: product.description,
      category: product.category,
      vendorId: product.vendorId,
      fullName: product.fullName,
      image: product.images,
    );
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _C.charcoal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: _C.terracotta, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${product.productName} added to cart',
                  style: GoogleFonts.dmSans(
                    color: _C.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Product _toProduct(dynamic item) => Product(
        id: item.productId,
        productName: item.productName,
        productPrice: item.productPrice,
        quantity: item.productQuantity,
        description: item.description,
        category: item.category,
        vendorId: item.vendorId,
        fullName: item.fullName,
        subCategory: '',
        images: List<String>.from(item.image ?? []),
        averageRating: item.averageRating ?? 4.5,
        totalRatings: item.totalRatings ?? 0,
      );

  PageRoute _pageRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, anim, __) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      );
}

// ── Favorite Card ─────────────────────────────────────────────────────────────
class _FavoriteCard extends StatefulWidget {
  final dynamic item;
  final Product product;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const _FavoriteCard({
    required this.item,
    required this.product,
    required this.onRemove,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  State<_FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<_FavoriteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = (widget.item.image != null && widget.item.image.isNotEmpty)
        ? widget.item.image[0] as String
        : null;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _hoverController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _hoverController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _elevation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            transform: Matrix4.identity()
              ..scale(_isPressed ? 0.985 : 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _C.cardBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: _C.ink.withOpacity(0.06 + _elevation.value * 0.04),
                  blurRadius: 16 + _elevation.value * 8,
                  offset: Offset(0, 4 + _elevation.value * 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ───────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              child: SizedBox(
                width: 130,
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: _C.sand,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: _C.slateLight,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: _C.sand,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 32,
                            color: _C.slateLight,
                          ),
                        ),
                      )
                    else
                      Container(
                        color: _C.sand,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 32,
                          color: _C.slateLight,
                        ),
                      ),

                    // Category badge
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _C.ink.withOpacity(0.72),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.product.category.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _C.cream,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Details ─────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: brand + remove
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.fullName ?? '',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: _C.slateLight,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Remove button
                        GestureDetector(
                          onTap: widget.onRemove,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _C.terracottaLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: _C.terracotta,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Product name
                    Text(
                      widget.item.productName ?? '',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _C.charcoal,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Rating row
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          final rating = widget.product.averageRating;
                          return Icon(
                            i < rating.floor()
                                ? Icons.star_rounded
                                : (i < rating
                                    ? Icons.star_half_rounded
                                    : Icons.star_outline_rounded),
                            size: 13,
                            color: const Color(0xFFD4A843),
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          widget.product.averageRating.toStringAsFixed(1),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: _C.slate,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${widget.product.totalRatings})',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: _C.slateLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Price + cart button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: _C.slateLight,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '\$${(widget.item.productPrice ?? 0).toStringAsFixed(2)}',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _C.charcoal,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),

                        // Add to cart pill
                        GestureDetector(
                          onTap: widget.onAddToCart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _C.terracotta,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _C.terracotta.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_shopping_cart_rounded,
                                  color: _C.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Add',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _C.white,
                                  ),
                                ),
                              ],
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
    );
  }
}