import '../../domain/entities/home_data.dart';
import 'home_banner_item_model.dart';

/// Data model representing aggregated home data from /api/user/home.
class HomeDataModel extends HomeData {
  const HomeDataModel({
    super.heroBanners = const [],
    super.middleBanners = const [],
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    List<HomeBannerItemModel> heroList = [];
    List<HomeBannerItemModel> middleList = [];

    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map
            ? Map<String, dynamic>.from(json['data'] as Map)
            : json);

    final banners = data['banners'] is Map
        ? data['banners'] as Map
        : data;

    final heroRaw = banners['home_hero'] ??
        banners['homeHero'] ??
        banners['hero_banners'] ??
        banners['hero'];
    if (heroRaw is List) {
      heroList = heroRaw
          .whereType<Map>()
          .map((item) =>
              HomeBannerItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      heroList.sort((a, b) => a.order.compareTo(b.order));
    }

    final middleRaw = banners['home_middle'] ??
        banners['homeMiddle'] ??
        banners['middle_banners'] ??
        banners['suggestions'] ??
        banners['middle'];
    if (middleRaw is List) {
      middleList = middleRaw
          .whereType<Map>()
          .map((item) =>
              HomeBannerItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      middleList.sort((a, b) => a.order.compareTo(b.order));
    }

    return HomeDataModel(
      heroBanners: heroList,
      middleBanners: middleList,
    );
  }
}
