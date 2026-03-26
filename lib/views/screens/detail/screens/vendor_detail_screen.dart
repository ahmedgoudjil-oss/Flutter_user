import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/controllers/product_controller.dart';
import 'package:untitled/models/vendor.dart';
import 'package:untitled/models/product.dart';
import 'package:untitled/provider/vendor_provider.dart';
import 'package:untitled/services/cache_service.dart';
import 'package:untitled/views/screens/nav_screens/widgets/product_item_widget.dart';
import 'package:untitled/views/screens/detail/screens/product_detail_screen.dart';

class VendorDetailScreen extends ConsumerStatefulWidget {
  final Vendor vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  @override
  ConsumerState<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends ConsumerState<VendorDetailScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  List<Product> _vendorProducts = [];
  final ProductController _productController = ProductController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSort = 'Default';
  String _selectedCategory = 'All';
  final List<String> _sortOptions = ['Default', 'Price: Low to High', 'Price: High to Low', 'Rating', 'Name'];
  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _loadVendorProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVendorProducts() async {
    setState(() {
      _isLoading = true;
    });
    
    print('🛍️ Loading products for vendor: ${widget.vendor.fullName}');
    
    try {
      final cachedProducts = await CacheService.getCachedVendorProducts(widget.vendor.id);
      
      if (cachedProducts.isNotEmpty) {
        print('📦 Loaded ${cachedProducts.length} products from cache for ${widget.vendor.fullName}');
        setState(() {
          _vendorProducts = cachedProducts;
          _isLoading = false;
        });
        
        _updateCategories();
        ref.read(vendorProductsProvider.notifier).setVendorProducts(widget.vendor.id, cachedProducts);
        _fetchFreshProducts();
      } else {
        await _fetchFreshProducts();
      }
    } catch (e) {
      print("❌ Error loading vendor products for ${widget.vendor.fullName}: $e");
      await _fetchFreshProducts();
    }
  }

  void _updateCategories() {
    final categories = _vendorProducts.map((product) => product.category).toSet().toList();
    setState(() {
      _availableCategories = ['All', ...categories];
    });
  }

  Future<void> _fetchFreshProducts() async {
    try {
      final products = await _productController.loadProductByVendor(widget.vendor.id);
      if (!mounted) return;
      
      print('✅ Successfully loaded ${products.length} fresh products for ${widget.vendor.fullName}');
      
      setState(() {
        _vendorProducts = products;
        _isLoading = false;
      });
      
      _updateCategories();
      ref.read(vendorProductsProvider.notifier).setVendorProducts(widget.vendor.id, products);
      await CacheService.saveVendorProducts(widget.vendor.id, products);
      
    } catch (e) {
      if (!mounted) return;
      print("❌ Error fetching fresh vendor products for ${widget.vendor.fullName}: $e");
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load products. Please check your connection.');
    }
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _isRefreshing = true;
    });
    
    print('🔄 Manual refresh for vendor: ${widget.vendor.fullName}');
    await _fetchFreshProducts();
    
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Product> _getFilteredAndSortedProducts() {
    var filteredProducts = _vendorProducts;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               product.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      filteredProducts = filteredProducts.where((product) {
        return product.category == _selectedCategory;
      }).toList();
    }

    // Apply sorting
    switch (_selectedSort) {
      case 'Price: Low to High':
        filteredProducts.sort((a, b) => a.productPrice.compareTo(b.productPrice));
        break;
      case 'Price: High to Low':
        filteredProducts.sort((a, b) => b.productPrice.compareTo(a.productPrice));
        break;
      case 'Rating':
        filteredProducts.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case 'Name':
        filteredProducts.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      default:
        // Keep default order
        break;
    }

    return filteredProducts;
  }

  Map<String, dynamic> _calculateStoreStats() {
    if (_vendorProducts.isEmpty) {
      return {
        'totalProducts': 0,
        'averageRating': 0.0,
        'totalRatings': 0,
        'categories': 0,
      };
    }

    final totalProducts = _vendorProducts.length;
    final averageRating = _vendorProducts.map((p) => p.averageRating).reduce((a, b) => a + b) / totalProducts;
    final totalRatings = _vendorProducts.map((p) => p.totalRatings).reduce((a, b) => a + b);
    final categories = _vendorProducts.map((p) => p.category).toSet().length;

    return {
      'totalProducts': totalProducts,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'categories': categories,
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;
    final childAspectRatio = screenWidth < 600 ? 0.9 : 1.1;
    final filteredProducts = _getFilteredAndSortedProducts();
    final storeStats = _calculateStoreStats();

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF667eea)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.vendor.fullName,
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF667eea)),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Color(0xFF667eea)),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF667eea)),
            onPressed: () async {
              await _refreshProducts();
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _buildMainContent(filteredProducts, storeStats, crossAxisCount, childAspectRatio),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading products...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(List<Product> filteredProducts, Map<String, dynamic> storeStats, int crossAxisCount, double childAspectRatio) {
    return Column(
      children: [
        // Store info header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Store logo and basic info
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF667eea).withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vendor.fullName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${widget.vendor.city}, ${widget.vendor.state}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              '${storeStats['averageRating'].toStringAsFixed(1)} (${storeStats['totalRatings']} reviews)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              // Store statistics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('${storeStats['totalProducts']}', 'Products'),
                  _buildStatItem('${storeStats['categories']}', 'Categories'),
                ],
              ),
            ],
          ),
        ),
        
        // Search and filter bar
        if (_vendorProducts.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF667eea)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF8F9FA),
                  ),
                ),
                SizedBox(height: 12),
                
                // Active filters display
                if (_searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedSort != 'Default')
                  Row(
                    children: [
                      Text(
                        'Filters: ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: [
                            if (_searchQuery.isNotEmpty)
                              Chip(
                                label: Text('Search: $_searchQuery'),
                                onDeleted: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                backgroundColor: Color(0xFF667eea).withOpacity(0.1),
                              ),
                            if (_selectedCategory != 'All')
                              Chip(
                                label: Text('Category: $_selectedCategory'),
                                onDeleted: () {
                                  setState(() {
                                    _selectedCategory = 'All';
                                  });
                                },
                                backgroundColor: Color(0xFF667eea).withOpacity(0.1),
                              ),
                            if (_selectedSort != 'Default')
                              Chip(
                                label: Text('Sort: $_selectedSort'),
                                onDeleted: () {
                                  setState(() {
                                    _selectedSort = 'Default';
                                  });
                                },
                                backgroundColor: Color(0xFF667eea).withOpacity(0.1),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        
        // Results count
        if (_vendorProducts.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredProducts.length} products found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedSort != 'Default')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = 'All';
                        _selectedSort = 'Default';
                        _searchController.clear();
                      });
                    },
                    child: Text(
                      'Clear all',
                      style: TextStyle(color: Color(0xFF667eea)),
                    ),
                  ),
              ],
            ),
          ),
        
        // Products section
        Expanded(
          child: filteredProducts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refreshProducts,
                  color: Color(0xFF667eea),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          child: ProductItemWidget(product: product),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'All'
                ? 'No products match your search'
                : 'No products available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'All'
                ? 'Try adjusting your search or filters'
                : 'This store hasn\'t added any products yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 16),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'All';
                  _selectedSort = 'Default';
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667eea),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Products'),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Enter product name, description, or category...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter & Sort'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category filter
            Text('Category:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _availableCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16),
            
            // Sort options
            Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSort,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _sortOptions.map((sort) {
                return DropdownMenuItem(
                  value: sort,
                  child: Text(sort),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _selectedSort = 'Default';
              });
              Navigator.pop(context);
            },
            child: Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }
} 