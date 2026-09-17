import '../../domain/entities/driver_user.dart';

class CustomerUserModel extends CustomerUser {
  const CustomerUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.avatarUrl,
    super.memberTier = 'Premium Member',
    super.totalRidesTaken = 14,
    super.savedCarsCount = 2,
  });

  factory CustomerUserModel.fromJson(Map<String, dynamic> json) {
    return CustomerUserModel(
      id: json['id'] as String? ?? 'cust_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'David Sterling',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      memberTier: json['member_tier'] as String? ?? 'Gold Tier Customer',
      totalRidesTaken: (json['total_rides_taken'] as num?)?.toInt() ?? 14,
      savedCarsCount: (json['saved_cars_count'] as num?)?.toInt() ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'member_tier': memberTier,
      'total_rides_taken': totalRidesTaken,
      'saved_cars_count': savedCarsCount,
    };
  }
}
