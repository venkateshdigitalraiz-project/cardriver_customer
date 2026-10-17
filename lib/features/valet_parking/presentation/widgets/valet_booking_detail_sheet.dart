import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/valet_booking_entity.dart';

class ValetBookingDetailSheet extends StatelessWidget {
  final ValetBookingEntity booking;

  const ValetBookingDetailSheet({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    const textCol = Color(0xFF0F172A);
    const subTextCol = Color(0xFF64748B);
    const cardBg = Color(0xFFF8FAFC);
    const borderCol = Color(0xFFE2E8F0);

    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(booking.eventDate);
    final isCompleted = booking.isCompleted;
    final isInProgress = booking.isInProgress;

    // Status styling configuration
    final statusColor = isCompleted
        ? const Color(0xFF10B981)
        : isInProgress
        ? const Color(0xFFF59E0B)
        : const Color(0xFF0284C7);

    final statusBg = statusColor.withValues(alpha: 0.12);
    final statusLabel = booking.status.replaceAll('_', ' ').toUpperCase();

    // Event type styling
    final isWedding = booking.eventType.toLowerCase().contains('wedding');
    final eventTypeIcon = isWedding
        ? Icons.celebration_rounded
        : Icons.business_center_rounded;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Drag Indicator Pill
          Center(
            child: Container(
              width: 46,
              height: 4.5,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // 2. Top Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Booking ID Pill with Copy button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBE74D).withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_parking_rounded,
                        color: Color(0xFFD97706),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              booking.bookingId,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: textCol,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: booking.bookingId),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Booking ID copied!'),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: const Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 14,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Valet Service Order Reference',
                          style: TextStyle(
                            fontSize: 11,
                            color: subTextCol,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Close Button
                Material(
                  color: const Color(0xFFF1F5F9),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // 3. Scrollable Content Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3A. Hero Event Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFBE74D).withValues(alpha: 0.16),
                          const Color(0xFFFFB800).withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFB800).withValues(alpha: 0.35),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFFFB800,
                          ).withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag Row: Event Type + Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    eventTypeIcon,
                                    size: 13,
                                    color: const Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    booking.eventType.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
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
                                  color: statusColor.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Event Title
                        Text(
                          booking.eventName,
                          style: AppTypography.titleLarge.copyWith(
                            color: textCol,
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Quick 3-Metric Overview Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricPill(
                                icon: Icons.calendar_month_rounded,
                                label: 'Date',
                                value: DateFormat(
                                  'd MMM yyyy',
                                ).format(booking.eventDate),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricPill(
                                icon: Icons.timer_outlined,
                                label: 'Duration',
                                value: '${booking.hours} Hours',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricPill(
                                icon: Icons.people_alt_rounded,
                                label: 'Staff Crew',
                                value: '${booking.person} person',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3B. Schedule & Service Logistics Card
                  _buildSectionHeader(
                    icon: Icons.access_time_filled_rounded,
                    title: 'Schedule & Service Details',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Full Event Date',
                          value: dateStr,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                        ),
                        _buildDetailRow(
                          icon: Icons.schedule_rounded,
                          label: 'Service Window',
                          value:
                              '${_formatTo12Hour(booking.startTime)} - ${_formatTo12Hour(booking.endTime)} (${booking.hours} hours on-duty)',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                        ),
                        _buildDetailRow(
                          icon: Icons.badge_rounded,
                          label: 'Valet Crew Assigned',
                          value:
                              '${booking.person} trained & verified parking person',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3C. Venue & Destination Location Card
                  _buildSectionHeader(
                    icon: Icons.location_on_rounded,
                    title: 'Venue & Destination Address',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFD97706,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.apartment_rounded,
                                color: Color(0xFFD97706),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.venueName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: textCol,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Designated Venue',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: subTextCol,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.pin_drop_rounded,
                                size: 16,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  booking.address,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF334155),
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (booking.coordinates != null &&
                            booking.coordinates!.length >= 2) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.gps_fixed_rounded,
                                  size: 13,
                                  color: Color(0xFF047857),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'GPS: ${booking.coordinates![0].toStringAsFixed(4)}, ${booking.coordinates![1].toStringAsFixed(4)}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3D. Special Instructions (if any)
                  if (booking.specialInstructions.trim().isNotEmpty) ...[
                    _buildSectionHeader(
                      icon: Icons.notes_rounded,
                      title: 'Special Instructions',
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBE74D).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(
                            0xFFFFB800,
                          ).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.sticky_note_2_rounded,
                            size: 18,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              booking.specialInstructions,
                              style: const TextStyle(
                                fontSize: 13,
                                color: textCol,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 3E. Pricing & Payment Breakdown Card
                  _buildSectionHeader(
                    icon: Icons.receipt_long_rounded,
                    title: 'Billing & Invoice Breakdown',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderCol),
                    ),
                    child: Column(
                      children: [
                        _buildInvoiceRow(
                          label: 'Base Valet Service Rate',
                          value:
                              '₹${booking.pricing.customerPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        ),
                        const SizedBox(height: 10),
                        _buildInvoiceRow(
                          label: 'Taxes & Regulatory Charges (GST)',
                          value:
                              '₹${booking.pricing.taxAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        // Total Row Highlight
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: textCol,
                              ),
                            ),
                            Text(
                              '₹${booking.pricing.totalAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Payment Status & Method Row
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    booking.isPaid
                                        ? Icons.check_circle_rounded
                                        : Icons.pending_rounded,
                                    size: 16,
                                    color: booking.isPaid
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    booking.isPaid ? 'PAID' : 'PAYMENT PENDING',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: booking.isPaid
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFD97706),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.credit_card_rounded,
                                    size: 15,
                                    color: subTextCol,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    booking.paymentMethod.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: subTextCol,
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

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // 4. Bottom Sticky Action Button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBE74D),
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.black87,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Done',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFFD97706)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: const Color(0xFFD97706)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFD97706)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
          final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
          final minStr = minute.toString().padLeft(2, '0');
          return '$hour12:$minStr $period';
        }
      }
    } catch (_) {}

    return trimmed;
  }
}
