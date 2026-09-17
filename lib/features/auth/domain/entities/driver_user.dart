import 'package:equatable/equatable.dart';

/// Domain Entity representing an authenticated Customer User looking to hire car drivers.
class CustomerUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String memberTier;
  final int totalRidesTaken;
  final int savedCarsCount;

  const CustomerUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.memberTier = 'Premium Member',
    this.totalRidesTaken = 14,
    this.savedCarsCount = 2,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatarUrl,
        memberTier,
        totalRidesTaken,
        savedCarsCount,
      ];
}
