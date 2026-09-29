import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/booking_entity.dart';
import '../bloc/my_bookings/my_bookings_bloc.dart';
import '../bloc/my_bookings/my_bookings_event.dart';
import '../bloc/my_bookings/my_bookings_state.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyBookingsBloc()..add(LoadMyBookings()),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E1E24),
            elevation: 0,
            title: const Text(
              'My Bookings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            bottom: const TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _BookingsList(type: 'Upcoming'),
              _BookingsList(type: 'Completed'),
              _BookingsList(type: 'Cancelled'),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final String type;
  
  const _BookingsList({required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBookingsBloc, MyBookingsState>(
      builder: (context, state) {
        if (state is MyBookingsLoading || state is MyBookingsInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is MyBookingsError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is MyBookingsLoaded) {
          final filteredBookings = state.bookings
              .where((b) => b.status == type)
              .toList();

          if (filteredBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${type.toLowerCase()} bookings',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You don\'t have any ${type.toLowerCase()} rides yet.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredBookings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final booking = filteredBookings[index];
              return _buildBookingCard(context, booking);
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingEntity booking) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormat.format(booking.scheduleDate),
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status,
                  style: AppTypography.labelSmall.copyWith(
                    color: _getStatusColor(booking.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Trip Info & Fare
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  booking.tripType == 'Outstation' ? Icons.alt_route : Icons.directions_car,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${booking.driverVehicle} • ${booking.tripType}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${booking.id} • '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                          ),
                        ),
                        TextSpan(text: '${booking.duration} ${booking.tripType == 'Outstation' ? 'Days' : 'Hours'}'),
                      ],
                    ),
                    style: AppTypography.bodySmall.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '₹${booking.fare.round()}',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Locations Timeline
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Icon(Icons.circle, color: Colors.green, size: 10),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.pickupAddress,
                            style: AppTypography.bodyMedium.copyWith(color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pickup: ${DateFormat('MMM dd, hh:mm a').format(booking.scheduleDate)}',
                            style: AppTypography.labelSmall.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (booking.dropAddress != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, top: 4.0, bottom: 4.0),
                    child: Container(
                      height: 20,
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Icon(Icons.square, color: Colors.red, size: 10),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.dropAddress!,
                              style: AppTypography.bodyMedium.copyWith(color: Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Drop: ${DateFormat('MMM dd, hh:mm a').format(
                                booking.tripType == 'Outstation' 
                                  ? booking.scheduleDate.add(Duration(days: booking.duration))
                                  : booking.scheduleDate.add(Duration(hours: booking.duration))
                              )}',
                              style: AppTypography.labelSmall.copyWith(color: Colors.red.shade700, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          // Driver Footer & Actions
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, size: 22, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver: ${booking.driverName}',
                      style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      'Contact No: ${booking.driverMobile}',
                      style: AppTypography.labelSmall.copyWith(color: Colors.grey.shade600),
                    ),
                    Text(
                      booking.driverVehicle,
                      style: AppTypography.labelSmall.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              if (booking.driverMobile != 'N/A')
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.phone, color: Colors.green.shade700, size: 20),
                    onPressed: () {},
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
