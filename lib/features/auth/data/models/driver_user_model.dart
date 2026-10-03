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
    String parsedName = json['name'] as String? ?? '';
    if (parsedName.isEmpty && json['firstName'] != null) {
      parsedName = '${json['firstName']} ${json['lastName'] ?? ''}'.trim();
    }
    
    return CustomerUserModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: parsedName,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      memberTier: json['memberTier'] as String? ?? json['member_tier'] as String? ?? 'Premium Member',
      totalRidesTaken: (json['totalRidesTaken'] as num?)?.toInt() ?? (json['total_rides_taken'] as num?)?.toInt() ?? 0,
      savedCarsCount: (json['savedCarsCount'] as num?)?.toInt() ?? (json['saved_cars_count'] as num?)?.toInt() ?? 0,
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
