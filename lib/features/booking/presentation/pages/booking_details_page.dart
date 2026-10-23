import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/booking_detail_entity.dart';
import '../../domain/usecases/get_booking_detail_usecase.dart';
import '../bloc/booking_detail/booking_detail_bloc.dart';
import '../bloc/booking_detail/booking_detail_event.dart';
import '../bloc/booking_detail/booking_detail_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

class BookingDetailsPage extends StatelessWidget {
  final String bookingId;
  final GetBookingDetailUseCase? getBookingDetailUseCase;

  const BookingDetailsPage({
    super.key,
    required this.bookingId,
    this.getBookingDetailUseCase,
  });

  @override
  Widget build(BuildContext context) {
    GetBookingDetailUseCase? useCase = getBookingDetailUseCase;
    if (useCase == null) {
      try {
        useCase = context.read<GetBookingDetailUseCase>();
      } catch (_) {
        final dio = Dio();
        final ds = BookingRemoteDataSourceImpl(dio: dio);
        final repo = BookingRepositoryImpl(remoteDataSource: ds);
        useCase = GetBookingDetailUseCase(repo);
      }
    }

    return BlocProvider(
      create: (context) =>
          BookingDetailBloc(getBookingDetailUseCase: useCase!)
            ..add(FetchBookingDetail(bookingId)),
      child: _BookingDetailsView(bookingId: bookingId),
    );
  }
}

class _BookingDetailsView extends StatelessWidget {
  final String bookingId;

  const _BookingDetailsView({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E24),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<BookingDetailBloc>().add(
                RefreshBookingDetail(bookingId),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<BookingDetailBloc, BookingDetailState>(
        builder: (context, state) {
          if (state is BookingDetailLoading || state is BookingDetailInitial) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading booking details...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is BookingDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to Load Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<BookingDetailBloc>().add(
                          FetchBookingDetail(bookingId),
                        );
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is BookingDetailLoaded) {
            final booking = state.booking;
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<BookingDetailBloc>().add(
                  RefreshBookingDetail(bookingId),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Overview Card
                    _buildOverviewCard(context, booking),
                    const SizedBox(height: 14),

                    // OTP Verification Ticket (if present)
                    if (booking.startOtp.isNotEmpty &&
                        booking.statusGroup != 'Cancelled') ...[
                      _buildOtpTicket(context, booking.startOtp),
                      const SizedBox(height: 14),
                    ],

                    // Route & Location Timeline
                    _buildRouteSection(context, booking),
                    const SizedBox(height: 14),

                    // Driver Section
                    _buildDriverSection(context, booking),
                    const SizedBox(height: 14),

                    // Vehicle & Service Specifications
                    _buildVehicleSection(context, booking),
                    const SizedBox(height: 14),

                    // Itemized Fare Breakdown
                    _buildFareBreakdownSection(context, booking),
                    const SizedBox(height: 14),

                    // Timestamps & Meta Info
                    _buildMetaInfoSection(context, booking),
                    const SizedBox(height: 20),

                    // Contextual Action Buttons
                    _buildActionButtons(context, booking),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, BookingDetailEntity booking) {
    final statusColor = _getStatusColor(booking.bookingStatus);
    final statusIcon = _getStatusIcon(booking.bookingStatus);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFEDF2F7))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '#${booking.displayBookingId}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: booking.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Booking ID ${booking.displayBookingId} copied',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        booking.displayStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Overview Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        DateFormat(
                          'EEEE, dd MMMM yyyy • hh:mm a',
                        ).format(booking.scheduledStartTime),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildPill(
                      icon: Icons.alt_route_rounded,
                      label: booking.displayTripType,
                      color: const Color(0xFF475569),
                      bgColor: const Color(0xFFF1F5F9),
                    ),
                    _buildPill(
                      icon: Icons.access_time_rounded,
                      label: '${booking.durationHours} Hours Duration',
                      color: const Color(0xFF475569),
                      bgColor: const Color(0xFFF1F5F9),
                    ),
                    _buildPill(
                      icon: Icons.directions_car_rounded,
                      label: booking.displayVehicle,
                      color: const Color(0xFF475569),
                      bgColor: const Color(0xFFF1F5F9),
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

  Widget _buildOtpTicket(BuildContext context, String otp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: const Icon(
                    Icons.lock_open_rounded,
                    color: Color(0xFFB45309),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RIDE START OTP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Share with driver at pickup',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB45309),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              otp,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF78350F),
                letterSpacing: 4.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSection(BuildContext context, BookingDetailEntity booking) {
    final dropTime = booking.scheduledStartTime.add(
      Duration(hours: booking.durationHours),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.route_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Trip Route & Schedule',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pickup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.green, width: 2.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'PICKUP POINT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.green,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat(
                            'hh:mm a',
                          ).format(booking.scheduledStartTime),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.pickupLocation.address,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),
                    if (booking.pickupLocation.hasCoordinates) ...[
                      const SizedBox(height: 4),
                      Text(
                        '📍 Coordinates: ${booking.pickupLocation.latitude!.toStringAsFixed(4)}, ${booking.pickupLocation.longitude!.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Connector line
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4, bottom: 4),
            child: Container(
              height: 28,
              width: 2,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),

          // Drop
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.red.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.red.shade700, width: 2.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'DROP-OFF POINT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.red.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Est. ${DateFormat('hh:mm a').format(dropTime)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.dropLocation.address.isNotEmpty
                          ? booking.dropLocation.address
                          : (booking.tripType.toLowerCase().contains('round')
                                ? 'Return to pickup location (${booking.durationHours} Hours Rental)'
                                : 'As directed by customer'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),
                    if (booking.dropLocation.hasCoordinates) ...[
                      const SizedBox(height: 4),
                      Text(
                        '📍 Coordinates: ${booking.dropLocation.latitude!.toStringAsFixed(4)}, ${booking.dropLocation.longitude!.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverSection(
    BuildContext context,
    BookingDetailEntity booking,
  ) {
    final isDriverAssigned = booking.isDriverAssigned;
    final isCancelled = booking.statusGroup == 'Cancelled';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.badge_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Driver Partner Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (isCancelled) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cancel_outlined,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      booking.cancellationReason.isNotEmpty
                          ? 'Cancelled: ${booking.cancellationReason}'
                          : 'This booking was cancelled.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isDriverAssigned) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: Color(0xFF9E6E00),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              booking.driverName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Phone: ${booking.driverMobile}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      if (booking.driverRating != null)
                        Text(
                          '★ ${booking.driverRating!.toStringAsFixed(1)} Rating',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD97706),
                          ),
                        ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _callNumber(context, booking.driverMobile),
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.schedule_send_rounded,
                    size: 20,
                    color: Color(0xFFD97706),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Driver Assignment in Progress',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'A top-rated verified driver partner will be assigned shortly before your pickup time.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB45309),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleSection(
    BuildContext context,
    BookingDetailEntity booking,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.directions_car_filled_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Vehicle Specifications',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildItemRow('Vehicle Type', booking.vehicleType.toUpperCase()),
          _buildItemRow('Transmission', booking.transmission.toUpperCase()),
          _buildItemRow(
            'Ownership',
            booking.vehicleOwnership.replaceAll('_', ' ').toUpperCase(),
          ),
          if (booking.vehicleNumber.isNotEmpty)
            _buildItemRow('Vehicle Number', booking.vehicleNumber),
          //   _buildItemRow('Passengers', '${booking.numberOfPassengers} Passenger(s)'),
        ],
      ),
    );
  }

  Widget _buildFareBreakdownSection(
    BuildContext context,
    BookingDetailEntity booking,
  ) {
    final isPaid = booking.paymentStatus.toLowerCase() == 'paid';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Fare Breakdown',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isPaid
                        ? Colors.green.shade300
                        : Colors.amber.shade300,
                  ),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'PAYMENT PENDING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isPaid
                        ? Colors.green.shade700
                        : Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildFareRow('Base Rental Amount', '₹${booking.baseAmount.round()}'),
          // if (booking.driverFee > 0)
          //   _buildFareRow('Driver Fee', '₹${booking.driverFee.round()}'),
          if (booking.extraKmAmount > 0)
            _buildFareRow(
              'Extra Km Charges',
              '₹${booking.extraKmAmount.round()}',
            ),
          // if (booking.driverAllowance > 0)
          //   _buildFareRow('Driver Allowance', '₹${booking.driverAllowance.round()}'),
          // if (booking.platformFee > 0)
          //   _buildFareRow('Platform Convenience Fee', '₹${booking.platformFee.round()}'),
          _buildFareRow('Taxes & GST (5%)', '₹${booking.taxAmount.round()}'),
          // if (booking.discountAmount > 0)
          //   _buildFareRow('Special Discount', '-₹${booking.discountAmount.round()}', isDiscount: true),
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '₹${booking.totalAmount.round()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.payment_rounded,
                size: 14,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                'Payment Mode: ${booking.paymentMethod.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfoSection(
    BuildContext context,
    BookingDetailEntity booking,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Information & Notes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 10),
          _buildItemRow(
            'Booked At',
            DateFormat('MMM dd, yyyy • hh:mm a').format(booking.createdAt),
          ),
          _buildItemRow('Service Mode', booking.bookingMode.toUpperCase()),
          if (booking.userNotes.isNotEmpty)
            _buildItemRow('Special Instructions', booking.userNotes),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    BookingDetailEntity booking,
  ) {
    final isDriverAssigned = booking.isDriverAssigned;
    final isFinished =
        booking.statusGroup == 'Completed' ||
        booking.statusGroup == 'Cancelled';

    return Row(
      children: [
        if (isDriverAssigned)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _callNumber(context, booking.driverMobile),
              icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
              label: const Text('Call Driver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else if (isFinished)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.push(
                  AppRoutes.bookingWizard,
                  extra: booking.serviceType.toLowerCase() == 'outstation'
                      ? 'Outstation'
                      : 'Local',
                );
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Book Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showSupportDialog(context),
              icon: const Icon(Icons.headset_mic_rounded, size: 18),
              label: const Text('Need Help?'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFareRow(String title, String amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDiscount
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'upcoming':
      case 'confirmed':
      case 'scheduled':
      case 'assigned':
      case 'accepted':
        return const Color(0xFF2563EB); // Blue
      case 'in_progress':
      case 'in progress':
        return const Color(0xFF0D9488); // Teal
      case 'pending':
        return const Color(0xFFD97706); // Amber
      case 'completed':
      case 'finished':
        return const Color(0xFF16A34A); // Green
      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return const Color(0xFFDC2626); // Red
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase().trim()) {
      case 'upcoming':
      case 'confirmed':
      case 'scheduled':
      case 'assigned':
      case 'accepted':
        return Icons.schedule_rounded;
      case 'in_progress':
      case 'in progress':
        return Icons.directions_car_filled_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'completed':
      case 'finished':
        return Icons.check_circle_rounded;
      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  void _callNumber(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open dialer for $cleanPhone')),
        );
      }
    }
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.headset_mic_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Trip Support'),
          ],
        ),
        content: const Text(
          'Need help or have questions regarding this booking? Our 24/7 dedicated support team is here to help you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _callNumber(context, '1800-123-4567');
            },
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Call Helpline'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
