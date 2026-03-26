import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/views/screens/nav_screens/cart_screen.dart';
import 'package:untitled/views/screens/nav_screens/category_screen.dart';
import '../../../controllers/banner_controller.dart';
import '../../../controllers/category_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../models/banner_model.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../provider/banner_provider.dart';
import '../../../provider/category_provider.dart';
import '../../../provider/product_provider.dart';
import '../../../provider/cart_provider.dart';
import 'package:untitled/views/screens/detail/screens/product_detail_screen.dart';
import 'package:untitled/views/widgets/category_card_widget.dart';
import 'package:untitled/views/widgets/product_card_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';

// ── Design tokens ─────────────────────────────────────────────────────────
class _C {
  static const cream          = Color(0xFFF5F0E8);
  static const sand           = Color(0xFFEDE7D9);
  static const parchment      = Color(0xFFE5DDD0);
  static const terracotta     = Color(0xFFBF6B4A);
  static const terracottaLight = Color(0xFFF0D5C8);
  static const charcoal       = Color(0xFF1E1E1E);
  static const ink            = Color(0xFF2D2926);
  static const slate          = Color(0xFF6B6560);
  static const slateLight     = Color(0xFF9B948C);
  static const white          = Color(0xFFFFFFFF);
  static const cardBorder     = Color(0xFFDDD6CB);
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _categoryController = CategoryController();
  final _productController  = ProductController();
  final _bannerController   = BannerController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadCategories(), _loadPopularProducts(), _loadBanners()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadBanners() async {
    try {
      final b = await _bannerController.loadBanners();
      ref.read(bannerProvider.notifier).addBanner(b);
    } catch (e) { debugPrint('banners: $e'); }
  }

  Future<void> _loadCategories() async {
    try {
      final c = await _categoryController.loadCategories();
      ref.read(categoryProvider.notifier).setCategories(c);
    } catch (e) { debugPrint('categories: $e'); }
  }

  Future<void> _loadPopularProducts() async {
    try {
      final p = await _productController.loadPopularProduct();
      ref.read(productProvider.notifier).setProducts(p);
    } catch (e) { debugPrint('products: $e'); }
  }

  int _crossAxisCount(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w >= 1100) return 4;
    if (w >= 800)  return 3;
    return 2;
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final products   = ref.watch(productProvider);
    final banners    = ref.watch(bannerProvider);
    final cartData   = ref.watch(cartProvider);
    final cartCount  = cartData.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.cream,
        appBar: _buildAppBar(cartCount),
        body: RefreshIndicator(
          color: _C.terracotta,
          backgroundColor: _C.white,
          onRefresh: _loadInitialData,
          child: _isLoading
              ? _buildShimmer()
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildBanner(banners)),
                    if (categories.isNotEmpty) ...[
                      SliverToBoxAdapter(child: _sectionHeader('Categories', showSeeAll: false)),
                      SliverToBoxAdapter(child: _buildCategories(categories)),
                    ],
                    if (products.isNotEmpty) ...[
                      SliverToBoxAdapter(child: _sectionHeader('Trending Now')),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _crossAxisCount(context),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.62,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _buildProductCard(products[i]),
                            childCount: products.length.clamp(0, 12),
                          ),
                        ),
                      ),
                    ],
                    if (products.isEmpty)
                      SliverToBoxAdapter(child: _buildEmptyState()),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────

  AppBar _buildAppBar(int cartCount) {
    return AppBar(
      backgroundColor: _C.cream,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _C.slateLight,
              letterSpacing: 0.4,
            ),
          ),
          Text(
            'NOVA SHOP',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _C.ink,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: _C.ink, size: 24),
          onPressed: () => showSearch(
            context: context,
            delegate: ProductSearchDelegate(_productController),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: _C.ink, size: 24),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: _C.terracotta,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        cartCount > 9 ? '9+' : '$cartCount',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _C.cardBorder),
      ),
    );
  }

  // ── Banner ─────────────────────────────────────────────────────────────

  Widget _buildBanner(List<BannerModel> banners) {
    if (banners.isEmpty) return _defaultBanner();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: CarouselSlider.builder(
        itemCount: banners.length,
        itemBuilder: (ctx, i, _) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              banners[i].image,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => _defaultBanner(),
            ),
          ),
        ),
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          viewportFraction: 0.88,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayCurve: Curves.easeInOut,
        ),
      ),
    );
  }

  Widget _defaultBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBF6B4A), Color(0xFFD4825F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Subtle texture overlay — diagonal stripe pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(painter: _StripePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.terracotta,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'LIMITED TIME',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '20% OFF\nNew Collections',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SHOP NOW',
                        style: GoogleFonts.dmSans(
                          color: _C.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, color: _C.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────────────────

  Widget _sectionHeader(String title, {bool showSeeAll = true}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _C.terracotta,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Container(width: 32, height: 2, color: _C.terracotta),
              ],
            ),
          ),
          if (showSeeAll)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryScreen()),
              ),
              child: Text(
                'See all →',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: _C.slateLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Categories ─────────────────────────────────────────────────────────

  Widget _buildCategories(List<Category> categories) {
    return SizedBox(
      height: 108,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (ctx, i) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: CategoryCardWidget(
            category: categories[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryScreen(initialCategory: categories[i].name),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Product Card ───────────────────────────────────────────────────────

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.cardBorder),
          boxShadow: [
            BoxShadow(
              color: _C.ink.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.images.isNotEmpty
                        ? Image.network(
                            product.images[0],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const ColoredBox(color: _C.sand),
                          )
                        : const ColoredBox(color: _C.sand),
                    // Rating chip
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFE8A020), size: 12),
                            const SizedBox(width: 2),
                            Text(
                              product.averageRating.toStringAsFixed(1),
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _C.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Details
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _C.ink,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.productPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _C.terracotta,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _C.terracotta,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 16),
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

  // ── Empty state ────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.shopping_bag_outlined, size: 52, color: _C.slateLight),
          const SizedBox(height: 12),
          Text(
            'Nothing here yet',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              color: _C.slateLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pull down to refresh',
            style: GoogleFonts.dmSans(fontSize: 13, color: _C.slateLight),
          ),
        ],
      ),
    );
  }

  // ── Shimmer ────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5DDD0),
      highlightColor: const Color(0xFFF5F0E8),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
              child: Container(width: 80, height: 14, color: Colors.white),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 108,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (_, __) => Container(
                  width: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 10),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount(context),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, __) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                childCount: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ── Stripe background painter ──────────────────────────────────────────────
class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke;
    for (double i = -size.height; i < size.width + size.height; i += 36) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => false;
}

// ── Search Delegate ────────────────────────────────────────────────────────

class ProductSearchDelegate extends SearchDelegate<Product?> {
  final ProductController controller;
  ProductSearchDelegate(this.controller);

  @override
  String get searchFieldLabel => 'Search products...';

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
        scaffoldBackgroundColor: _C.cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: _C.cream,
          elevation: 0,
          iconTheme: IconThemeData(color: _C.ink),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: GoogleFonts.dmSans(color: _C.slateLight),
          border: InputBorder.none,
        ),
      );

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: _C.ink),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back, color: _C.ink),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      color: _C.cream,
      child: FutureBuilder<List<Product>>(
        future: controller.searchProducts(query),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _C.terracotta));
          }
          final results = snap.data ?? [];
          if (results.isEmpty) {
            return Center(
              child: Text('No results for "$query"',
                  style: GoogleFonts.dmSans(color: _C.slateLight)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (MediaQuery.of(ctx).size.width ~/ 200).clamp(2, 4),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: results.length,
            itemBuilder: (ctx, i) => ProductCardWidget(
              product: results[i],
              onTap: () => Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: results[i])),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container(
        color: _C.cream,
        child: Center(
          child: Text(
            'Try "shoes", "phones", "bags"',
            style: GoogleFonts.dmSans(color: _C.slateLight, fontSize: 14),
          ),
        ),
      );
    }
    return Container(
      color: _C.cream,
      child: FutureBuilder<List<Product>>(
        future: controller.searchProducts(query),
        builder: (ctx, snap) {
          final list = snap.data ?? [];
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: _C.cardBorder),
            itemBuilder: (ctx, i) {
              final p = list[i];
              return ListTile(
                tileColor: _C.cream,
                leading: p.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(p.images[0],
                            width: 44, height: 44, fit: BoxFit.cover),
                      )
                    : const SizedBox(width: 44),
                title: Text(p.productName,
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600, color: _C.ink)),
                subtitle: Text('\$${p.productPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.dmSans(color: _C.terracotta, fontWeight: FontWeight.w700)),
                trailing: const Icon(Icons.north_west, size: 16, color: _C.slateLight),
                onTap: () {
                  close(context, p);
                  Navigator.push(ctx,
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
                },
              );
            },
          );
        },
      ),
    );
  }
}