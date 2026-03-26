import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/banner_model.dart';

class BannerProvider extends StateNotifier<List<BannerModel>> {
  BannerProvider() : super([]);

  // Method to add a banner
  void addBanner(List<BannerModel> banners) {
    state = banners;
  }

 
}
final bannerProvider = StateNotifierProvider<BannerProvider, List<BannerModel>>(
  (ref) => BannerProvider(),
);