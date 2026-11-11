import '../../domain/entities/referral_entity.dart';

class ReferralModel extends ReferralEntity {
  const ReferralModel({
    required super.referralCode,
    required super.shareLink,
    super.rewardPerReferral,
    super.totalReferrals,
    super.totalEarned,
    super.currency,
    super.howItWorks,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json, {String? defaultCode}) {
    final code = json['referralCode']?.toString() ??
        json['code']?.toString() ??
        json['referral_code']?.toString() ??
        defaultCode ??
        'USER-5678';

    final link = json['shareLink']?.toString() ??
        json['share_url']?.toString() ??
        json['link']?.toString() ??
        'https://cardrivercustomer.app/join?ref=$code';

    final reward = (json['rewardPerReferral'] ??
            json['reward_amount'] ??
            json['reward'] ??
            100.0)
        .toDouble();

    final referrals = (json['totalReferrals'] ??
            json['total_referrals'] ??
            json['count'] ??
            0) as num;

    final earned = (json['totalEarned'] ??
            json['total_earned'] ??
            json['earned_amount'] ??
            (referrals * reward))
        .toDouble();

    final currency = json['currency']?.toString() ?? '₹';

    List<String> steps = const [
      'Share your referral code or link with friends & family.',
      'They sign up and book their first comfortable ride.',
      'You earn ₹100 ride cashback directly into your wallet!',
    ];

    if (json['howItWorks'] is List) {
      steps = (json['howItWorks'] as List)
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return ReferralModel(
      referralCode: code,
      shareLink: link,
      rewardPerReferral: reward,
      totalReferrals: referrals.toInt(),
      totalEarned: earned,
      currency: currency,
      howItWorks: steps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referralCode': referralCode,
      'shareLink': shareLink,
      'rewardPerReferral': rewardPerReferral,
      'totalReferrals': totalReferrals,
      'totalEarned': totalEarned,
      'currency': currency,
      'howItWorks': howItWorks,
    };
  }
}

