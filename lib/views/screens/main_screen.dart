import 'package:flutter/material.dart';
import 'package:untitled/views/screens/nav_screens/home_screen.dart';
import 'package:untitled/views/screens/nav_screens/favorite_screen.dart';
import 'package:untitled/views/screens/nav_screens/category_screen.dart';
import 'package:untitled/views/screens/nav_screens/cart_screen.dart';
import 'package:untitled/views/screens/nav_screens/account_screen.dart';

class MainScreen extends StatefulWidget {
  final int? initialIndex;
  const MainScreen({super.key, this.initialIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _pageIndex;

  final List<Widget> _pages = [
    const HomeScreen(),
    const FavoriteScreen(),
    const CategoryScreen(),
    AccountScreen(),
    const CartScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _pageIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E40AF),
        onPressed: () => setState(() => _pageIndex = 4),
        child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'Home', 0),
            _navItem(Icons.favorite_border, 'Favorites', 1),
            const SizedBox(width: 48), // FAB space
            _navItem(Icons.category_outlined, 'Category', 2),
            _navItem(Icons.person_outline, 'Account', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _pageIndex == index;
    const activeColor = Color(0xFF1E40AF);

    return InkWell(
      onTap: () => setState(() => _pageIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.black45,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected ? activeColor : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}