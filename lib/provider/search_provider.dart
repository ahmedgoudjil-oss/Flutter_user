import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/product.dart';
import 'package:untitled/controllers/product_controller.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  final ProductController _productController = ProductController();

  SearchNotifier() : super(SearchState());

  Future<void> searchProducts(String query, {String category = 'All'}) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(
        products: [],
        isLoading: false,
        error: null,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔍 Searching for: "$query"');
      final List<Product> products = await _productController.searchProducts(query);
      print('📦 Found ${products.length} products');
      
      // Apply category filter if not "All"
      List<Product> filteredProducts = products;
      if (category != 'All') {
        filteredProducts = products.where((product) => 
          product.category.toLowerCase() == category.toLowerCase()
        ).toList();
        print('🏷️ Filtered to ${filteredProducts.length} products in category: $category');
      }

      state = state.copyWith(
        products: filteredProducts,
        isLoading: false,
        error: null,
      );
      print('✅ Search completed successfully');
    } catch (e) {
      print('❌ Search error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void addToHistory(String query) {
    if (query.isNotEmpty && !state.searchHistory.contains(query)) {
      final newHistory = [query, ...state.searchHistory];
      if (newHistory.length > 10) {
        newHistory.removeLast();
      }
      state = state.copyWith(searchHistory: newHistory);
    }
  }

  void clearSearch() {
    state = state.copyWith(products: []);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

class SearchState {
  final List<Product> products;
  final List<String> searchHistory;
  final bool isLoading;
  final String? error;
  final String selectedCategory;

  SearchState({
    this.products = const [],
    this.searchHistory = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory = 'All',
  });

  SearchState copyWith({
    List<Product>? products,
    List<String>? searchHistory,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return SearchState(
      products: products ?? this.products,
      searchHistory: searchHistory ?? this.searchHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
}); 