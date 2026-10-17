import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/valet_parking_remote_datasource.dart';
import '../../data/repositories/valet_parking_repository_impl.dart';
import '../../domain/entities/valet_booking_entity.dart';
import '../../domain/entities/valet_parking_location.dart';
import '../../domain/usecases/get_active_valet_tickets_usecase.dart';
import '../../domain/usecases/get_valet_bookings_usecase.dart';
import '../../domain/usecases/get_valet_locations_usecase.dart';
import '../../domain/usecases/request_valet_booking_usecase.dart';
import '../../domain/usecases/request_vehicle_retrieval_usecase.dart';
import '../bloc/valet_parking_bloc.dart';
import '../bloc/valet_parking_event.dart';
import '../bloc/valet_parking_state.dart';
import '../widgets/valet_active_ticket_card.dart';
import '../widgets/valet_booking_card.dart';
import '../widgets/valet_booking_detail_sheet.dart';
import '../widgets/valet_booking_sheet.dart';
import '../widgets/valet_location_card.dart';

/// Alias for user's naming convention
typedef ValietParkPage = ValetParkingPage;

class ValetParkingPage extends StatelessWidget {
  final GetValetBookingsUseCase? getValetBookingsUseCase;
  final GetValetLocationsUseCase? getValetLocationsUseCase;
  final GetActiveValetTicketsUseCase? getActiveValetTicketsUseCase;
  final RequestValetBookingUseCase? requestValetBookingUseCase;
  final RequestVehicleRetrievalUseCase? requestVehicleRetrievalUseCase;

  const ValetParkingPage({
    super.key,
    this.getValetBookingsUseCase,
    this.getValetLocationsUseCase,
    this.getActiveValetTicketsUseCase,
    this.requestValetBookingUseCase,
    this.requestVehicleRetrievalUseCase,
  });

  @override
  Widget build(BuildContext context) {
    GetValetBookingsUseCase? bookingsUC = getValetBookingsUseCase;
    GetValetLocationsUseCase? locationsUC = getValetLocationsUseCase;
    GetActiveValetTicketsUseCase? ticketsUC = getActiveValetTicketsUseCase;
    RequestValetBookingUseCase? bookingUC = requestValetBookingUseCase;
    RequestVehicleRetrievalUseCase? retrievalUC =
        requestVehicleRetrievalUseCase;

    if (bookingsUC == null ||
        locationsUC == null ||
        ticketsUC == null ||
        bookingUC == null ||
        retrievalUC == null) {
      try {
        bookingsUC ??= context.read<GetValetBookingsUseCase>();
        locationsUC ??= context.read<GetValetLocationsUseCase>();
        ticketsUC ??= context.read<GetActiveValetTicketsUseCase>();
        bookingUC ??= context.read<RequestValetBookingUseCase>();
        retrievalUC ??= context.read<RequestVehicleRetrievalUseCase>();
      } catch (_) {
        final ds = ValetParkingRemoteDataSourceImpl();
        final repo = ValetParkingRepositoryImpl(remoteDataSource: ds);
        bookingsUC ??= GetValetBookingsUseCase(repo);
        locationsUC ??= GetValetLocationsUseCase(repo);
        ticketsUC ??= GetActiveValetTicketsUseCase(repo);
        bookingUC ??= RequestValetBookingUseCase(repo);
        retrievalUC ??= RequestVehicleRetrievalUseCase(repo);
      }
    }

    final resolvedBookingsUC = bookingsUC;
    final resolvedLocationsUC = locationsUC;
    final resolvedTicketsUC = ticketsUC;
    final resolvedBookingUC = bookingUC;
    final resolvedRetrievalUC = retrievalUC;

    return BlocProvider(
      create: (context) => ValetParkingBloc(
        getValetBookingsUseCase: resolvedBookingsUC,
        getValetLocationsUseCase: resolvedLocationsUC,
        getActiveValetTicketsUseCase: resolvedTicketsUC,
        requestValetBookingUseCase: resolvedBookingUC,
        requestVehicleRetrievalUseCase: resolvedRetrievalUC,
      )..add(const LoadValetParkingData()),
      child: const _ValetParkingPageView(),
    );
  }
}

class _ValetParkingPageView extends StatefulWidget {
  const _ValetParkingPageView();

  @override
  State<_ValetParkingPageView> createState() => _ValetParkingPageViewState();
}

class _ValetParkingPageViewState extends State<_ValetParkingPageView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    const cardBg = Colors.white;
    const textCol = Color(0xFF0F172A);
    const subTextCol = Color(0xFF64748B);

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        colorScheme: Theme.of(context).colorScheme.copyWith(
          brightness: Brightness.light,
          surface: Colors.white,
          onSurface: textCol,
        ),
      ),
      child: BlocConsumer<ValetParkingBloc, ValetParkingState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFFF3366),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.successMessage!)),
                  ],
                ),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: bg,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pinned Header Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header: Title, VIP Badge, and Refresh Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Valet Parking',
                                      style: AppTypography.displayMedium
                                          .copyWith(
                                            color: textCol,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 26,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'VIP',
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Event & Private Valet Service Bookings',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: subTextCol,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<ValetParkingBloc>().add(
                                  const LoadValetParkingData(refresh: true),
                                );
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              color: AppColors.primary,
                              tooltip: 'Refresh Valet Bookings',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Summary Statistics Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Valet',
                                value: '${state.bookings.length}',
                                icon: Icons.confirmation_number_outlined,
                                accentColor: const Color(0xFF00E5FF),
                                cardBg: cardBg,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                title: 'In Progress',
                                value: '${state.inProgressCount}',
                                icon: Icons.hourglass_top_rounded,
                                accentColor: AppColors.primary,
                                cardBg: cardBg,
                                showDot: state.inProgressCount > 0,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Completed',
                                value: '${state.completedCount}',
                                icon: Icons.check_circle_outline_rounded,
                                accentColor: const Color(0xFF10B981),
                                cardBg: cardBg,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Search Bar
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: cardBg,
                        //     borderRadius: BorderRadius.circular(16),
                        //     border: Border.all(
                        //       color: const Color(0xFFE2E8F0),
                        //     ),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.black.withValues(
                        //           alpha: 0.04,
                        //         ),
                        //         blurRadius: 10,
                        //         offset: const Offset(0, 3),
                        //       ),
                        //     ],
                        //   ),
                        //   child: TextField(
                        //     controller: _searchController,
                        //     style: const TextStyle(color: textCol),
                        //     onChanged: (query) {
                        //       context
                        //           .read<ValetParkingBloc>()
                        //           .add(SearchValetBookings(query));
                        //     },
                        //     decoration: InputDecoration(
                        //       hintText:
                        //           'Search by event, booking ID, or venue...',
                        //       hintStyle: const TextStyle(
                        //         color: subTextCol,
                        //         fontSize: 13,
                        //       ),
                        //       prefixIcon: const Icon(
                        //         Icons.search_rounded,
                        //         color: AppColors.primary,
                        //       ),
                        //       suffixIcon: _searchController.text.isNotEmpty
                        //           ? IconButton(
                        //               icon: const Icon(Icons.clear_rounded,
                        //                   size: 18),
                        //               onPressed: () {
                        //                 _searchController.clear();
                        //                 context
                        //                     .read<ValetParkingBloc>()
                        //                     .add(const SearchValetBookings(''));
                        //               },
                        //             )
                        //           : null,
                        //       border: InputBorder.none,
                        //       contentPadding: const EdgeInsets.symmetric(
                        //         horizontal: 16,
                        //         vertical: 14,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  // Tab Content Body
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBookingsTab(context, state),
                        _buildStationsTab(context, state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingsTab(BuildContext context, ValetParkingState state) {
    if (state.status == ValetParkingStatus.loading && state.bookings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<ValetParkingBloc>().add(
          const LoadValetParkingData(refresh: true),
        );
      },
      child: Column(
        children: [
          // Filter Chips (All, In Progress, Completed, Pending)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    context,
                    label: 'All (${state.bookings.length})',
                    filterKey: 'all',
                    isSelected: state.selectedStatusFilter == 'all',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'In Progress (${state.inProgressCount})',
                    filterKey: 'in_progress',
                    isSelected: state.selectedStatusFilter == 'in_progress',
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Completed (${state.completedCount})',
                    filterKey: 'completed',
                    isSelected: state.selectedStatusFilter == 'completed',
                    activeColor: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),
          ),

          // Bookings List
          Expanded(
            child: state.filteredBookings.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 80,
                          horizontal: 24,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.event_busy_rounded,
                                size: 48,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No Valet Bookings Found',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'No orders match the selected filter or search keyword.',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                    itemCount: state.filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = state.filteredBookings[index];
                      return ValetBookingCard(
                        booking: booking,
                        onTap: () => _openBookingDetail(context, booking),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String filterKey,
    required bool isSelected,
    Color activeColor = AppColors.primary,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0B0E14) : const Color(0xFF475569),
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: activeColor,
      backgroundColor: const Color(0xFFEFF3F8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? activeColor : const Color(0xFFE2E8F0),
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          context.read<ValetParkingBloc>().add(
            FilterValetBookingsByStatus(filterKey),
          );
        }
      },
    );
  }

  Widget _buildStationsTab(BuildContext context, ValetParkingState state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<ValetParkingBloc>().add(const LoadValetParkingData());
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // Active Passes Banner if any
          if (state.activeTickets.isNotEmpty) ...[
            Text(
              'ACTIVE DIGITAL VALET PASS',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            ...state.activeTickets.map(
              (ticket) => ValetActiveTicketCard(
                ticket: ticket,
                onRetrievalRequested: () {
                  context.read<ValetParkingBloc>().add(
                    RequestRetrievalSubmitted(ticket.ticketId),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          Text(
            'AVAILABLE VALET STATIONS',
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),

          ...state.filteredLocations.map(
            (loc) => ValetLocationCard(
              location: loc,
              onBookTap: () => _openBookingSheet(context, loc),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required Color cardBg,
    bool showDot = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Icon(icon, size: 16, color: accentColor),
              if (showDot)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _openBookingDetail(BuildContext context, ValetBookingEntity booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ValetBookingDetailSheet(booking: booking),
    );
  }

  void _openBookingSheet(BuildContext context, ValetParkingLocation location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ValetBookingSheet(
          location: location,
          onConfirm:
              ({
                required String locationId,
                required String vehicleNumber,
                required String vehicleModel,
                required int estimatedHours,
                String? specialInstructions,
              }) {
                context.read<ValetParkingBloc>().add(
                  BookValetSlotSubmitted(
                    locationId: locationId,
                    vehicleNumber: vehicleNumber,
                    vehicleModel: vehicleModel,
                    estimatedHours: estimatedHours,
                    specialInstructions: specialInstructions,
                  ),
                );
              },
        );
      },
    );
  }
}
