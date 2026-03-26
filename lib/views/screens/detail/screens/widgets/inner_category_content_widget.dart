// hadi la page ta3 ki nthamou 3la category man home screen troh lel page ta3 category
// w tban fiha les subcategories ta3ha

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/controllers/product_controller.dart';
import 'package:untitled/controllers/subcategory_controller.dart';
import 'package:untitled/models/category.dart';
import 'package:untitled/models/product.dart';
import 'package:untitled/models/subcategory.dart';
import 'package:untitled/views/screens/detail/screens/widgets/inner_banner_widget.dart';
import 'package:untitled/views/screens/detail/screens/widgets/inner_header_widget.dart';
import 'package:untitled/views/screens/detail/screens/widgets/subcategory_tile_widget.dart';
import 'package:untitled/views/screens/nav_screens/widgets/product_item_widget.dart';
import 'package:untitled/views/screens/nav_screens/widgets/reusable_text_widget.dart';

class InnerCategoryContentWidget extends StatefulWidget {
  final Category category;

  const InnerCategoryContentWidget({super.key, required this.category});

  @override
  State<InnerCategoryContentWidget> createState() =>
      _InnerCategoryContentWidgetState();
}

class _InnerCategoryContentWidgetState
    extends State<InnerCategoryContentWidget> {
  late Future<List<Subcategory>> _subCategories;
  late Future<List<Product>> futureProducts;
  final SubcategoryController _subcategoryController = SubcategoryController();
  @override
  void initState() {
    super.initState();
    _subCategories = _subcategoryController.getSubCategoriesByCategoryName(
      widget.category.name,
    );
    futureProducts = ProductController().loadProductByCategory(
      widget.category.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
        child: InnerHeaderWidget(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF3F4F8),
              Color(0xFFE9EAF6),
              Color(0xFFDDE6F6),
              Color(0xFFFAF7FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                InnerBannerWidget(image: widget.category.banner),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      "Shop By Category",
                      style: GoogleFonts.quicksand(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: Color.fromARGB(255, 47, 145, 225),
                        shadows: [
                          Shadow(
                            color: Color.fromARGB(255, 108, 53, 163).withOpacity(0.12),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Color(0xFF5EACEA).withOpacity(0.10), width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF5EACEA).withOpacity(0.09),
                            blurRadius: 18,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
                        child: FutureBuilder(
                          future: _subCategories,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return SizedBox(height: 60, child: Center(child: CircularProgressIndicator()));
                            } else if (snapshot.hasError) {
                              return Center(child: Text("Error :${snapshot.error}"));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(child: Text("No SubCategories"));
                            } else {
                              final subcategories = snapshot.data!;
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                    (subcategories.length / 7).ceil(),
                                    (setIndex) {
                                      final start = setIndex * 7;
                                      final end = ((setIndex + 1) * 7).clamp(0, subcategories.length);
                                      final rowItems = subcategories.sublist(start, end);
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: rowItems
                                              .map(
                                                (subcategory) => Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                                  child: Material(
                                                    elevation: 6,
                                                    borderRadius: BorderRadius.circular(18),
                                                    color: Colors.white.withOpacity(0.95),
                                                    child: SubcategoryTileWidget(
                                                      image: subcategory.image,
                                                      title: subcategory.subCategoryName, onTap: () {  },
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
