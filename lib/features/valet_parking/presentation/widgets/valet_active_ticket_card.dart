import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/valet_parking_ticket.dart';

class ValetActiveTicketCard extends StatelessWidget {
  final ValetParkingTicket ticket;
  final VoidCallback onRetrievalRequested;

  const ValetActiveTicketCard({
    super.key,
    required this.ticket,
    required this.onRetrievalRequested,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRetrieval = ticket.status == ValetTicketStatus.retrievalRequested;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2838), const Color(0xFF111722)]
              : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Valet Pass Tag + Status Badge
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DIGITAL VALET PASS',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRetrieval
                        ? const Color(0xFFFF5722).withValues(alpha: 0.2)
                        : const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isRetrieval
                          ? const Color(0xFFFF5722)
                          : const Color(0xFF10B981),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isRetrieval ? 'Retrieving Car...' : 'Parked Safely',
                    style: AppTypography.labelSmall.copyWith(
                      color: isRetrieval
                          ? const Color(0xFFFF7043)
                          : const Color(0xFF34D399),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dashed Divider Look
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Middle Details: Vehicle & Location
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.vehicleModel,
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // License plate badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            ticket.vehicleNumber,
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Bay & OTP Block
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'PASS OTP',
                          style: AppTypography.labelSmall.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          ticket.valetPassOtp,
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          'Bay: ${ticket.slotNumber}',
                          style: AppTypography.labelSmall.copyWith(
                            color: const Color(0xFFCBD5E1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location row
                Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ticket.locationName,
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFFCBD5E1),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Attendant Row with Call Action
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.valetAttendantName,
                              style: AppTypography.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Assigned Valet Captain',
                              style: AppTypography.labelSmall.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final uri = Uri.parse('tel:${ticket.valetPhone}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        icon: const Icon(Icons.call_rounded),
                        color: const Color(0xFF10B981),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF10B981).withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action: Request Retrieval
          Container(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isRetrieval ? null : onRetrievalRequested,
                icon: Icon(
                  isRetrieval ? Icons.hourglass_top_rounded : Icons.car_rental_rounded,
                  size: 20,
                ),
                label: Text(
                  isRetrieval
                      ? 'Valet is Bringing Your Car'
                      : 'Request Car Retrieval',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRetrieval
                      ? const Color(0xFF334155)
                      : AppColors.primary,
                  foregroundColor: isRetrieval
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF0B0E14),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  textStyle: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
