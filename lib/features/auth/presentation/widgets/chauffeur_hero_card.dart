import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

class ChauffeurHeroCard extends StatefulWidget {
  const ChauffeurHeroCard({super.key});

  @override
  State<ChauffeurHeroCard> createState() => _ChauffeurHeroCardState();
}

class _ChauffeurHeroCardState extends State<ChauffeurHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _selectedServiceIndex = 0;

  final List<Map<String, dynamic>> _services = [
    {
      'icon': Icons.access_time_filled_rounded,
      'title': 'Hourly Driver',
      'tag': 'From \$12/hr',
      'subtitle': 'In-city trips & errands',
      'color': const Color(0xFFFFB800),
    },
    {
      'icon': Icons.alt_route_rounded,
      'title': 'One-Way Drop',
      'tag': 'City & Airport',
      'subtitle': 'Fixed fare transfers',
      'color': const Color(0xFF00E5FF),
    },
    {
      'icon': Icons.map_rounded,
      'title': 'Outstation Trip',
      'tag': 'Round-Trip',
      'subtitle': 'Weekend & highway travel',
      'color': const Color(0xFF10B981),
    },
    {
      'icon': Icons.nightlife_rounded,
      'title': 'Night & Party',
      'tag': 'Safe Return',
      'subtitle': 'Drive home in your car',
      'color': const Color(0xFFFF5722),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeService = _services[_selectedServiceIndex];
    final Color activeColor = activeService['color'] as Color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Luxury Hero Banner Card — theme-aware
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: AppDimens.borderRadiusLarge,
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1F293D), const Color(0xFF0F1420)]
                  : [const Color(0xFFF8FBFF), const Color(0xFFEAF1FB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: isDark ? 22 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Ambient Glowing Radial Accent
              Positioned(
                right: -25,
                top: -25,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        activeColor.withValues(alpha: isDark ? 0.35 : 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Perspective Grid Pattern
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: AppDimens.borderRadiusLarge,
                  child: CustomPaint(
                    painter: _RoadGridPainter(
                      gridColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                    ),
                  ),
                ),
              ),

              // Card Inner Layout
              Padding(
                padding: const EdgeInsets.all(AppDimens.p16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Information Area
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Live Availability & Verified Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimens.p8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.primary.withValues(alpha: 0.18)
                                      : AppColors.primaryDark.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.primary.withValues(alpha: 0.4)
                                        : AppColors.primaryDark.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '1,420+ VERIFIED DRIVERS NEARBY',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: isDark
                                            ? AppColors.primaryLight
                                            : AppColors.primaryDark,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Main Catchy Heading
                              Text(
                                'Hire a Chauffeur\nFor Your Own Car',
                                style: AppTypography.titleMedium.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.w900,
                                  height: 1.18,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Dynamic Selected Service Subtitle
                              Row(
                                children: [
                                  Icon(
                                    activeService['icon'] as IconData,
                                    size: 13,
                                    color: activeColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    activeService['subtitle'] as String,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: isDark
                                          ? Colors.white70
                                          : AppColors.textSecondaryLight,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Right Animated Car & Chauffeur Graphic
                        Expanded(
                          flex: 4,
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _animController.value * -6),
                                  child: child,
                                );
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer Glowing Ring
                                  Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: activeColor.withValues(
                                          alpha: isDark ? 0.35 : 0.25,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  // Center Graphic Circle
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          activeColor,
                                          activeColor.withValues(alpha: 0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: activeColor.withValues(
                                            alpha: isDark ? 0.45 : 0.3,
                                          ),
                                          blurRadius: 18,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.directions_car_filled_rounded,
                                        size: 36,
                                        color: isDark
                                            ? const Color(0xFF0D111A)
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  // Rating Pill Badge
                                  Positioned(
                                    bottom: -2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF0F141F)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.primary,
                                          width: 1,
                                        ),
                                        boxShadow: isDark
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.08),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 11,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '4.95 ★',
                                            style: AppTypography.labelSmall.copyWith(
                                              color: isDark
                                                  ? Colors.white
                                                  : AppColors.textPrimaryLight,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimens.p12),

        // Interactive Service Type Tabs
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _services.length,
            separatorBuilder: (_, index) => const SizedBox(width: AppDimens.p8),
            itemBuilder: (context, index) {
              final service = _services[index];
              final isSelected = index == _selectedServiceIndex;
              final Color color = service['color'] as Color;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedServiceIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.p12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? color.withValues(alpha: 0.18) : color.withValues(alpha: 0.12))
                        : (isDark ? AppColors.surfaceDark : AppColors.inputFillLight),
                    borderRadius: AppDimens.borderRadiusLarge,
                    border: Border.all(
                      color: isSelected
                          ? color
                          : (isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
                      width: isSelected ? 1.4 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        service['icon'] as IconData,
                        size: 14,
                        color: isSelected
                            ? color
                            : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        service['title'] as String,
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected
                              ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          service['tag'] as String,
                          style: AppTypography.labelSmall.copyWith(
                            color: color,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
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
      ],
    );
  }
}

class _RoadGridPainter extends CustomPainter {
  final Color gridColor;

  _RoadGridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 32) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + 40, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
