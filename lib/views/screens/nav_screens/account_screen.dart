import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/controllers/auth_controller.dart';
import 'package:untitled/views/screens/detail/screens/order_screen.dart';
import 'package:untitled/provider/user_provider.dart';
import 'package:untitled/views/screens/nav_screens/favorite_screen.dart';
import 'package:untitled/views/screens/detail/screens/shipping_adress_screen.dart';
import 'package:untitled/provider/order_provider.dart';
import 'package:untitled/provider/delivered_order_count_provider.dart';
import 'package:untitled/provider/favorite_provider.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
class _T {
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

  static const bg = cream;
  static const surface = white;
  static const stroke = 1.2;
}

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen>
    with TickerProviderStateMixin {
  final AuthController _authController = AuthController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();

  late AnimationController _masterAnim;
  late List<Animation<double>> _itemAnims;

  static const _menuItems = [
    (Icons.shopping_bag_outlined, 'My Orders', 'Track and manage orders'),
    (Icons.favorite_border_rounded, 'Favourites', 'Your saved items'),
    (
      Icons.location_on_outlined,
      'Shipping Address',
      'Manage delivery addresses',
    ),
    (Icons.notifications_outlined, 'Notifications', 'Alerts & updates'),
    (Icons.help_outline_rounded, 'Help & Support', 'Get help from us'),
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: _T.bg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _masterAnim = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    final itemCount = _menuItems.length + 4; // profile + stats + title + logout
    _itemAnims = List.generate(itemCount, (i) {
      final start = (i / itemCount) * 0.65;
      final end = start + 0.35;
      return CurvedAnimation(
        parent: _masterAnim,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      );
    });

    _masterAnim.forward();
  }

  @override
  void dispose() {
    _masterAnim.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  // Shared reveal wrapper
  Widget _reveal(int index, Widget child) {
    final anim = _itemAnims[index.clamp(0, _itemAnims.length - 1)];
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final orderCount = ref.watch(deliveredOrderCountProvider);
    final wishCount = ref.watch(wishlistCountProvider);

    return Scaffold(
      backgroundColor: _T.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ──────────────────────────────────────────
          SliverToBoxAdapter(child: _reveal(0, _buildTopBar())),

          // ── Profile hero ─────────────────────────────────────
          SliverToBoxAdapter(child: _reveal(1, _buildProfileHero(user))),

          // ── Stats ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _reveal(2, _buildStats(orderCount, wishCount)),
          ),

          // ── Section label ─────────────────────────────────────
          SliverToBoxAdapter(child: _reveal(3, _buildSectionLabel())),

          // ── Menu items ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                final (icon, title, sub) = _menuItems[i];
                return _reveal(
                  4 + i,
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MenuItem(
                      icon: icon,
                      title: title,
                      subtitle: sub,
                      onTap: () => _handleMenu(i),
                    ),
                  ),
                );
              }, childCount: _menuItems.length),
            ),
          ),

          // ── Logout ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: _reveal(4 + _menuItems.length, _buildLogout()),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Account',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: _T.charcoal,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage profile and orders',
                style: GoogleFonts.dmSans(fontSize: 13, color: _T.slateLight),
              ),
            ],
          ),
          _IconChip(icon: Icons.tune_rounded, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildProfileHero(dynamic user) {
    final initials = (user?.fullName ?? 'G')
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _T.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _T.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _T.ink.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _T.terracotta,
              shape: BoxShape.circle,
              border: Border.all(color: _T.terracottaLight, width: 3),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Guest User',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _T.charcoal,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'guest@example.com',
                  style: GoogleFonts.dmSans(fontSize: 13, color: _T.slate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _T.terracottaLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _T.terracotta.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '✦ PREMIUM MEMBER',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _T.terracotta,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit chip
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _T.sand,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _T.cardBorder, width: 1),
              ),
              child: const Icon(Icons.edit_outlined, color: _T.ink, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int orders, int wishlist) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              label: 'ORDERS',
              value: '$orders',
              icon: Icons.shopping_bag_outlined,
              accent: _T.terracotta,
              accentPale: _T.terracottaLight,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              label: 'SAVED',
              value: '$wishlist',
              icon: Icons.favorite_border_rounded,
              accent: _T.charcoal,
              accentPale: _T.sand,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              label: 'POINTS',
              value: '840',
              icon: Icons.bolt_rounded,
              accent: _T.slate,
              accentPale: _T.parchment,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            color: _T.sand,
            margin: const EdgeInsets.only(right: 10),
          ),
          Text(
            'ACCOUNT OPTIONS',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _T.slate,
              letterSpacing: 2.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () async {
          await _authController.signOutUser(context: context, ref: ref);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _T.terracotta,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _T.terracotta.withOpacity(0.24),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: _T.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'SIGN OUT',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _T.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenu(int index) {
    switch (index) {
      case 0:
        Navigator.push(context, _fadeRoute(const OrderScreen()));
      case 1:
        Navigator.push(context, _fadeRoute(const FavoriteScreen()));
      case 2:
        Navigator.push(
          context,
          _fadeRoute(
            ShippingAddressScreen(
              nameController: _nameController,
              addressController: _addressController,
              phoneController: _phoneController,
              stateController: _stateController,
              cityController: _cityController,
              localityController: _localityController,
            ),
          ),
        );
      default:
        break;
    }
  }

  PageRoute _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, anim, __) => page,
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
    transitionDuration: const Duration(milliseconds: 260),
  );
}

// ── Stat tile ─────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color accent, accentPale;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.accentPale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: _T.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _T.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentPale,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _T.charcoal,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _T.slate,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu item ─────────────────────────────────────────────────────────────────
class _MenuItem extends StatefulWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_pressed ? 0.975 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _pressed ? _T.sand : _T.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _pressed ? _T.terracotta : _T.cardBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon block
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _T.sand,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _T.cardBorder, width: 1),
              ),
              child: Icon(widget.icon, size: 22, color: _T.charcoal),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _T.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.dmSans(fontSize: 12, color: _T.slate),
                  ),
                ],
              ),
            ),

            // Arrow
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _T.terracotta,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: _T.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Icon chip (top bar) ───────────────────────────────────────────────────────
class _IconChip extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconChip({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _T.sand,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _T.cardBorder, width: 1),
        ),
        child: Icon(icon, size: 20, color: _T.ink),
      ),
    );
  }
}
