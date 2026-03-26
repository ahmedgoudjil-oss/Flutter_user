//hadi tafichi subcategroy ta3 ki nthamou 3la category man home
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:untitled/models/subcategory.dart';
import 'package:untitled/views/screens/detail/screens/subcategory_product_screen.dart';

class SubcategoryTileWidget extends StatelessWidget {
  final String image;
  final String title;
  final Subcategory? subcategory;

  const SubcategoryTileWidget({
    super.key, 
    required this.image, 
    required this.title,
    this.subcategory, required Null Function() onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (subcategory != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubcategoryProductScreen(subcategory: subcategory!),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 220),
        curve: Curves.easeOut,
        constraints: BoxConstraints(
          maxHeight: 150, // reduced from 160
          minHeight: 110, // reduced from 120
          minWidth: 80,
          maxWidth: 140,
        ),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF7F53AC).withOpacity(0.16),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              elevation: 16,
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.78),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), // reduced vertical padding
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF7F53AC).withOpacity(0.32),
                      Color(0xFF647DEE).withOpacity(0.32),
                      Color(0xFF5EACEA).withOpacity(0.22),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Color(0xFF7F53AC).withOpacity(0.18), width: 1.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 44, // reduced from 50
                      width: 44, // reduced from 50
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF7F53AC).withOpacity(0.32),
                            Color(0xFF647DEE).withOpacity(0.32),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF7F53AC).withOpacity(0.22),
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: Color(0xFF7F53AC), size: 20),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 6), // reduced from 8
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7F53AC),
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Color(0xFF647DEE).withOpacity(0.18),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}