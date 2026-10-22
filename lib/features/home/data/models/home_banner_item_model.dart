import '../../domain/entities/home_banner_item.dart';

/// Data model representing a home banner item extending the domain entity.
class HomeBannerItemModel extends HomeBannerItem {
  const HomeBannerItemModel({
    required super.id,
    required super.section,
    required super.title,
    required super.subtitle,
    required super.imageUrl,
    required super.actionUrl,
    required super.order,
  });

  factory HomeBannerItemModel.fromJson(Map<String, dynamic> json) {
    return HomeBannerItemModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      actionUrl: json['actionUrl']?.toString() ?? '',
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'order': order,
    };
  }
}
