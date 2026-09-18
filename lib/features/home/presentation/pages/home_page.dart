import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/main_navigation/presentation/bloc/navigation_bloc.dart';
import '../../../../features/main_navigation/presentation/bloc/navigation_event.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

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
            // Top Hero Section with integrated App Bar and floating card
            _buildHeroSection(context),
            const SizedBox(height: 120), // Space for the floating card
            // "For You" Staggered Grid
            _buildStaggeredGrid(context),
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
          height: 280,
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
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
                                      text: 'on Hire',
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Floating Action Card
        Positioned(
          bottom: -100,
          left: 20,
          right: 20,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Yellow Banner (Layered underneath)
              Container(
                margin: const EdgeInsets.only(top: 30, left: 16, right: 16),
                padding: const EdgeInsets.only(
                  top: 50,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFBE74D), // Yellow from image
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '617, Kukatpally, Hyderabad',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
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
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // White Toggle Card (On Top)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Plan your trip
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        alignment: Alignment.center,
                        child: Text(
                          'Plan your trip',
                          style: AppTypography.labelLarge.copyWith(
                            color: const Color(0xFF0277BD),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    // Divider
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    // Go now
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to booking tab
                          context.read<NavigationBloc>().add(TabChanged(1));
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF266475), // Dark teal from image
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.flash_on,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Go Now',
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStaggeredGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'For You',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_circle_outline,
                      size: 16,
                      color: Color(0xFF0277BD),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'How it works',
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF0277BD),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column (Tall Schedule Card)
              Expanded(
                flex: 1,
                child: _buildStaggeredCard(
                  context: context,
                  height: 248, // 120 + 8 + 120 = 248
                  title: 'Schedule',
                  subtitle: 'Reserve in advance',
                  imagePath: 'assets/images/schedule.png',
                  fallbackIcon: Icons.schedule,
                  iconColor: const Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(width: 8), // Decreased gap
              // Right Column
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Top Wide Card (Instant)
                    _buildStaggeredCard(
                      context: context,
                      height: 120, // Decreased height
                      title: 'Instant',
                      subtitle: 'Get a driver in minutes',
                      imagePath: 'assets/images/instant.png',
                      fallbackIcon: Icons.directions_car,
                      iconColor: const Color(0xFF1976D2),
                    ),
                    const SizedBox(height: 8), // Decreased gap
                    // Bottom Row (Two small square cards)
                    Row(
                      children: [
                        Expanded(
                          child: _buildStaggeredCard(
                            context: context,
                            height: 120, // Decreased height
                            title: 'Subscription',
                            subtitle: 'Recurring trips',
                            imagePath: 'assets/images/subs.png',
                            fallbackIcon: Icons.star,
                            iconColor: const Color(0xFFFBC02D),
                            isSquare: true,
                          ),
                        ),
                        const SizedBox(width: 8), // Decreased gap
                        Expanded(
                          child: _buildStaggeredCard(
                            context: context,
                            height: 120, // Decreased height
                            title: 'Daily',
                            subtitle: 'Rides for everyday',
                            imagePath: 'assets/images/daily.png',
                            fallbackIcon: Icons.calendar_month,
                            iconColor: const Color(0xFF1976D2),
                            isSquare: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredCard({
    required BuildContext context,
    required double height,
    required String title,
    required String subtitle,
    required String imagePath,
    required IconData fallbackIcon,
    required Color iconColor,
    bool isSquare = false,
  }) {
    final bool isSmallHeight = height <= 150;

    return GestureDetector(
      onTap: () {
        context.read<NavigationBloc>().add(TabChanged(1));
      },
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias, // Clip image to border radius
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Stack(
          children: [
            // IMAGE LAYER (Bottom Layer)
            // By filling the bounds and using BoxFit.contain, we guarantee the image 
            // scales to the absolute maximum physical size allowed by the card's width/height 
            // without ever clipping or overflowing.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: isSmallHeight ? 0 : 30, // For schedule card, give a small top margin to prevent head from going too high
              child: Padding(
                padding: EdgeInsets.only(
                  right: isSmallHeight ? 8.0 : 0.0, // Slight right padding for small cards so they don't hit the exact edge
                  bottom: isSmallHeight ? 8.0 : 0.0,
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      fallbackIcon,
                      color: iconColor.withValues(alpha: 0.5),
                      size: isSmallHeight ? 48 : 80,
                    );
                  },
                ),
              ),
            ),
            
            // TEXT LAYER (Top Layer)
            // Drawn on top, so it is mathematically impossible for the image to cover the text
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(isSmallHeight ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        // Removed ellipsis so FittedBox forces it to scale down instead of truncating
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          fontSize: isSmallHeight ? 13 : 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.black54,
                        fontSize: isSmallHeight ? 10 : 11,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
