import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/models/subcategory.dart';
import 'package:untitled/models/product.dart';
import 'package:untitled/controllers/product_controller.dart';
import 'package:untitled/provider/cart_provider.dart';
import 'package:untitled/provider/favorite_provider.dart';
import 'package:untitled/provider/subcategory_product_provider.dart';
import 'package:untitled/views/screens/detail/screens/product_detail_screen.dart';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
//  Sort + Filter Models
// ─────────────────────────────────────────────
enum SortOption { bestMatch, priceLow, priceHigh, topRated }

extension SortLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.bestMatch:   return 'Best match';
      case SortOption.priceLow:   return 'Price: low';
      case SortOption.priceHigh:  return 'Price: high';
      case SortOption.topRated:   return 'Top rated';
    }
  }
}

const _filters = ['All', 'In stock', 'Top rated', 'Budget'];

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class SubcategoryProductScreen extends ConsumerStatefulWidget {
  final Subcategory subcategory;
  const SubcategoryProductScreen({super.key, required this.subcategory});

  @override
  ConsumerState<SubcategoryProductScreen> createState() =>
      _SubcategoryProductScreenState();
}

class _SubcategoryProductScreenState
    extends ConsumerState<SubcategoryProductScreen>
    with SingleTickerProviderStateMixin {
  final ProductController _productController = ProductController();

  bool _isLoading = true;
  String _activeFilter = 'All';
  SortOption _sort = SortOption.bestMatch;
  bool _isGridView = true;

  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380), value: 1.0);
    _fetchProducts();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final products = await _productController
          .loadProductBySubCategory(widget.subcategory.subCategoryName);
      if (!mounted) return;
      ref.read(subcategoryProductProvider.notifier).setProducts(products);
    } catch (_) {
      if (!mounted) return;
      ref.read(subcategoryProductProvider.notifier).setProducts([]);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1300),
        ),
      );
  }

  void _openProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _addToCart(Product product) {
    ref.read(cartProvider.notifier).addProductToCart(
          productId: product.id,
          productName: product.productName,
          productPrice: product.productPrice,
          category: product.category,
          image: product.images,
          vendorId: product.vendorId,
          productQuantity: product.quantity,
          quantity: 1,
          description: product.description,
          fullName: product.fullName,
        );
    _showSnack('${product.productName} added to cart');
  }

  void _toggleFavorite(Product product) {
    final favNotifier = ref.read(FavoriteProvider.notifier);
    final isFavorite = ref.read(FavoriteProvider).containsKey(product.id);

    if (isFavorite) {
      favNotifier.removeProductFromFavorite(product.id);
      _showSnack('${product.productName} removed from favorites');
      return;
    }

    favNotifier.addProductToFavorites(
      productId: product.id,
      productName: product.productName,
      productPrice: product.productPrice,
      category: product.category,
      image: product.images,
      vendorId: product.vendorId,
      productQuantity: product.quantity,
      quantity: 1,
      description: product.description,
      fullName: product.fullName,
      averageRating: product.averageRating,
      totalRatings: product.totalRatings,
    );
    _showSnack('${product.productName} added to favorites');
  }

  // ── filtering + sorting ─────────────────────
  List<Product> _process(List<Product> raw) {
    List<Product> items = [...raw];
    switch (_activeFilter) {
      case 'In stock':
        items = items.where((product) => product.quantity > 0).toList();
        break;
      case 'Top rated':
        items = items.where((product) => product.averageRating >= 4.0).toList();
        break;
      case 'Budget':
        items = items.where((product) => product.productPrice <= 100).toList();
        break;
      default:
        break;
    }

    // sort
    switch (_sort) {
      case SortOption.priceLow:
        items.sort((a, b) => (a.productPrice).compareTo(b.productPrice));
        break;
      case SortOption.priceHigh:
        items.sort((a, b) => (b.productPrice).compareTo(a.productPrice));
        break;
      case SortOption.topRated:
        items.sort((a, b) {
          final byRating = b.averageRating.compareTo(a.averageRating);
          if (byRating != 0) return byRating;
          return b.totalRatings.compareTo(a.totalRatings);
        });
        break;
      case SortOption.bestMatch:
        items.sort((a, b) {
          final scoreA = (a.averageRating * a.totalRatings);
          final scoreB = (b.averageRating * b.totalRatings);
          return scoreB.compareTo(scoreA);
        });
        break;
    }
    return items;
  }

  void _setSort(SortOption value) {
    if (_sort == value) return;
    setState(() => _sort = value);
    _fadeCtrl.forward(from: 0);
  }

  void _setFilter(String f) {
    if (_activeFilter == f) return;
    setState(() => _activeFilter = f);
    _fadeCtrl.forward(from: 0);
  }

  int _crossAxisCount(double width) {
    if (!_isGridView) return 1;
    if (width >= 1100) return 4;
    if (width >= 700) return 3;
    return 2;
  }

  double _childAspectRatio(double width) {
    if (!_isGridView) return 4.0;
    return width >= 700 ? 0.72 : 0.68;
  }

  // ── build ───────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final allProducts = ref.watch(subcategoryProductProvider);
    final favorites = ref.watch(FavoriteProvider);
    final cartItems = ref.watch(cartProvider);
    final products = _process(allProducts);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _C.cream,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerScrolled) => [
          _buildAppBar(innerScrolled),
          _buildFilterBar(),
          _buildStatsBar(products.length),
        ],
        body: _isLoading
            ? _LoadingShimmer(crossAxisCount: _crossAxisCount(size.width))
            : products.isEmpty
                ? _EmptyState(onRefresh: _fetchProducts)
                : RefreshIndicator(
                    color: _C.terracotta,
                    onRefresh: _fetchProducts,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      slivers: [
                        SliverFadeTransition(
                          opacity: _fadeCtrl,
                          sliver: SliverPadding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _crossAxisCount(size.width),
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio:
                                    _childAspectRatio(size.width),
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) {
                                  final product = products[i];
                                  return _ProductCard(
                                    product: product,
                                    isListView: !_isGridView,
                                    isFavorite: favorites.containsKey(product.id),
                                    isInCart: cartItems.containsKey(product.id),
                                    onTap: () => _openProductDetail(product),
                                    onAddToCart: () => _addToCart(product),
                                    onToggleFavorite: () => _toggleFavorite(product),
                                  );
                                },
                                childCount: products.length,
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ── app bar ─────────────────────────────────
  Widget _buildAppBar(bool scrolled) {
    return SliverAppBar(
      backgroundColor: _C.white,
      elevation: scrolled ? 1 : 0,
      pinned: true,
      leading: _CircleIconBtn(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subcategory.subCategoryName,
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _C.ink,
            ),
          ),
        ],
      ),
      actions: [
        _CircleIconBtn(
          icon: _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
          onTap: () => setState(() => _isGridView = !_isGridView),
        ),
        _CircleIconBtn(
          icon: Icons.search_rounded,
          onTap: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── filter bar ───────────────────────────────
  Widget _buildFilterBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SimpleHeader(
        height: 52,
        child: Container(
          color: _C.white,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filters.length,
                  itemBuilder: (_, i) {
                    final f = _filters[i];
                    final active = _activeFilter == f;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          f,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? _C.terracotta : _C.slateLight,
                          ),
                        ),
                        selected: active,
                        onSelected: (_) => _setFilter(f),
                        selectedColor: _C.terracottaLight,
                        backgroundColor: _C.sand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: BorderSide(
                            color: active ? _C.terracotta.withOpacity(0.5) : Colors.transparent,
                          ),
                        ),
                        side: BorderSide(
                          color: active ? _C.terracotta.withOpacity(0.5) : Colors.transparent,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  },
                ),
              ),
              Divider(
                height: 1,
                color: _C.cardBorder,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── stats bar ────────────────────────────────
  Widget _buildStatsBar(int count) {
    return SliverToBoxAdapter(
      child: Container(
        color: _C.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: _C.slateLight),
                  children: [
                    const TextSpan(text: 'Showing '),
                    TextSpan(
                      text: '$count products',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700, color: _C.ink),
                    ),
                    TextSpan(text: ' in "${widget.subcategory.subCategoryName}"'),
                  ],
                ),
              ),
            ),
            PopupMenuButton<SortOption>(
              initialValue: _sort,
              tooltip: 'Sort products',
              onSelected: _setSort,
              itemBuilder: (context) => SortOption.values
                  .map(
                    (option) => PopupMenuItem<SortOption>(
                      value: option,
                      child: Text(
                        option.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: option == _sort ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _C.sand,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _C.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.swap_vert_rounded, size: 14, color: _C.slateLight),
                    const SizedBox(width: 4),
                    Text(
                      _sort.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _C.slateLight,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: _C.slateLight),
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

// ─────────────────────────────────────────────
//  Product card
// ─────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final Product product;
  final bool isListView;
  final bool isFavorite;
  final bool isInCart;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleFavorite;
  const _ProductCard(
      {required this.product,
      this.isListView = false,
      required this.isFavorite,
      required this.isInCart,
      required this.onTap,
      required this.onAddToCart,
      required this.onToggleFavorite});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 160));
    _scaleAnim = Tween(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) => _scaleCtrl.reverse(),
      onTapCancel: () => _scaleCtrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: widget.isListView
            ? _buildListTile(p)
            : _buildGridCard(p),
      ),
    );
  }

  Widget _buildGridCard(Product p) {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _C.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: p.images.isNotEmpty
                      ? Image.network(
                          p.images.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                // Fav button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.onToggleFavorite,
                    child: _FavBtn(active: widget.isFavorite),
                  ),
                ),
                if (p.averageRating > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge(
                      text: '★ ${p.averageRating.toStringAsFixed(1)}',
                      bg: _C.terracottaLight,
                      textColor: _C.terracotta,
                    ),
                  ),
              ],
            ),
          ),
          // Info
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 8, 11, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.productName,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.ink,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.category,
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: _C.slateLight),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${p.productPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _C.terracotta,
                            ),
                          ),
                        ],
                      ),
                      _AddToCartBtn(
                        active: widget.isInCart,
                        onTap: widget.onAddToCart,
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

  Widget _buildListTile(Product p) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _C.cardBorder,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
            child: SizedBox(
              width: 100,
              height: double.infinity,
                child: p.images.isNotEmpty
                  ? Image.network(p.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder())
                  : _imagePlaceholder(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p.productName,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _C.ink,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${p.productPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _C.terracotta,
                        ),
                      ),
                      Row(children: [
                        GestureDetector(
                          onTap: widget.onToggleFavorite,
                          child: _FavBtn(active: widget.isFavorite),
                        ),
                        const SizedBox(width: 6),
                        _AddToCartBtn(
                          active: widget.isInCart,
                          onTap: widget.onAddToCart,
                        ),
                      ]),
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

  Widget _imagePlaceholder() {
    return Container(
      color: _C.sand,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: _C.slateLight,
          size: 32,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Shared small widgets
// ─────────────────────────────────────────────
class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconBtn(
      {required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: _C.sand,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 18,
            color: _C.ink),
      ),
    );
  }
}

class _FavBtn extends StatelessWidget {
  final bool active;
  const _FavBtn({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: active
            ? _C.terracottaLight
            : _C.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: _C.cardBorder),
      ),
      child: Icon(
        active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: 15,
        color: active ? _C.terracotta : _C.slateLight,
      ),
    );
  }
}

class _AddToCartBtn extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _AddToCartBtn({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: active ? _C.terracotta : _C.terracottaLight,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          active ? Icons.check_rounded : Icons.add_rounded,
          size: 18,
          color: active ? _C.white : _C.terracotta,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color textColor;
  const _Badge(
      {required this.text, required this.bg, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
            fontSize: 10, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Loading shimmer
// ─────────────────────────────────────────────
class _LoadingShimmer extends StatefulWidget {
  final int crossAxisCount;
  const _LoadingShimmer({required this.crossAxisCount});

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => FadeTransition(
        opacity: _anim,
        child: Container(
          decoration: BoxDecoration(
            color: _C.sand,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Empty state
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _C.terracottaLight,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 40, color: _C.terracotta),
            ),
            const SizedBox(height: 22),
            Text(
              'No products found',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _C.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no products in this subcategory yet. Check back later.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: _C.slateLight),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onRefresh,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
                decoration: BoxDecoration(
                  color: _C.terracotta,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Refresh',
                  style: GoogleFonts.dmSans(
                    color: _C.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Persistent header helper
// ─────────────────────────────────────────────
class _SimpleHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  const _SimpleHeader({required this.child, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Material(
        elevation: overlapsContent ? 2 : 0,
        color: _C.white,
        child: SizedBox(height: height, child: child),
      );

  @override double get maxExtent => height;
  @override double get minExtent => height;
  @override bool shouldRebuild(covariant _SimpleHeader old) =>
      old.child != child || old.height != height;
}