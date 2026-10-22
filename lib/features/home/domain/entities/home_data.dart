import 'package:equatable/equatable.dart';
import 'home_banner_item.dart';

/// Aggregated entity representing the data returned by /api/user/home.
class HomeData extends Equatable {
  final List<HomeBannerItem> heroBanners;
  final List<HomeBannerItem> middleBanners;

  const HomeData({
    this.heroBanners = const [],
    this.middleBanners = const [],
  });

  @override
  List<Object?> get props => [heroBanners, middleBanners];
}
