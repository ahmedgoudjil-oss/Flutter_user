import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/controllers/category_controller.dart';
import 'package:untitled/controllers/subcategory_controller.dart';
import 'package:untitled/models/category.dart';
import 'package:untitled/models/subcategory.dart';
import 'package:untitled/provider/category_provider.dart';
import 'package:untitled/provider/subcategory_provider.dart';
import 'package:untitled/views/screens/detail/screens/widgets/subcategory_tile_widget.dart';
import 'package:untitled/views/screens/nav_screens/widgets/header_widget.dart';

// ─────────────────────────────────────────────
//  Design tokens  (warm editorial palette)
// ─────────────────────────────────────────────
class _C {
  // light
  static const sand        = Color(0xFFFAF7F2);
  static const card        = Color(0xFFFFFFFF);
  static const border      = Color(0xFFE7E2DA);
  static const ink         = Color(0xFF1C1917);
  static const ink2        = Color(0xFF57534E);
  static const ink3        = Color(0xFFA8A29E);
  static const amber       = Color(0xFFD97706);
  static const amberLight  = Color(0xFFFEF3C7);
  static const amberDark   = Color(0xFF92400E);
  // dark
  static const darkBg      = Color(0xFF1C1917);
  static const darkSurface = Color(0xFF292524);
  static const darkBorder  = Color(0xFF3D3733);
}

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class CategoryScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const CategoryScreen({super.key, this.initialCategory});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen>
    with SingleTickerProviderStateMixin {

  // ── controllers (unchanged) ────────────────
  final CategoryController    _categoryController    = CategoryController();
  final SubcategoryController _subcategoryController = SubcategoryController();

  String _selectedCategoryName = 'Electronics';
  bool   _isLoading   = true;
  String _searchQuery = '';

  final ScrollController      _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _fadeController;

  // ── lifecycle (unchanged) ──────────────────
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
    if (widget.initialCategory != null) {
      _selectedCategoryName = widget.initialCategory!;
    }
    _fetchInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── data (unchanged) ──────────────────────
  Future<void> _fetchInitialData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchCategories(),
        _fetchSubcategories(_selectedCategoryName),
      ]);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await _categoryController.loadCategories();
      ref.read(categoryProvider.notifier).setCategories(cats);
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _fetchSubcategories(String name) async {
    try {
      final subs =
          await _subcategoryController.getSubCategoriesByCategoryName(name);
      ref.read(subcategoryProvider.notifier).setSubcategories(subs);
    } catch (e) {
      debugPrint('Error loading subcategories: $e');
      ref.read(subcategoryProvider.notifier).setSubcategories([]);
    }
  }

  void _onCategorySelected(String name) {
    if (_selectedCategoryName == name) return;
    setState(() {
      _selectedCategoryName = name;
      _searchQuery = '';
      _searchController.clear();
    });
    _fadeController.forward(from: 0);
    _fetchSubcategories(name);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Subcategory> _filtered(List<Subcategory> subs) {
    if (_searchQuery.isEmpty) return subs;
    final q = _searchQuery.toLowerCase();
    return subs
        .where((s) => s.subCategoryName.toLowerCase().contains(q))
        .toList();
  }

  int _crossAxisCount(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w >= 1100) return 4;
    if (w >= 750)  return 3;
    return 2;
  }

  // ── build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final bg           = isDark ? _C.darkBg      : _C.sand;
    final surfaceColor = isDark ? _C.darkSurface : _C.card;
    final borderColor  = isDark ? _C.darkBorder  : _C.border;
    final inkColor     = isDark ? Colors.white   : _C.ink;
    final ink2Color    = isDark ? Colors.white60 : _C.ink2;

    final categories    = ref.watch(categoryProvider);
    final allSubs       = ref.watch(subcategoryProvider);
    final subcategories = _filtered(allSubs);

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        color: _C.amber,
        onRefresh: _fetchInitialData,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [

            // ── Collapsible app bar ───────────
            _EditorialAppBar(
              isDark: isDark,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              inkColor: inkColor,
            ),

            // ── Search + count ────────────────
            SliverToBoxAdapter(
              child: Container(
                color: surfaceColor,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WarmSearchField(
                      controller: _searchController,
                      isDark: isDark,
                      borderColor: borderColor,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      onClear: () => setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      }),
                    ),
                    const SizedBox(height: 10),
                    _CountRow(
                      count: subcategories.length,
                      category: _selectedCategoryName,
                      ink2Color: ink2Color,
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: Divider(height: 1, color: borderColor)),

            // ── Pinned tab rail ───────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedHeader(
                height: 56,
                child: _TabRail(
                  categories: categories,
                  selected: _selectedCategoryName,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  onSelect: _onCategorySelected,
                ),
              ),
            ),

            // ── Content ───────────────────────
            if (_isLoading)
              _ShimmerGrid(
                crossAxisCount: _crossAxisCount(context),
                isDark: isDark,
                borderColor: borderColor,
              )
            else if (subcategories.isEmpty)
              _EmptyState(
                onReload: _fetchInitialData,
                inkColor: inkColor,
                ink2Color: ink2Color,
              )
            else
              SliverFadeTransition(
                opacity: _fadeController,
                sliver: SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _crossAxisCount(context),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.92,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final sc = subcategories[i];
                        return SubcategoryTileWidget(
                          subcategory: sc,
                          image: sc.image,
                          title: sc.subCategoryName,
                          onTap: () {},
                        );
                      },
                      childCount: subcategories.length,
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  App bar  — italic serif title
// ─────────────────────────────────────────────
class _EditorialAppBar extends StatelessWidget {
  final bool  isDark;
  final Color surfaceColor, borderColor, inkColor;
  const _EditorialAppBar({
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.inkColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: surfaceColor,
      elevation: 0,
      pinned: true,
      expandedHeight: 120,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(height: 1, color: borderColor),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse',
              style: GoogleFonts.libreBaskerville(
                fontSize: 9,
                letterSpacing: .14,
                color: _C.amber,
              ),
            ),
            Text(
              'Categories',
              style: GoogleFonts.libreBaskerville(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: inkColor,
              ),
            ),
          ],
        ),
        background: Container(color: surfaceColor),
        collapseMode: CollapseMode.parallax,
      ),
      actions: [
        _AppBarBtn(icon: Icons.search_rounded, inkColor: inkColor, borderColor: borderColor, onTap: () {}),
        _AppBarBtn(icon: Icons.tune_rounded,   inkColor: inkColor, borderColor: borderColor, onTap: () {}),
        const SizedBox(width: 10),
      ],
    );
  }
}

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final Color    inkColor, borderColor;
  final VoidCallback onTap;
  const _AppBarBtn({
    required this.icon,
    required this.inkColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 17, color: inkColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Search field
// ─────────────────────────────────────────────
class _WarmSearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool  isDark;
  final Color borderColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _WarmSearchField({
    required this.controller,
    required this.isDark,
    required this.borderColor,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final bg   = isDark ? const Color(0xFF292524) : _C.sand;
    final hint = isDark ? Colors.white38 : _C.ink3;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.lato(
          fontSize: 14,
          color: isDark ? Colors.white : _C.ink,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: hint, size: 19),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close_rounded, color: hint, size: 17),
                )
              : null,
          hintText: 'Search subcategories…',
          hintStyle: GoogleFonts.lato(color: hint, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Count row
// ─────────────────────────────────────────────
class _CountRow extends StatelessWidget {
  final int    count;
  final String category;
  final Color  ink2Color;
  const _CountRow({
    required this.count,
    required this.category,
    required this.ink2Color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: _C.amberLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count items',
            style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _C.amberDark,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'in "$category"',
            style: GoogleFonts.lato(fontSize: 12, color: ink2Color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Tab rail
// ─────────────────────────────────────────────
class _TabRail extends StatelessWidget {
  final List<Category> categories;
  final String selected;
  final bool  isDark;
  final Color surfaceColor, borderColor;
  final ValueChanged<String> onSelect;

  const _TabRail({
    required this.categories,
    required this.selected,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        color: surfaceColor,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: List.generate(
            5,
            (_) => Container(
              margin: const EdgeInsets.only(right: 8),
              width: 88,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : _C.sand,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: surfaceColor,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat      = categories[i];
                final isActive = selected == cat.name;
                return _TabChip(
                  name: cat.name,
                  isActive: isActive,
                  isDark: isDark,
                  borderColor: borderColor,
                  onTap: () => onSelect(cat.name),
                );
              },
            ),
          ),
          Divider(height: 1, color: borderColor),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String name;
  final bool  isActive, isDark;
  final Color borderColor;
  final VoidCallback onTap;

  const _TabChip({
    required this.name,
    required this.isActive,
    required this.isDark,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg     = isDark ? Colors.white    : _C.ink;
    final inactiveBg   = Colors.transparent;
    final activeText   = isDark ? _C.ink          : Colors.white;
    final inactiveText = isDark ? Colors.white60  : _C.ink2;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isActive ? activeBg : borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 7),
              decoration: BoxDecoration(
                color: isActive ? _C.amber : borderColor,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              name,
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeText : inactiveText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Shimmer grid
// ─────────────────────────────────────────────
class _ShimmerGrid extends StatefulWidget {
  final int   crossAxisCount;
  final bool  isDark;
  final Color borderColor;
  const _ShimmerGrid({
    required this.crossAxisCount,
    required this.isDark,
    required this.borderColor,
  });

  @override
  State<_ShimmerGrid> createState() => _ShimmerGridState();
}

class _ShimmerGridState extends State<_ShimmerGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = Tween(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shimmerColor = widget.isDark
        ? Colors.white.withOpacity(0.06)
        : _C.border;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.92,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => FadeTransition(
            opacity: _fade,
            child: Container(
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.borderColor),
              ),
            ),
          ),
          childCount: 6,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Empty state
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onReload;
  final Color inkColor, ink2Color;
  const _EmptyState({
    required this.onReload,
    required this.inkColor,
    required this.ink2Color,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _C.amberLight,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.inbox_outlined, size: 36, color: _C.amber),
              ),
              const SizedBox(height: 20),
              Text(
                'Nothing here',
                style: GoogleFonts.libreBaskerville(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: inkColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different category\nor pull down to refresh.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    fontSize: 14, color: ink2Color, height: 1.6),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: onReload,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    color: _C.ink,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    'Reload',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

// ─────────────────────────────────────────────
//  Pinned header delegate  (logic unchanged)
// ─────────────────────────────────────────────
class _PinnedHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  const _PinnedHeader({required this.child, required this.height});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 2 : 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox(height: height, child: child),
    );
  }

  @override double get maxExtent => height;
  @override double get minExtent => height;

  @override
  bool shouldRebuild(covariant _PinnedHeader old) =>
      old.child != child || old.height != height;
}
