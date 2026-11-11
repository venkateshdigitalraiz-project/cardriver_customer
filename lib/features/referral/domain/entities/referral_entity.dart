import 'package:equatable/equatable.dart';

class ReferralEntity extends Equatable {
  final String referralCode;
  final String shareLink;
  final double rewardPerReferral;
  final int totalReferrals;
  final double totalEarned;
  final String currency;
  final List<String> howItWorks;

  const ReferralEntity({
    required this.referralCode,
    required this.shareLink,
    this.rewardPerReferral = 100.0,
    this.totalReferrals = 0,
    this.totalEarned = 0.0,
    this.currency = '₹',
    this.howItWorks = const [
      'Share your referral code or link with friends & family.',
      'They sign up and book their first comfortable ride.',
      'You earn ₹100 ride cashback directly into your wallet!',
    ],
  });

  @override
  List<Object?> get props => [
        referralCode,
        shareLink,
        rewardPerReferral,
        totalReferrals,
        totalEarned,
        currency,
        howItWorks,
      ];
}

