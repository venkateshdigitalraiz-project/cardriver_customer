import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../booking/presentation/pages/booking_wizard_screen.dart';
// import '../../../drivers/domain/entities/driver_search_type.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/valet_event_booking_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatelessWidget {
  const _HomePageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Hero Section with integrated App Bar & overlay Location Card
            _buildHeroSection(context),
            const SizedBox(height: 52), // Space for the bottom half of the overlay card + gap

            // "For You" Staggered Grid
            // _buildStaggeredGrid(context),
            // const SizedBox(height: 24),
            _buildLocalOutstationSection(context),
            const SizedBox(height: 32),

            // Valet Event Booking Card with labeled sample fields & Add button
            _buildValetEventBookingSection(context),
            const SizedBox(height: 32),

            // "Suggestions" Carousel
            _buildSuggestionsSection(context),
            const SizedBox(height: 32),

            // Ongoing Rides Section
            _buildOngoingRides(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Top Background Image / Gradient
        SizedBox(
          height: 260,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/highway_cars_upward.gif',
                fit: BoxFit.cover,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom App Bar
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFBE74D),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.drive_eta,
                                  color: Colors.black87,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text.rich(
                                TextSpan(
                                  text: 'Driver',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' on Hire',
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Overlay Location Card (Overlays GIF and below card)
        Positioned(
          bottom: -36,
          left: 20,
          right: 20,
          child: _buildLocationCard(context),
        ),
      ],
    );
  }

  // User Current Location Card
  Widget _buildLocationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE74D), // Yellow from image
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.black87,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '617, Kukatpally, Hyderabad',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Telangana, 500072, India',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Verified Drivers section containing attached Local and Outstation cards
  Widget _buildLocalOutstationSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verified Drivers Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF2E7D32),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Professional & Police Verified Drivers',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Experienced drivers for your safe journey',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Attached Local and Outstation Cards
            Row(
              children: [
                // Local Card
                Expanded(
                  child: _buildServiceOptionCard(
                    context: context,
                    title: 'Local',
                    subtitle: 'Within city • From ₹350',
                    icon: Icons.directions_car_filled_rounded,
                    primaryColor: const Color(0xFF266475),
                    bgColor: const Color(0xFFF2F8F9),
                    imagePath: 'assets/images/local.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookingWizardScreen(
                            initialTripType: 'Local',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Outstation Card
                Expanded(
                  child: _buildServiceOptionCard(
                    context: context,
                    title: 'Outstation',
                    subtitle: 'Intercity • From ₹1000',
                    icon: Icons.alt_route_rounded,
                    primaryColor: const Color(0xFFE65100),
                    bgColor: const Color(0xFFFFF3E0),
                    imagePath: 'assets/images/outstation.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookingWizardScreen(
                            initialTripType: 'Outstation',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required Color bgColor,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryColor, size: 22),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: primaryColor.withValues(alpha: 0.6),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValetEventBookingSection(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final hasBooking = state.valetBookingResponse != null;
        final bookingData = state.valetBookingResponse?.data;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => _openValetBookingBottomSheet(context),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Simple, clean circular service icon
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBE74D).withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_parking_rounded,
                          color: Colors.black87,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Clean Title and Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Valet Event Booking',
                                  style: AppTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                                if (hasBooking) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      bookingData?.bookingId ?? 'BOOKED',
                                      style: const TextStyle(
                                        color: Color(0xFF047857),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              hasBooking
                                  ? 'Royals Wedding Gala • View details'
                                  : 'Weddings & events • From ₹11,800',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Professional action button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBE74D),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hasBooking ? 'View' : 'Book',
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.black87,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openValetBookingBottomSheet(BuildContext context) {
    final homeBloc = context.read<HomeBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return BlocProvider.value(
          value: homeBloc,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(modalContext).size.height * 0.92,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
                      child: ValetEventBookingCard(isBottomSheet: true),
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

  Widget _buildSuggestionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Suggestions',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: PageView.builder(
            onPageChanged: (index) {
              context.read<HomeBloc>().add(BannerPageChanged(index));
            },
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF1F8FF),
                      Color(0xFFFDE4F2),
                    ], // Light blue to light pink
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Text Content
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Explore In-city',
                              style: AppTypography.titleLarge.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Across town, around the corner, and everywhere in between.',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.black54,
                                height: 1.4,
                                fontSize: 11,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF266475),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Book Now',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Illustration Placeholder
                      Expanded(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: const Icon(
                              Icons.location_city,
                              size: 60,
                              color: Color(0xFF266475),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Pagination Dots
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (dotIndex) {
                final isActive = dotIndex == state.currentBannerIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActive
                        ? const Color(0xFFFBE74D)
                        : Colors.grey.shade300,
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOngoingRides(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ongoing Rides',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              Text(
                'See all',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0277BD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Total: ',
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text: '₹600',
                                style: AppTypography.titleLarge.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Trip is now live',
                          style: AppTypography.labelMedium.copyWith(
                            color: const Color(0xFF0277BD),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '06 Oct, 04:20 pm',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.black38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: Color(0xFF1976D2),
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Sedan',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA), // Light cyan
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Ongoing',
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF006064),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text('In-city', style: AppTypography.labelSmall),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 16,
                      color: Colors.grey.shade300,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 6),
                        Text('4h 30m', style: AppTypography.labelSmall),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 16,
                      color: Colors.grey.shade300,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.swap_horiz,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text('One-way', style: AppTypography.labelSmall),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
