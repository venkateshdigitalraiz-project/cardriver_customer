import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/rating_bloc.dart';
import '../bloc/rating_event.dart';
import '../bloc/rating_state.dart';

class RatingPageArgs {
  final String bookingId;
  final String? customerName;
  final String? customerId;
  final String? customerPhoto;
  final String? avatarUrl;
  final String? driverName;
  final String? driverPhoto;
  final String? vehicleInfo;
  final String? tripInfo;
  final String? title;
  final String? subtitle;
  final String? prompt;
  final String? pickupAddress;
  final String? dropAddress;
  final String? totalFare;
  final String? driverToken;
  final String backgroundImage;
  final BoxFit backgroundFit;

  const RatingPageArgs({
    this.bookingId = '',
    this.customerName,
    this.customerId,
    this.customerPhoto,
    this.avatarUrl,
    this.driverName,
    this.driverPhoto,
    this.vehicleInfo,
    this.tripInfo,
    this.title = 'Rate Your Customer',
    this.subtitle = 'Your feedback is valuable for us',
    this.prompt = 'How was your passenger?',
    this.pickupAddress,
    this.dropAddress,
    this.totalFare,
    this.driverToken,
    this.backgroundImage = 'assets/images/sunny_city_road.png',
    this.backgroundFit = BoxFit.fill,
  });

  factory RatingPageArgs.fromMap(Map<String, dynamic> map) {
    return RatingPageArgs(
      bookingId: map['bookingId']?.toString() ?? '',
      customerName:
          map['customerName']?.toString() ?? map['driverName']?.toString(),
      customerId: map['customerId']?.toString(),
      customerPhoto:
          map['customerPhoto']?.toString() ??
          map['avatarUrl']?.toString() ??
          map['driverPhoto']?.toString(),
      avatarUrl:
          map['avatarUrl']?.toString() ??
          map['customerPhoto']?.toString() ??
          map['driverPhoto']?.toString(),
      driverName: map['driverName']?.toString(),
      driverPhoto: map['driverPhoto']?.toString(),
      vehicleInfo: map['vehicleInfo']?.toString(),
      tripInfo: map['tripInfo']?.toString(),
      title: map['title']?.toString() ?? 'Rate Your Customer',
      subtitle:
          map['subtitle']?.toString() ?? 'Your feedback is valuable for us',
      prompt: map['prompt']?.toString() ?? 'How was your passenger?',
      pickupAddress: map['pickupAddress']?.toString(),
      dropAddress: map['dropAddress']?.toString(),
      totalFare: map['totalFare']?.toString(),
      driverToken: map['driverToken']?.toString(),
      backgroundImage:
          map['backgroundImage']?.toString() ??
          'assets/images/sunny_city_road.png',
      backgroundFit: map['backgroundFit'] == 'cover'
          ? BoxFit.cover
          : BoxFit.fill,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'customerName': customerName,
      'customerId': customerId,
      'customerPhoto': customerPhoto,
      'avatarUrl': avatarUrl,
      'driverName': driverName,
      'driverPhoto': driverPhoto,
      'vehicleInfo': vehicleInfo,
      'tripInfo': tripInfo,
      'title': title,
      'subtitle': subtitle,
      'prompt': prompt,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'totalFare': totalFare,
      'driverToken': driverToken,
      'backgroundImage': backgroundImage,
      'backgroundFit': backgroundFit.name,
    };
  }

  RatingPageArgs copyWith({
    String? bookingId,
    String? customerName,
    String? customerId,
    String? customerPhoto,
    String? avatarUrl,
    String? driverName,
    String? driverPhoto,
    String? vehicleInfo,
    String? tripInfo,
    String? title,
    String? subtitle,
    String? prompt,
    String? pickupAddress,
    String? dropAddress,
    String? totalFare,
    String? driverToken,
    String? backgroundImage,
    BoxFit? backgroundFit,
  }) {
    return RatingPageArgs(
      bookingId: bookingId ?? this.bookingId,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      customerPhoto: customerPhoto ?? this.customerPhoto,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      driverName: driverName ?? this.driverName,
      driverPhoto: driverPhoto ?? this.driverPhoto,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      tripInfo: tripInfo ?? this.tripInfo,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      prompt: prompt ?? this.prompt,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropAddress: dropAddress ?? this.dropAddress,
      totalFare: totalFare ?? this.totalFare,
      driverToken: driverToken ?? this.driverToken,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      backgroundFit: backgroundFit ?? this.backgroundFit,
    );
  }
}

typedef RatingPage = CustomerRatingPage;

class CustomerRatingPage extends StatefulWidget {
  final String bookingId;
  final String? customerName;
  final String? customerPhoto;
  final String? driverName;
  final String? driverPhoto;
  final String? vehicleInfo;
  final String? tripInfo;
  final RatingPageArgs? args;

  const CustomerRatingPage({
    super.key,
    this.bookingId = '',
    this.customerName,
    this.customerPhoto,
    this.driverName,
    this.driverPhoto,
    this.vehicleInfo,
    this.tripInfo,
    this.args,
  });

  @override
  State<CustomerRatingPage> createState() => _CustomerRatingPageState();
}

class _CustomerRatingPageState extends State<CustomerRatingPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _commentController;

  static const List<_FeedbackChipData> _chips = [
    _FeedbackChipData('Kind & Friendly', Icons.favorite_rounded),
    _FeedbackChipData('On Time', Icons.access_time_rounded),
    _FeedbackChipData('Polite', Icons.sentiment_satisfied_alt_rounded),
    _FeedbackChipData('Shared Ride Well', Icons.groups_rounded),
  ];

  String get _effectiveBookingId => widget.args?.bookingId.isNotEmpty == true
      ? widget.args!.bookingId
      : widget.bookingId;

  String? get _effectiveCustomerName =>
      widget.args?.customerName ??
      widget.customerName ??
      widget.args?.driverName ??
      widget.driverName;

  String? get _effectiveAvatarUrl =>
      widget.args?.avatarUrl ??
      widget.args?.customerPhoto ??
      widget.customerPhoto ??
      widget.args?.driverPhoto ??
      widget.driverPhoto;

  String get _effectiveTitle => widget.args?.title ?? 'Rate Your Customer';

  String get _effectiveSubtitle =>
      widget.args?.subtitle ?? 'Your feedback is valuable for us';

  String get _effectivePrompt =>
      widget.args?.prompt ?? 'How was your passenger?';

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String get _effectiveBackgroundImage =>
      widget.args?.backgroundImage ?? 'assets/images/sunny_city_road.png';

  BoxFit get _effectiveBackgroundFit =>
      widget.args?.backgroundFit ?? BoxFit.fill;

  @override
  Widget build(BuildContext context) {
    const primaryAmber = Color(0xFFF59E0B);
    final bgImage = _effectiveBackgroundImage;
    final hasBgImage = bgImage.isNotEmpty;

    return Theme(
      data: AppTheme.lightTheme.copyWith(scaffoldBackgroundColor: Colors.white),
      child: BlocConsumer<RatingBloc, RatingState>(
        listener: (context, state) {
          if (state.status == RatingSubmissionStatus.success) {
            _showCelebrationDialog(context);
          } else if (state.status == RatingSubmissionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ??
                      'Failed to submit rating. Please try again.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Color(0xFF1E293B),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                _effectiveTitle,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              centerTitle: true,
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Full-screen background image fitted to screen width & height
                if (hasBgImage)
                  Positioned.fill(
                    child: Image.asset(
                      bgImage,
                      width: double.infinity,
                      height: double.infinity,
                      fit: _effectiveBackgroundFit,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),

                // 2. Foreground Scrollable Content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // 1. Hero Artwork with Warm Yellow Skyline, Avatar & Map Pin
                        _buildHeroIllustration(hasBgImage: hasBgImage),
                        const SizedBox(height: 18),

                        // 2. Headings
                        Text(
                          _effectivePrompt,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _effectiveSubtitle,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. Golden Star Rating Row (.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0)
                        _buildStarRatingRow(context, state.rating),
                        const SizedBox(height: 20),

                        // 4. Feedback Chips matching attached image
                        _buildChipsSection(context, state.selectedTags),
                        const SizedBox(height: 20),

                        // 5. Add Comment Box with Pencil Icon
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        top: 2,
                                        right: 8,
                                      ),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _commentController,
                                        maxLength: 200,
                                        maxLines: 2,
                                        onChanged: (val) {
                                          setState(() {});
                                          context.read<RatingBloc>().add(
                                            ChangeCommentEvent(val),
                                          );
                                        },
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          color: Color(0xFF0F172A),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText:
                                              'Add a comment (optional)...',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 13.5,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          counterText: '',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${_commentController.text.length}/200',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 6. Vibrant Golden / Amber Pill Submit Rating Button ->
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryAmber,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: primaryAmber.withValues(
                                  alpha: 0.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed:
                                  state.status == RatingSubmissionStatus.loading
                                  ? null
                                  : () {
                                      HapticFeedback.mediumImpact();
                                      context.read<RatingBloc>().add(
                                        SubmitRatingEvent(
                                          bookingId: _effectiveBookingId,
                                          driverName: _effectiveCustomerName,
                                        ),
                                      );
                                    },
                              child:
                                  state.status == RatingSubmissionStatus.loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Submit Rating',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 19,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 7. Decorative Footer Illustration
                        _BottomCityCarIllustration(hasBgImage: hasBgImage),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= 1. Hero Artwork Illustration =================
  Widget _buildHeroIllustration({bool hasBgImage = false}) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft warm yellow skyline (fallback if no background image)
          if (!hasBgImage)
            Positioned.fill(
              child: CustomPaint(painter: _HeaderSkylinePainter()),
            ),

          // Central Passenger Portrait Avatar with White Border & Shadow
          Positioned(
            bottom: 12,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar circle
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        _effectiveAvatarUrl != null &&
                            _effectiveAvatarUrl!.isNotEmpty
                        ? Image.network(
                            _effectiveAvatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _defaultCustomerAvatar(),
                          )
                        : _defaultCustomerAvatar(),
                  ),
                ),

                // Golden Yellow Passenger Badge Icon at bottom-right
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),

                // Top-right Golden Map Pin Location Marker Icon
                const Positioned(
                  top: -8,
                  right: -12,
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFF59E0B),
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultCustomerAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Image.network(
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?fit=crop&w=300&q=80',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            (_effectiveCustomerName?.isNotEmpty == true)
                ? _effectiveCustomerName![0].toUpperCase()
                : 'P',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  // ================= 3. Star Rating Row (.5 to 5.0) =================
  Widget _buildStarRatingRow(BuildContext context, double currentRating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1; // 1, 2, 3, 4, 5
        final isFull = currentRating >= starNumber;
        final isHalf = !isFull && currentRating >= (starNumber - 0.5);

        IconData iconData;
        Color starColor;

        if (isFull) {
          iconData = Icons.star_rounded;
          starColor = const Color(0xFFFFB800);
        } else if (isHalf) {
          iconData = Icons.star_half_rounded;
          starColor = const Color(0xFFFFB800);
        } else {
          iconData = Icons.star_rounded;
          starColor = const Color(
            0xFFE2E8F0,
          ); // Light grey star as in attached design
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: (isFull || isHalf) ? 1.12 : 1.0,
                  curve: Curves.easeOutBack,
                  child: Icon(iconData, size: 46, color: starColor),
                ),
                // Left half tap zone (.5, 1.5, 2.5, 3.5, 4.5)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 24,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<RatingBloc>().add(
                        ChangeRatingScoreEvent(starNumber - 0.5),
                      );
                    },
                  ),
                ),
                // Right half tap zone (1.0, 2.0, 3.0, 4.0, 5.0)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 24,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<RatingBloc>().add(
                        ChangeRatingScoreEvent(starNumber.toDouble()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ================= 4. Feedback Chips Section =================
  Widget _buildChipsSection(BuildContext context, List<String> selectedTags) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Row 1: Kind & Friendly, On Time
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChipItem(context, _chips[0], selectedTags),
              const SizedBox(width: 8),
              _buildChipItem(context, _chips[1], selectedTags),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: Polite, Shared Ride Well
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChipItem(context, _chips[2], selectedTags),
              const SizedBox(width: 8),
              _buildChipItem(context, _chips[3], selectedTags),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipItem(
    BuildContext context,
    _FeedbackChipData data,
    List<String> selectedTags,
  ) {
    final isSelected = selectedTags.contains(data.label);
    const primaryAmber = Color(0xFFF59E0B);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<RatingBloc>().add(ToggleRatingTagEvent(data.label));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryAmber : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryAmber : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryAmber.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              data.icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF1E293B),
            ),
            const SizedBox(width: 6),
            Text(
              data.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCelebrationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Thank You!',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your review helps us keep our service quality exceptional.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeedbackChipData {
  final String label;
  final IconData icon;
  const _FeedbackChipData(this.label, this.icon);
}

// ================= Custom Painters for Visual Fidelity =================

/// Draws the soft warm golden yellow city silhouette behind the avatar
class _HeaderSkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final bldgPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    // Stylized buildings silhouette
    final path = Path();
    final h = size.height * 0.72;
    path.moveTo(0, h);
    path.lineTo(size.width * 0.08, h);
    path.lineTo(size.width * 0.08, h - 30);
    path.lineTo(size.width * 0.16, h - 30);
    path.lineTo(size.width * 0.16, h - 18);
    path.lineTo(size.width * 0.24, h - 18);
    path.lineTo(size.width * 0.24, h - 45);
    path.lineTo(size.width * 0.32, h - 45);
    path.lineTo(size.width * 0.32, h - 22);
    path.lineTo(size.width * 0.68, h - 22);
    path.lineTo(size.width * 0.68, h - 40);
    path.lineTo(size.width * 0.76, h - 40);
    path.lineTo(size.width * 0.76, h - 15);
    path.lineTo(size.width * 0.84, h - 15);
    path.lineTo(size.width * 0.84, h - 32);
    path.lineTo(size.width * 0.92, h - 32);
    path.lineTo(size.width * 0.92, h);
    path.lineTo(size.width, h);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, bldgPaint);

    // Soft white bottom fade
    final fadePaint = Paint()
      ..shader =
          LinearGradient(
            colors: [Colors.white.withValues(alpha: 0.0), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height * 0.65,
              size.width,
              size.height * 0.35,
            ),
          );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.65, size.width, size.height * 0.35),
      fadePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stylized Sedan Car vector
class _CarVectorGraphic extends StatelessWidget {
  final Color color;
  const _CarVectorGraphic({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CarPainter(color: color));
  }
}

class _CarPainter extends CustomPainter {
  final Color color;
  const _CarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final windowPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final wheelPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final rimPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Car Body Path
    final body = Path();
    body.moveTo(w * 0.05, h * 0.65);
    body.quadraticBezierTo(w * 0.05, h * 0.45, w * 0.15, h * 0.45);
    body.lineTo(w * 0.30, h * 0.45);
    body.quadraticBezierTo(w * 0.40, h * 0.20, w * 0.55, h * 0.20);
    body.lineTo(w * 0.75, h * 0.20);
    body.quadraticBezierTo(w * 0.88, h * 0.25, w * 0.95, h * 0.50);
    body.lineTo(w * 0.98, h * 0.65);
    body.quadraticBezierTo(w * 0.98, h * 0.72, w * 0.92, h * 0.72);
    body.lineTo(w * 0.08, h * 0.72);
    body.quadraticBezierTo(w * 0.05, h * 0.72, w * 0.05, h * 0.65);
    body.close();
    canvas.drawPath(body, bodyPaint);

    // Front & Back Windows
    final window = Path();
    window.moveTo(w * 0.35, h * 0.43);
    window.lineTo(w * 0.43, h * 0.25);
    window.lineTo(w * 0.72, h * 0.25);
    window.lineTo(w * 0.82, h * 0.43);
    window.close();
    canvas.drawPath(window, windowPaint);

    // Wheels
    final wheelRadius = h * 0.16;
    canvas.drawCircle(Offset(w * 0.25, h * 0.72), wheelRadius, wheelPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.72), wheelRadius, wheelPaint);
    canvas.drawCircle(Offset(w * 0.25, h * 0.72), wheelRadius * 0.5, rimPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.72), wheelRadius * 0.5, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bottom Decorative Golden Waves, Trees & little Black Car
class _BottomCityCarIllustration extends StatelessWidget {
  final bool hasBgImage;
  const _BottomCityCarIllustration({this.hasBgImage = false});

  @override
  Widget build(BuildContext context) {
    if (hasBgImage) {
      return const SizedBox(height: 36);
    }
    return SizedBox(
      height: 90,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Golden landscape silhouette & layered warm waves
          Positioned.fill(child: CustomPaint(painter: _BottomWavePainter())),
          // Little Black Car traveling on top of the golden road
          Positioned(
            bottom: 24,
            child: Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const _CarVectorGraphic(color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Subtle warm yellow trees & hills behind waves
    final bgHillsPaint = Paint()
      ..color = const Color(0xFFFEF08A).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final hills = Path();
    hills.moveTo(0, h * 0.65);
    hills.quadraticBezierTo(w * 0.15, h * 0.35, w * 0.35, h * 0.55);
    hills.quadraticBezierTo(w * 0.55, h * 0.3, w * 0.75, h * 0.5);
    hills.quadraticBezierTo(w * 0.9, h * 0.35, w, h * 0.55);
    hills.lineTo(w, h);
    hills.lineTo(0, h);
    hills.close();
    canvas.drawPath(hills, bgHillsPaint);

    // Tree silhouettes on the left and right
    final treePaint = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.12, h * 0.52), 12, treePaint);
    canvas.drawCircle(Offset(w * 0.18, h * 0.56), 9, treePaint);
    canvas.drawCircle(Offset(w * 0.82, h * 0.52), 11, treePaint);
    canvas.drawCircle(Offset(w * 0.88, h * 0.54), 14, treePaint);

    // 2. Back Wave (Warm Amber)
    final backWavePaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    final backWave = Path();
    backWave.moveTo(0, h * 0.62);
    backWave.quadraticBezierTo(w * 0.3, h * 0.42, w * 0.55, h * 0.58);
    backWave.quadraticBezierTo(w * 0.8, h * 0.72, w, h * 0.48);
    backWave.lineTo(w, h);
    backWave.lineTo(0, h);
    backWave.close();
    canvas.drawPath(backWave, backWavePaint);

    // 3. Front Wave / Road (Golden Amber)
    final frontWavePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    final frontWave = Path();
    frontWave.moveTo(0, h * 0.75);
    frontWave.quadraticBezierTo(w * 0.35, h * 0.60, w * 0.65, h * 0.68);
    frontWave.quadraticBezierTo(w * 0.85, h * 0.72, w, h * 0.66);
    frontWave.lineTo(w, h);
    frontWave.lineTo(0, h);
    frontWave.close();
    canvas.drawPath(frontWave, frontWavePaint);

    // Road white dashed center curve
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final roadLine = Path();
    roadLine.moveTo(0, h * 0.82);
    roadLine.quadraticBezierTo(w * 0.35, h * 0.67, w * 0.65, h * 0.75);
    roadLine.quadraticBezierTo(w * 0.85, h * 0.79, w, h * 0.73);
    canvas.drawPath(roadLine, dashPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
