import 'package:equatable/equatable.dart';

/// Entity representing a banner item on the customer home page.
class HomeBannerItem extends Equatable {
  final String id;
  final String section;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String actionUrl;
  final int order;

  const HomeBannerItem({
    required this.id,
    required this.section,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.actionUrl,
    required this.order,
  });

  @override
  List<Object?> get props => [
        id,
        section,
        title,
        subtitle,
        imageUrl,
        actionUrl,
        order,
      ];
}
