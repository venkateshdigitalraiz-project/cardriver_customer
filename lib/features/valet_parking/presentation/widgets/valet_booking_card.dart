import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/valet_booking_entity.dart';

class ValetBookingCard extends StatelessWidget {
  final ValetBookingEntity booking;
  final VoidCallback onTap;

  const ValetBookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161D29) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF263347) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextCol =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final isCompleted = booking.isCompleted;
    final isInProgress = booking.isInProgress;

    final statusBg = isCompleted
        ? const Color(0xFF10B981).withValues(alpha: 0.15)
        : isInProgress
            ? AppColors.primary.withValues(alpha: 0.2)
            : const Color(0xFF38BDF8).withValues(alpha: 0.15);

    final statusTextCol = isCompleted
        ? const Color(0xFF10B981)
        : isInProgress
            ? AppColors.primary
            : const Color(0xFF38BDF8);

    final dateStr = DateFormat('EEE, d MMM yyyy').format(booking.eventDate);

    final eventIcon = booking.eventType.toLowerCase().contains('wedding')
        ? Icons.celebration_rounded
        : Icons.business_center_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isInProgress ? AppColors.primary.withValues(alpha: 0.5) : borderColor,
          width: isInProgress ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isInProgress
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Booking ID, Type Icon & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            eventIcon,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.bookingId,
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              booking.eventType.toUpperCase(),
                              style: AppTypography.labelSmall.copyWith(
                                color: subTextCol,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusTextCol.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        booking.status.replaceAll('_', ' ').toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: statusTextCol,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Event Title
                Text(
                  booking.eventName,
                  style: AppTypography.titleMedium.copyWith(
                    color: textCol,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // Venue & Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.place_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.venueName,
                            style: AppTypography.bodySmall.copyWith(
                              color: textCol,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            booking.address,
                            style: AppTypography.bodySmall.copyWith(
                              color: subTextCol,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date & Time Grid
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F141D)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Color(0xFF00E5FF),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                dateStr,
                                style: AppTypography.labelSmall.copyWith(
                                  color: textCol,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 16,
                        width: 1,
                        color: Colors.grey.withValues(alpha: 0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_formatTo12Hour(booking.startTime)} - ${_formatTo12Hour(booking.endTime)} (${booking.hours}h)',
                            style: AppTypography.labelSmall.copyWith(
                              color: textCol,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Valet Staff & Total Pricing Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.group_rounded,
                            size: 14,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${booking.person} Valet Captains Assigned',
                          style: AppTypography.labelSmall.copyWith(
                            color: subTextCol,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${booking.pricing.totalAmount.toInt()}',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          booking.paymentStatus.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: booking.isPaid
                                ? const Color(0xFF10B981)
                                : const Color(0xFFFF9800),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }

  String _formatTo12Hour(String timeStr) {
    final trimmed = timeStr.trim();
    if (trimmed.isEmpty) return trimmed;

    if (trimmed.toUpperCase().contains('AM') ||
        trimmed.toUpperCase().contains('PM')) {
      return trimmed;
    }

    try {
      final parts = trimmed.split(':');
      if (parts.isNotEmpty) {
        final hour = int.tryParse(parts[0]);
        final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
        if (hour != null) {
          final period = hour >= 12 ? 'PM' : 'AM';
          final hour12 = hour == 0
              ? 12
              : (hour > 12 ? hour - 12 : hour);
          final minStr = minute.toString().padLeft(2, '0');
          return '$hour12:$minStr $period';
        }
      }
    } catch (_) {}

    return trimmed;
  }
}
