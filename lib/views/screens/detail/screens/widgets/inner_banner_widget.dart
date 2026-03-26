//hadi tafichi banner ta3 ki nthamou 3la category man home
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/controllers/banner_controller.dart';
import 'package:untitled/models/category.dart';
import 'package:untitled/provider/banner_provider.dart';

class InnerBannerWidget extends ConsumerStatefulWidget {
 final String image;

  const InnerBannerWidget({super.key, required this.image});

  @override
  ConsumerState<InnerBannerWidget> createState() => _InnerBannerWidgetState();
}

class _InnerBannerWidgetState extends ConsumerState<InnerBannerWidget> {
  @override
  void initState() {
    
    super.initState();
    _checkAndFetchBanner();
  }

  void _checkAndFetchBanner() {
    final banners = ref.read(bannerProvider);
    if (banners.isEmpty) {
      _fetchBanner();
    }
  }

  Future<void> _fetchBanner() async {
    // This method can be used to fetch products if needed
    // For now, it's empty as the widget does not require fetching products
    final BannerController bannerController = BannerController();
    try {
      final banners = await bannerController.loadBanners();

      ref.read(bannerProvider.notifier).addBanner(banners);
    } catch (e) {
      // Optionally handle error (e.g., show a snackbar)
      print("Error fetching banners: $e");
      
    }
  }
  @override
  Widget build(BuildContext context) {
    ref.watch(bannerProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [Color(0xFFFFF3E0), Color(0xFFFFB74D).withOpacity(0.18)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(widget.image, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.10), Colors.deepOrange.withOpacity(0.10)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.deepOrange.withOpacity(0.12), blurRadius: 6)],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer, color: Colors.deepOrange, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "Special Category",
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.08)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}