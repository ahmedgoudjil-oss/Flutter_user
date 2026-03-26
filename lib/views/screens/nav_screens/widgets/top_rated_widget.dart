import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/controllers/product_controller.dart';
import 'package:untitled/models/product.dart';
import 'package:untitled/provider/cart_provider.dart';
import 'package:untitled/provider/favorite_provider.dart';
import 'package:untitled/provider/product_provider.dart';
import 'package:untitled/provider/topRated_product_provider.dart';
import 'package:untitled/views/screens/nav_screens/widgets/product_item_widget.dart';

class TopRatedWidget extends ConsumerStatefulWidget {
  

  const TopRatedWidget({super.key, });
  

  @override
  ConsumerState<TopRatedWidget> createState() => _TopRatedWidgetState();
}

class _TopRatedWidgetState extends ConsumerState<TopRatedWidget> {
  @override
  void initState() {
    super.initState();
    _checkAndFetchProducts();
  }

  void _checkAndFetchProducts() {
    final products = ref.read(topratedProductProvider);
    if (products.isEmpty) {
      _fetchProduct();
    }
  }

  Future<void> _fetchProduct() async {
    final ProductController productController = ProductController();
    try {
      final products = await productController.loadTopRatedProduct();
      ref.read(topratedProductProvider.notifier).setProducts(products);
    } catch (e) {
      // Optionally handle error (e.g., show a snackbar)
      print("Error fetching products: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    final products = ref.watch(topratedProductProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    return SizedBox(
      height: 270,
      child: ListView.builder(
        padding: EdgeInsets.zero, // Remove top space
        itemCount: (products.length / 2).ceil(),
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, rowIndex) {
          final firstIndex = rowIndex * 2;
          final secondIndex = firstIndex + 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF1976D2).withOpacity(0.10),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 16,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      margin: EdgeInsets.zero,
                      child: Container(
                        height: 230,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: ProductItemWidget(product: products[firstIndex]),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                if (secondIndex < products.length)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF1976D2).withOpacity(0.10),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 16,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        margin: EdgeInsets.zero,
                        child: Container(
                          height: 230,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: ProductItemWidget(product: products[secondIndex]),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(child: SizedBox()),
              ],
            ),
          );
        },
      ),
    );
  }
}