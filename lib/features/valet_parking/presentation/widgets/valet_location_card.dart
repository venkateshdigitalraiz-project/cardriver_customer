import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/valet_parking_location.dart';

class ValetLocationCard extends StatelessWidget {
  final ValetParkingLocation location;
  final VoidCallback onBookTap;

  const ValetLocationCard({
    super.key,
    required this.location,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161D29) : Colors.white;
    final borderColor = isDark ? const Color(0xFF263347) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Location Icon, Title, Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.local_parking_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: AppTypography.titleMedium.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: subColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location.address,
                              style: AppTypography.bodySmall.copyWith(
                                color: subColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Rating Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        location.rating.toStringAsFixed(1),
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Distance & Availability Row
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.navigation_rounded,
                  label: '${location.distanceKm} km away',
                  color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7),
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.access_time_rounded,
                  label: location.operatingHours,
                  color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                ),
                const Spacer(),
                Text(
                  '${location.availableSlots} slots left',
                  style: AppTypography.labelSmall.copyWith(
                    color: location.availableSlots > 5
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFF5722),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Feature Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: location.features.take(3).map((feat) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    feat,
                    style: AppTypography.labelSmall.copyWith(
                      color: subColor,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            const Divider(height: 1, color: Color(0x1F94A3B8)),
            const SizedBox(height: 12),

            // Price & Book Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate',
                      style: AppTypography.labelSmall.copyWith(color: subColor),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '₹${location.ratePerHour.toInt()}',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: ' / hr',
                            style: AppTypography.bodySmall.copyWith(
                              color: subColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onBookTap,
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: const Text('Book Valet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: const Color(0xFF0B0E14),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    textStyle: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
