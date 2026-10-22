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
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json);

    final banners = data['banners'] is Map ? data['banners'] as Map : null;

    if (banners != null) {
      if (banners['home_hero'] is List) {
        heroList = (banners['home_hero'] as List)
            .whereType<Map>()
            .map((item) => HomeBannerItemModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        heroList.sort((a, b) => a.order.compareTo(b.order));
      }

      if (banners['home_middle'] is List) {
        middleList = (banners['home_middle'] as List)
            .whereType<Map>()
            .map((item) => HomeBannerItemModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        middleList.sort((a, b) => a.order.compareTo(b.order));
      }
    }

    return HomeDataModel(
      heroBanners: heroList,
      middleBanners: middleList,
    );
  }
}
