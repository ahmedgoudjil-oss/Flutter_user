import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/controllers/vendor_controller.dart';
import 'package:untitled/controllers/product_controller.dart';
import 'package:untitled/provider/stores_provider.dart';
import 'package:untitled/models/product.dart';
import 'package:untitled/models/vendor.dart';
import 'package:untitled/services/cache_service.dart';
import 'package:untitled/views/screens/detail/screens/vendor_detail_screen.dart';
import 'package:untitled/views/screens/nav_screens/widgets/product_item_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key});

  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  final ProductController _productController = ProductController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Electronics', 'Fashion', 'Home', 'Sports', 'Books'];

  @override
  void initState() {
    super.initState();
    print('🚀 StoresScreen initState called');
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    print('📋 _loadData called');
    final storesNotifier = ref.read(storesProvider.notifier);
    
    print('📊 Provider state check:');
    print('   - Vendors count: ${storesNotifier.vendors.length}');
    print('   - Vendor products count: ${storesNotifier.vendorProducts.length}');
    print('   - Last fetch time: ${storesNotifier.lastFetchTime}');
    print('   - Cache expired: ${storesNotifier.isCacheExpired}');
    
    // Check if we have cached data
    if (storesNotifier.vendors.isNotEmpty) {
      print('📦 ✅ Using cached stores data from SharedPreferences');
      print('📊 Cache info: ${storesNotifier.cacheInfo}');
      
      setState(() {
        _isLoading = false;
      });
      
      // Check if cache is expired and fetch fresh data in background
      if (storesNotifier.isCacheExpired) {
        print('⏰ Cache expired, fetching fresh data in background');
        _fetchFreshDataInBackground();
      } else {
        print('✅ Cache is still valid, no background fetch needed');
      }
    } else {
      print('🔄 ❌ No cached data available in SharedPreferences, fetching fresh data...');
      setState(() {
        _isLoading = true;
      });
      await _fetchFreshData();
    }
  }

  bool _isCacheExpired(String? lastFetchTimeString) {
    if (lastFetchTimeString == null) return true;
    
    try {
      final lastFetchTime = DateTime.parse(lastFetchTimeString);
      final now = DateTime.now();
      final difference = now.difference(lastFetchTime);
      return difference.inDays >= 2; // Cache expires after 2 days
    } catch (e) {
      return true;
    }
  }

  Future<void> _fetchFreshDataInBackground() async {
    try {
      print('🔄 Fetching fresh data in background...');
      
      final VendorController vendorController = VendorController();
      final vendors = await vendorController.loadVendors();
      
      Map<String, List<Product>> vendorProducts = {};
      for (var vendor in vendors) {
        try {
          print('📦 Fetching products for vendor: ${vendor.fullName}');
          final products = await _productController.loadProductByVendor(vendor.id);
          vendorProducts[vendor.id] = products;
          print('✅ Successfully loaded ${products.length} products for ${vendor.fullName}');
        } catch (e) {
          print("❌ Error fetching products for vendor ${vendor.fullName}: $e");
          vendorProducts[vendor.id] = [];
        }
      }
      
      if (mounted) {
        ref.read(storesProvider.notifier).updateStoresData(vendors, vendorProducts);
        print('✅ Fresh data fetched and cached successfully');
      }
      
    } catch (e) {
      print("❌ Error fetching fresh data in background: $e");
    }
  }

  Future<void> _fetchFreshData() async {
    try {
      print('🔄 Fetching fresh data...');
      
      final VendorController vendorController = VendorController();
      final vendors = await vendorController.loadVendors();
      
      Map<String, List<Product>> vendorProducts = {};
      for (var vendor in vendors) {
        try {
          print('📦 Fetching products for vendor: ${vendor.fullName}');
          final products = await _productController.loadProductByVendor(vendor.id);
          vendorProducts[vendor.id] = products;
          print('✅ Successfully loaded ${products.length} products for ${vendor.fullName}');
        } catch (e) {
          print("❌ Error fetching products for vendor ${vendor.fullName}: $e");
          vendorProducts[vendor.id] = [];
        }
      }
      
      if (mounted) {
        ref.read(storesProvider.notifier).updateStoresData(vendors, vendorProducts);
      }
      
    } catch (e) {
      print("❌ Error fetching fresh data: $e");
      if (mounted) {
        _showErrorSnackBar('Failed to load stores. Please check your connection.');
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }
    
    print('🔄 Manual refresh triggered');
    await _fetchFreshData();
    
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _forceRefreshData() async {
    print('🔄 Force refreshing stores data...');
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    // Clear cache and fetch fresh data
    if (mounted) {
      ref.read(storesProvider.notifier).clearStoresData();
    }
    await _fetchFreshData();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<Vendor> _getFilteredVendors() {
    final storesNotifier = ref.watch(storesProvider.notifier);
    final vendors = storesNotifier.vendors;
    final vendorProducts = storesNotifier.vendorProducts;
    
    // Filter vendors that have products
    var filteredVendors = vendors.where((vendor) {
      final products = vendorProducts[vendor.id] ?? [];
      return products.isNotEmpty;
    }).toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredVendors = filteredVendors.where((vendor) {
        return vendor.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               vendor.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               vendor.state.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_selectedFilter != 'All') {
      filteredVendors = filteredVendors.where((vendor) {
        final products = vendorProducts[vendor.id] ?? [];
        return products.any((product) => 
          product.category.toLowerCase().contains(_selectedFilter.toLowerCase()));
      }).toList();
    }

    return filteredVendors;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF1A202C);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            elevation: 2,
            pinned: true,
            centerTitle: true,
            title: Text(
              'Stores',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SearchAndFilterHeader(
              searchController: _searchController,
              selectedFilter: _selectedFilter,
              filterOptions: _filterOptions,
              onSearchChanged: (query) => setState(() => _searchQuery = query),
              onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
              isDark: isDark,
            ),
            pinned: true,
          ),
          _isLoading
              ? _buildShimmerGrid()
              : _buildStoreGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'No stores match your search'
                : 'No stores available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'Try adjusting your search or filters'
                : 'Pull to refresh to load stores',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 16),
          if (_searchQuery.isNotEmpty || _selectedFilter != 'All')
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'All';
                  _searchController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667eea),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreGrid(bool isDark) {
    final filteredVendors = _getFilteredVendors();
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    if (filteredVendors.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final vendor = filteredVendors[index];
            return _buildVendorCard(vendor, cardColor);
          },
          childCount: filteredVendors.length,
        ),
      ),
    );
  }

  Widget _buildVendorCard(Vendor vendor, Color cardColor) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VendorDetailScreen(vendor: vendor)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
              child: const Icon(Icons.store_outlined, color: Color(0xFF3B82F6), size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              vendor.fullName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${vendor.city}, ${vendor.state}',
              style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 12),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Text(
                'View Store',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667eea),
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
          childCount: 6,
        ),
      ),
    );
  }
}

class _SearchAndFilterHeader extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final String selectedFilter;
  final List<String> filterOptions;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final bool isDark;

  _SearchAndFilterHeader({
    required this.searchController,
    required this.selectedFilter,
    required this.filterOptions,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search stores...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF3B82F6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterOptions.map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) => onFilterChanged(filter),
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    selectedColor: const Color(0xFF3B82F6).withOpacity(0.8),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 140.0;

  @override
  double get minExtent => 140.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
