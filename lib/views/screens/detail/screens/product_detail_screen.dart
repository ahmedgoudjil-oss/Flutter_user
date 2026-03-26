import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/controllers/product_controller.dart';
import 'package:untitled/controllers/product_review_controller.dart';
import 'package:untitled/models/product.dart';
import 'package:untitled/provider/cart_provider.dart';
import 'package:untitled/provider/favorite_provider.dart';
import 'package:untitled/provider/related_product_provider.dart';
import 'package:untitled/provider/user_provider.dart';
import 'package:untitled/views/screens/detail/screens/product_detail_screen.dart'
    as detail_importer; // avoid analyzer conflict
// ignore: unused_import
import 'package:untitled/views/screens/nav_screens/widgets/reusable_text_widget.dart';

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

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with TickerProviderStateMixin {
  final ProductController _productController = ProductController();
  final ProductReviewController _productReviewController =
      ProductReviewController();

  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _scaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  final PageController _pageController = PageController();
  final Set<int> _loadedImageIndices = {}; // track loaded images
  int _selectedImageIndex = 0;
  bool _isLoadingRelatedProducts = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();

    _checkAndFetchProducts();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _checkAndFetchProducts() {
    final products = ref.read(relatedProductProvider);
    if (products.isEmpty) {
      _fetchRelatedProducts();
    }
  }

  Future<void> _fetchRelatedProducts() async {
    if (_isLoadingRelatedProducts) return;

    setState(() {
      _isLoadingRelatedProducts = true;
    });

    try {
      final relatedProducts = await _productController
          .loadRelatedProductBySubCategory(widget.product.id);

      if (relatedProducts.isNotEmpty) {
        ref.read(relatedProductProvider.notifier).setProducts(relatedProducts);
      } else {
        final popular = await _productController.loadPopularProduct();
        final filtered = popular
            .where((p) => p.id != widget.product.id)
            .toList();
        ref.read(relatedProductProvider.notifier).setProducts(filtered);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to load related products');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRelatedProducts = false;
        });
      }
    }
  }

  Future<void> _addToCart() async {
    HapticFeedback.lightImpact();
    final cartNotifier = ref.read(cartProvider.notifier);
    try {
      cartNotifier.addProductToCart(
        productId: widget.product.id,
        productName: widget.product.productName,
        productPrice: widget.product.productPrice,
        category: widget.product.category,
        image: widget.product.images,
        vendorId: widget.product.vendorId,
        productQuantity: widget.product.quantity,
        quantity: 1,
        description: widget.product.description,
        fullName: widget.product.fullName,
      );
      _showSnackBar('${widget.product.productName} added to cart');
    } catch (e) {
      _showSnackBar('Failed to add to cart');
    }
  }

  Future<void> _toggleFavorite() async {
    HapticFeedback.selectionClick();
    final favNotifier = ref.read(FavoriteProvider.notifier);
    final isFav = ref.read(FavoriteProvider).containsKey(widget.product.id);

    if (isFav) {
      favNotifier.removeProductFromFavorite(widget.product.id);
      _showSnackBar('${widget.product.productName} removed from favorites');
    } else {
      favNotifier.addProductToFavorites(
        productId: widget.product.id,
        productName: widget.product.productName,
        productPrice: widget.product.productPrice,
        category: widget.product.category,
        image: widget.product.images,
        vendorId: widget.product.vendorId,
        productQuantity: widget.product.quantity,
        quantity: 1,
        description: widget.product.description,
        fullName: widget.product.fullName,
      );
      _showSnackBar('${widget.product.productName} added to favorites');
    }
  }

  void _openReviewDialog() {
    final user = ref.read(userProvider);
    if (user == null || user.id.isEmpty) {
      _showSnackBar('Please login to review this product');
      return;
    }

    double reviewRating = 5.0;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: _C.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Write a Review',
                style: GoogleFonts.playfairDisplay(
                  color: _C.charcoal,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => IconButton(
                          icon: Icon(
                            index < reviewRating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color(0xFFD4A843),
                          ),
                          onPressed: () {
                            setState(() {
                              reviewRating = (index + 1).toDouble();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reviewController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Write your review here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: _C.sand,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.dmSans(color: _C.slate),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.terracotta,
                  ),
                  onPressed: () async {
                    final reviewText = reviewController.text.trim();
                    if (reviewText.isEmpty) {
                      _showSnackBar('Please write a review');
                      return;
                    }

                    await _productReviewController.uploadReview(
                      buyerId: user.id,
                      email: user.email,
                      fullName: user.fullName,
                      productId: widget.product.id,
                      rating: reviewRating,
                      review: reviewText,
                      context: context,
                    );

                    if (mounted) {
                      Navigator.of(dialogContext).pop();
                    }
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
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.dmSans(
              color: _C.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: _C.charcoal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(14),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
        ),
      );
  }

  Widget _buildImagePage(int index) {
    final url = (index < widget.product.images.length)
        ? widget.product.images[index]
        : '';
    return GestureDetector(
      onTap: () {
        // optional: expand image or open gallery
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                // mark image as loaded -- defer to post frame to avoid setState during build
                if (!_loadedImageIndices.contains(index)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() => _loadedImageIndices.add(index));
                  });
                }
                return child;
              }
              return Container(
                decoration: const BoxDecoration(color: _C.sand),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      _C.slateLight,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, st) {
              return Container(
                color: _C.sand,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.broken_image,
                        size: 64,
                        color: _C.slateLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Unable to load image',
                        style: GoogleFonts.dmSans(
                          color: _C.slate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (!_loadedImageIndices.contains(index))
            Container(color: Colors.black.withOpacity(0.06)),
        ],
      ),
    );
  }

  Widget _buildThumbnails() {
    final images = widget.product.images;
    if (images.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
      child: SizedBox(
        height: 66,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, i) {
            final imageUrl = images[i];
            final isActive = i == _selectedImageIndex;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                // defer visual update after current frame to avoid markNeedsBuild during build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() {
                    _selectedImageIndex = i;
                  });
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.only(right: i == images.length - 1 ? 0 : 12),
                width: isActive ? 68 : 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive ? _C.terracotta : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _C.charcoal.withOpacity(isActive ? 0.14 : 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    // Format price with two decimals and space as thousands separator for readability
    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final relatedProducts = ref.watch(relatedProductProvider);
    final favoritesMap = ref.watch(FavoriteProvider);
    final isFavorite = favoritesMap.containsKey(widget.product.id);

    return Scaffold(
      backgroundColor: _C.cream,
      appBar: AppBar(
        backgroundColor: _C.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: _C.charcoal),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            widget.product.productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: _C.charcoal,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add to cart',
            onPressed: _addToCart,
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: _C.terracotta,
            ),
          ),
          IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? _C.terracotta : _C.charcoal,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Image hero section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: _C.cardBorder,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _C.charcoal.withOpacity(0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: Stack(
                                  children: [
                                    PageView.builder(
                                      controller: _pageController,
                                      itemCount: widget.product.images.length,
                                      onPageChanged: (index) {
                                        // defer update to avoid calling setState during the build phase
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (!mounted) return;
                                              setState(
                                                () =>
                                                    _selectedImageIndex = index,
                                              );
                                            });
                                      },
                                      itemBuilder: (context, index) =>
                                          _buildImagePage(index),
                                    ),
                                    // position count
                                    Positioned(
                                      left: 14,
                                      top: 14,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _C.charcoal.withOpacity(0.72),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${_selectedImageIndex + 1}/${widget.product.images.length}',
                                          style: GoogleFonts.dmSans(
                                            color: _C.cream,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                    ),
                  ),

                  // thumbnails
                  _buildThumbnails(),

                  // Product info card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _C.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _C.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: _C.charcoal.withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // title + price
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.product.productName,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: _C.charcoal,
                                      height: 1.05,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _C.terracotta,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${_formatPrice(widget.product.productPrice.toDouble())} DA',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 18,
                                      color: _C.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // rating row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _C.sand,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Color(0xFFFFB74D),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.product.totalRatings > 0
                                            ? widget.product.averageRating
                                                  .toStringAsFixed(1)
                                            : '—',
                                        style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.w700,
                                          color: _C.charcoal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (widget.product.totalRatings > 0)
                                  Text(
                                    '${widget.product.totalRatings} reviews',
                                    style: GoogleFonts.dmSans(color: _C.slate),
                                  ),
                                const Spacer(),
                                Text(
                                  widget.product.category,
                                  style: GoogleFonts.dmSans(
                                    color: _C.slate,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: _openReviewDialog,
                                icon: const Icon(
                                  Icons.rate_review,
                                  color: _C.terracotta,
                                ),
                                label: Text(
                                  'Write Review',
                                  style: GoogleFonts.dmSans(
                                    color: _C.terracotta,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: _C.terracottaLight,
                                  ),
                                  backgroundColor: _C.terracottaLight
                                      .withOpacity(0.35),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // vendor row
                            Row(
                              children: [
                                const Icon(
                                  Icons.storefront_outlined,
                                  color: _C.terracotta,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vendor',
                                        style: GoogleFonts.dmSans(
                                          color: _C.slate,
                                        ),
                                      ),
                                      Text(
                                        widget.product.fullName,
                                        style: GoogleFonts.dmSans(
                                          color: _C.charcoal,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // description
                            Text(
                              'Description',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _C.charcoal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.product.description,
                              style: GoogleFonts.dmSans(
                                color: _C.slate,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // related products header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Text(
                          'Related Products',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _C.charcoal,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoadingRelatedProducts)
                          Text(
                            'Loading...',
                            style: GoogleFonts.dmSans(color: _C.slate),
                          ),
                        if (!_isLoadingRelatedProducts)
                          Text(
                            '${relatedProducts.length} items',
                            style: GoogleFonts.dmSans(color: _C.slate),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // related products list
                  SizedBox(
                    height: 300,
                    child: _isLoadingRelatedProducts
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: _C.terracotta,
                            ),
                          )
                        : relatedProducts.isEmpty
                        ? Center(
                            child: Text(
                              'No related products',
                              style: GoogleFonts.dmSans(color: _C.slate),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: relatedProducts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final p = relatedProducts[index];
                              return _RelatedProductCard(
                                product: p,
                                onAdd: () async {
                                  ref
                                      .read(cartProvider.notifier)
                                      .addProductToCart(
                                        productId: p.id,
                                        productName: p.productName,
                                        productPrice: p.productPrice,
                                        category: p.category,
                                        image: p.images,
                                        vendorId: p.vendorId,
                                        productQuantity: p.quantity,
                                        quantity: 1,
                                        description: p.description,
                                        fullName: p.fullName,
                                      );
                                  _showSnackBar(
                                    '${p.productName} added to cart',
                                  );
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductDetailScreen(product: p),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
                ],
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: _C.cardBorder),
            boxShadow: [
              BoxShadow(
                color: _C.charcoal.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _C.terracotta,
                  ),
                  label: Text(
                    isFavorite ? 'Remove' : 'Favorite',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      color: _C.terracotta,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _C.terracottaLight),
                    backgroundColor: _C.terracottaLight.withOpacity(0.35),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(
                    Icons.add_shopping_cart_rounded,
                    color: _C.white,
                  ),
                  label: Text(
                    'Add to Cart',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      color: _C.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: _C.terracotta,
                    elevation: 6,
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

class _RelatedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final Future<void> Function() onAdd;

  const _RelatedProductCard({
    required this.product,
    required this.onAdd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.cardBorder),
            boxShadow: [
              BoxShadow(
                color: _C.charcoal.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    product.images.isNotEmpty ? product.images[0] : '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _C.sand,
                      child: const Icon(
                        Icons.broken_image,
                        color: _C.slateLight,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.w700,
                        color: _C.charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${product.productPrice.toStringAsFixed(2)} DA',
                          style: GoogleFonts.playfairDisplay(
                            color: _C.charcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: _C.terracotta,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () => onAdd(),
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              color: _C.white,
                              size: 18,
                            ),
                            tooltip: 'Add to cart',
                          ),
                        ),
                      ],
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
}
