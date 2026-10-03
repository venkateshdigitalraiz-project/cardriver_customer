import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/flow/booking_flow_bloc.dart';
import 'active_trip_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking_request_entity.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final BookingRequestEntity request;

  const BookingConfirmedScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D253F), // Dark blue from mockup
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Booking Confirmed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your driver will be assigned shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking ID',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '#CDR123456',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      title: 'Date & Time',
                      value: request.scheduleDate != null
                          ? '${DateFormat('dd MMM yyyy').format(request.scheduleDate!)}, ${request.scheduleHour}:${request.scheduleMinute.toString().padLeft(2, '0')} ${request.scheduleHour != null && request.scheduleHour! >= 12 ? 'PM' : 'AM'}'
                          : 'Not selected',
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.schedule,
                      title: 'Duration',
                      value: '${request.durationHours} ${request.isOutstation ? (request.durationHours > 1 ? 'Days' : 'Day') : (request.durationHours > 1 ? 'hours' : 'hour')}',
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.directions_car,
                      title: 'Car',
                      value: request.carType,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.location_on,
                      title: 'Pickup',
                      value: request.pickupAddress ?? 'Not provided',
                      valueColor: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.location_on,
                      title: 'Drop',
                      value: request.dropAddress ?? 'Not provided',
                      valueColor: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.currency_rupee,
                      title: 'Price',
                      value: request.estimatedFare != null ? '₹${request.estimatedFare}' : 'Not provided',
                      valueColor: Colors.green.shade800,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Spacer(),

              // Buttons
              ElevatedButton(
                onPressed: () {
                  final bookingBloc = context.read<BookingFlowBloc>();
                  // Navigate to Active Trip tracking
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: bookingBloc,
                        child: const ActiveTripScreen(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Track Driver',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D253F),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
