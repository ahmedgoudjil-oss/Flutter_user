import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../controllers/banner_controller.dart';
import '../../../../models/banner_model.dart';
import 'package:untitled/provider/banner_provider.dart';

class BannerWidget extends ConsumerStatefulWidget {
  const BannerWidget({super.key});

  @override
  ConsumerState<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends ConsumerState<BannerWidget> {
  @override
  void initState() {
    super.initState();
    if (ref.read(bannerProvider).isEmpty) _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    try {
      final banners = await BannerController().loadBanners();
      ref.read(bannerProvider.notifier).addBanner(banners);
    } catch (e) {
      debugPrint('Error fetching banners: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final banners = ref.watch(bannerProvider);

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: banners.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF3B82F6),
                  strokeWidth: 2,
                ),
              )
            : PageView.builder(
                itemCount: banners.length,
                itemBuilder: (context, index) =>
                    _buildBannerItem(banners[index]),
              ),
      ),
    );
  }

  Widget _buildBannerItem(BannerModel banner) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          banner.image,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const ColoredBox(
                  color: Color(0xFFDBEAFE),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3B82F6),
                      strokeWidth: 2,
                    ),
                  ),
                ),
          errorBuilder: (_, __, ___) => const ColoredBox(
            color: Color(0xFFDBEAFE),
            child: Center(
              child: Icon(Icons.image_not_supported,
                  size: 36, color: Color(0xFF3B82F6)),
            ),
          ),
        ),
        // "Featured" badge
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Featured',
              style: TextStyle(
                color: Color(0xFF1E40AF),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}