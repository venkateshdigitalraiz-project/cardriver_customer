import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/usecases/get_driver_bookings_usecase.dart';
import '../bloc/my_bookings/my_bookings_bloc.dart';
import '../bloc/my_bookings/my_bookings_event.dart';
import '../bloc/my_bookings/my_bookings_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

class MyBookingsPageDup extends StatelessWidget {
  final GetDriverBookingsUseCase? getDriverBookingsUseCase;

  const MyBookingsPageDup({super.key, this.getDriverBookingsUseCase});

  @override
  Widget build(BuildContext context) {
    GetDriverBookingsUseCase? useCase = getDriverBookingsUseCase;
    if (useCase == null) {
      try {
        useCase = context.read<GetDriverBookingsUseCase>();
      } catch (_) {
        final dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 25),
            receiveTimeout: const Duration(seconds: 25),
          ),
        );
        final ds = BookingRemoteDataSourceImpl(dio: dio);
        final repo = BookingRepositoryImpl(remoteDataSource: ds);
        useCase = GetDriverBookingsUseCase(repo);
      }
    }

    return BlocProvider(
      create: (context) =>
          MyBookingsBloc(getDriverBookingsUseCase: useCase!)..add(
            const LoadMyBookings(
              page: 1,
              limit: 5,
              status: '',
              startDate: '',
              endDate: '',
              search: '',
            ),
          ),
      child: const _MyBookingsPageView(),
    );
  }
}

class _MyBookingsPageView extends StatelessWidget {
  const _MyBookingsPageView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Refresh',
              onPressed: () {
                context.read<MyBookingsBloc>().add(
                  const RefreshMyBookings(
                    status: '',
                    startDate: '',
                    endDate: '',
                    search: '',
                  ),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: BlocBuilder<MyBookingsBloc, MyBookingsState>(
              builder: (context, state) {
                int? allCount;
                int? upcomingCount;
                int? completedCount;
                int? cancelledCount;

                if (state is MyBookingsLoaded) {
                  allCount = state.getCountForType('all');
                  upcomingCount = state.getCountForType('upcoming');
                  completedCount = state.getCountForType('completed');
                  cancelledCount = state.getCountForType('cancelled');
                }

                return TabBar(
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: [
                    Tab(text: allCount != null ? 'All ($allCount)' : 'All'),
                    Tab(
                      text: upcomingCount != null
                          ? 'Upcoming ($upcomingCount)'
                          : 'Upcoming',
                    ),
                    Tab(
                      text: completedCount != null
                          ? 'Completed ($completedCount)'
                          : 'Completed',
                    ),
                    Tab(
                      text: cancelledCount != null
                          ? 'Cancelled ($cancelledCount)'
                          : 'Cancelled',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _BookingsList(type: 'All'),
            _BookingsList(type: 'Upcoming'),
            _BookingsList(type: 'Completed'),
            _BookingsList(type: 'Cancelled'),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends StatefulWidget {
  final String type;

  const _BookingsList({required this.type});

  @override
  State<_BookingsList> createState() => _BookingsListState();
}

class _BookingsListState extends State<_BookingsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<MyBookingsBloc>().add(LoadMoreMyBookings());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 60,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load bookings',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<MyBookingsBloc>().add(
                        const LoadMyBookings(
                          page: 1,
                          limit: 5,
                          status: '',
                          startDate: '',
                          endDate: '',
                          search: '',
                        ),
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

        if (state is MyBookingsLoaded) {
          final filteredBookings = state.getBookingsForType(widget.type);

          if (filteredBookings.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<MyBookingsBloc>().add(
                  const RefreshMyBookings(
                    status: '',
                    startDate: '',
                    endDate: '',
                    search: '',
                  ),
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                children: [_buildEmptyState(context, widget.type)],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<MyBookingsBloc>().add(
                const RefreshMyBookings(
                  status: '',
                  startDate: '',
                  endDate: '',
                  search: '',
                ),
              );
            },
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount:
                  filteredBookings.length + (state.isLoadingMore ? 1 : 0) + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeaderSummary(
                    filteredBookings.length,
                    state.bookings.length,
                  );
                }

                final itemIndex = index - 1;
                if (itemIndex == filteredBookings.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                final booking = filteredBookings[itemIndex];
                return _buildBookingCard(context, booking);
              },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String type) {
    final isAll = type.toLowerCase() == 'all';
    final isUpcoming = type.toLowerCase() == 'upcoming';
    final isCompleted = type.toLowerCase() == 'completed';

    IconData emptyIcon;
    String title;
    String subtitle;

    if (isAll) {
      emptyIcon = Icons.calendar_month_outlined;
      title = 'No Bookings Found';
      subtitle =
          'You haven\'t made any driver bookings yet. Need a professional driver? Book in seconds!';
    } else if (isUpcoming) {
      emptyIcon = Icons.schedule_outlined;
      title = 'No Upcoming Trips';
      subtitle =
          'You don\'t have any rides scheduled right now. Plan your next trip with a trusted driver!';
    } else if (isCompleted) {
      emptyIcon = Icons.task_alt_rounded;
      title = 'No Completed Rides';
      subtitle =
          'Your finished trips and trip invoices will appear here once your journeys conclude.';
    } else {
      emptyIcon = Icons.cancel_outlined;
      title = 'No Cancelled Rides';
      subtitle = 'You have not cancelled any driver bookings.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(emptyIcon, size: 54, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.push(AppRoutes.bookingWizard, extra: 'Local');
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Book a Driver Partner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSummary(int filteredCount, int totalCount) {
    final isAll = widget.type.toLowerCase() == 'all';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAll
                      ? Icons.format_list_bulleted_rounded
                      : Icons.filter_list_rounded,
                  size: 16,
                  color: const Color(0xFF9E6E00),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isAll ? 'All Bookings History' : '${widget.type} Bookings',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAll ? '$totalCount Total' : '$filteredCount of $totalCount',
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF9E6E00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingEntity booking) {
    final statusColor = _getStatusColor(booking.status);
    final statusIcon = _getStatusIcon(booking.status);
    final isDriverAssigned =
        booking.driverName.isNotEmpty &&
        booking.driverName.toLowerCase() != 'unassigned' &&
        booking.driverMobile != 'N/A' &&
        booking.driverMobile.isNotEmpty;
    final isCancelled = booking.statusGroup.toLowerCase() == 'cancelled';
    final isCompleted = booking.statusGroup.toLowerCase() == 'completed';
    final isOutstation =
        booking.tripType.toLowerCase().contains('outstation') ||
        booking.serviceType.toLowerCase().contains('outstation');

    final displayTripType = _formatTripType(
      booking.tripType,
      booking.serviceType,
    );
    final shortBookingId = booking.id.length > 8
        ? booking.id.substring(booking.id.length - 8).toUpperCase()
        : booking.id.toUpperCase();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _openBookingDetails(context, booking),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header Strip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFEDF2F7), width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Booking ID Pill with copy icon
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: booking.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Booking ID #$shortBookingId copied'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.tag_rounded,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              shortBookingId,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.copy_rounded,
                              size: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Status Pill with Icon
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 13, color: statusColor),
                          const SizedBox(width: 5),
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

              // Main Content Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scheduled Date & Trip Category + OTP Box
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Date & Badges
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      DateFormat(
                                        'EEE, dd MMM yyyy • hh:mm a',
                                      ).format(booking.scheduleDate),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  _buildTagChip(
                                    icon: isOutstation
                                        ? Icons.explore_outlined
                                        : Icons.near_me_outlined,
                                    label: displayTripType,
                                    color: const Color(0xFF475569),
                                    bgColor: const Color(0xFFF1F5F9),
                                  ),
                                  _buildTagChip(
                                    icon: Icons.access_time_rounded,
                                    label:
                                        '${booking.duration} ${isOutstation ? 'Days' : 'Hrs'}',
                                    color: const Color(0xFF475569),
                                    bgColor: const Color(0xFFF1F5F9),
                                  ),
                                  if (booking.driverVehicle.isNotEmpty &&
                                      booking.driverVehicle != 'DriveU Classic')
                                    _buildTagChip(
                                      icon: Icons.directions_car_rounded,
                                      label: booking.driverVehicle,
                                      color: const Color(0xFF475569),
                                      bgColor: const Color(0xFFF1F5F9),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Right: START OTP Badge (if upcoming/pending and has OTP)
                        if (booking.startOtp.isNotEmpty &&
                            !isCancelled &&
                            !isCompleted) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFCD34D),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_outline_rounded,
                                      size: 11,
                                      color: Color(0xFFB45309),
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'START OTP',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFB45309),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  booking.startOtp,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF78350F),
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Route Timeline (Pickup -> Drop)
                    _buildRouteTimeline(booking, isOutstation),

                    const SizedBox(height: 14),

                    // Fare & Payment Info Row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                booking.paymentStatus.toLowerCase() == 'paid'
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.account_balance_wallet_outlined,
                                size: 16,
                                color:
                                    booking.paymentStatus.toLowerCase() ==
                                        'paid'
                                    ? Colors.green.shade700
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.paymentStatus.toLowerCase() ==
                                            'paid'
                                        ? 'Paid • ${booking.paymentMethod.toUpperCase()}'
                                        : 'Payment ${booking.paymentStatus.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          booking.paymentStatus.toLowerCase() ==
                                              'paid'
                                          ? Colors.green.shade700
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const Text(
                                    'Total Estimated Fare',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '₹${booking.fare.round()}',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),

                    // Driver Section (Assigned vs Assigning Soon vs Completed/Cancelled)
                    _buildDriverSection(
                      context,
                      booking,
                      isDriverAssigned,
                      isCancelled,
                      isCompleted,
                    ),

                    const SizedBox(height: 12),

                    // Action Buttons Row
                    _buildCardActionButtons(
                      context,
                      booking,
                      isDriverAssigned,
                      isCancelled,
                      isCompleted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteTimeline(BookingEntity booking, bool isOutstation) {
    final hasDrop =
        booking.dropAddress != null && booking.dropAddress!.trim().isNotEmpty;
    final dropTime = isOutstation
        ? booking.scheduleDate.add(Duration(days: booking.duration))
        : booking.scheduleDate.add(Duration(hours: booking.duration));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pickup Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.green, width: 2),
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'PICKUP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.green,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('hh:mm a').format(booking.scheduleDate),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.pickupAddress.isNotEmpty
                          ? booking.pickupAddress
                          : 'Pickup location not specified',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Timeline connector
          Padding(
            padding: const EdgeInsets.only(left: 7.0),
            child: Container(
              height: 18,
              width: 2,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),

          // Drop Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.red.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.red.shade700, width: 2),
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'DROP-OFF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.red.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Est. ${DateFormat('hh:mm a').format(dropTime)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasDrop
                          ? booking.dropAddress!
                          : (booking.tripType.toLowerCase().contains('round')
                                ? 'Return to pickup location (${booking.duration} ${isOutstation ? 'Days' : 'Hours'} rental)'
                                : 'As directed by customer'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasDrop
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF64748B),
                        fontStyle: hasDrop
                            ? FontStyle.normal
                            : FontStyle.italic,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildDriverSection(
    BuildContext context,
    BookingEntity booking,
    bool isDriverAssigned,
    bool isCancelled,
    bool isCompleted,
  ) {
    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'This trip was cancelled.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 16,
              color: Color(0xFF16A34A),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isDriverAssigned
                    ? 'Completed by ${booking.driverName}'
                    : 'Ride completed successfully',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isDriverAssigned) {
      return Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: const Icon(Icons.person, size: 22, color: Color(0xFF9E6E00)),
          ),
          const SizedBox(width: 10),
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
                          fontSize: 13,
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
                      size: 14,
                      color: Color(0xFF3B82F6),
                    ),
                  ],
                ),
                Text(
                  'Driver Partner • ${booking.driverMobile}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.white, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
            ),
            tooltip: 'Call Driver',
            onPressed: () => _callNumber(context, booking.driverMobile),
          ),
        ],
      );
    }

    // Driver not assigned yet (Upcoming / Pending)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.schedule_send_rounded, size: 16, color: Color(0xFFD97706)),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver Assignment in Progress',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                Text(
                  'Driver contact & vehicle details will appear before pickup.',
                  style: TextStyle(fontSize: 10, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardActionButtons(
    BuildContext context,
    BookingEntity booking,
    bool isDriverAssigned,
    bool isCancelled,
    bool isCompleted,
  ) {
    return Row(
      children: [
        // "View Details" button on all cards
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openBookingDetails(context, booking),
            icon: const Icon(Icons.info_outline_rounded, size: 15),
            label: const Text('View Details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E293B),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Context-dependent right button
        if (isCancelled || isCompleted)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.push(
                  AppRoutes.bookingWizard,
                  extra: booking.tripType.toLowerCase().contains('outstation')
                      ? 'Outstation'
                      : 'Local',
                );
              },
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('Book Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
        else if (isDriverAssigned)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _callNumber(context, booking.driverMobile),
              icon: const Icon(Icons.phone_in_talk_rounded, size: 15),
              label: const Text('Call Driver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showSupportDialog(context);
              },
              icon: const Icon(Icons.headset_mic_outlined, size: 15),
              label: const Text('Need Help?'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF475569),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTagChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _openBookingDetails(BuildContext context, BookingEntity booking) {
    final bookingIdToUse = booking.dbId.isNotEmpty ? booking.dbId : booking.id;
    context.push('${AppRoutes.bookingDetails}/$bookingIdToUse');
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'upcoming':
      case 'confirmed':
      case 'scheduled':
      case 'assigned':
      case 'accepted':
        return const Color(0xFF2563EB); // Modern Blue
      case 'in_progress':
      case 'in progress':
        return const Color(0xFF0D9488); // Teal
      case 'pending':
        return const Color(0xFFD97706); // Amber
      case 'completed':
      case 'finished':
        return const Color(0xFF16A34A); // Emerald Green
      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return const Color(0xFFDC2626); // Rose Red
      default:
        return const Color(0xFF64748B); // Slate
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

  String _formatTripType(String tripType, String serviceType) {
    final raw = tripType.isNotEmpty ? tripType : serviceType;
    if (raw.isEmpty) return 'Local Ride';

    final cleaned = raw.replaceAll('_', ' ').trim();
    return cleaned
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
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
            Text('Customer Support'),
          ],
        ),
        content: const Text(
          'Need assistance with your booking? Our 24/7 dedicated customer care team is available to help.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
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
