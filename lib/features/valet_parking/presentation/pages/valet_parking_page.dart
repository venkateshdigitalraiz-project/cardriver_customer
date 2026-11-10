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
        listenWhen: (previous, current) =>
            (current.errorMessage != null &&
                previous.errorMessage != current.errorMessage) ||
            (current.successMessage != null &&
                previous.successMessage != current.successMessage),
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
                                              color: AppColors.secondaryDark,
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
                              onPressed: () =>
                                  _showValetFilterBottomSheet(context),
                              icon: const Icon(Icons.tune_rounded),
                              color: AppColors.info,
                              tooltip: 'Filter Valet Bookings',
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              if (showDot)
                Positioned(
                  top: 0,
                  right: -1,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
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

  void _showValetFilterBottomSheet(BuildContext context) {
    final bloc = context.read<ValetParkingBloc>();
    final currentStatusFilter = bloc.state.selectedStatusFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ValetFilterBottomSheet(
        initialStatus: currentStatusFilter,
        onApply: (selectedStatus) {
          Navigator.of(sheetContext).pop();
          // Map dropdown value to backend API query param:
          // 'pending' -> 'new_request'
          // 'confirmed' -> 'confirmed'
          // 'inprogress' -> 'in_progress'
          // 'complected' -> 'completed'
          String apiStatus = selectedStatus;
          if (selectedStatus.toLowerCase() == 'pending') {
            apiStatus = 'new_request';
          } else if (selectedStatus.toLowerCase() == 'inprogress') {
            apiStatus = 'in_progress';
          } else if (selectedStatus.toLowerCase() == 'complected') {
            apiStatus = 'completed';
          }

          bloc.add(LoadValetParkingData(refresh: true, status: apiStatus));
        },
      ),
    );
  }
}

/// Bottom Sheet containing Status Dropdown and Cancel / OK buttons
class _ValetFilterBottomSheet extends StatefulWidget {
  final String initialStatus;
  final ValueChanged<String> onApply;

  const _ValetFilterBottomSheet({
    required this.initialStatus,
    required this.onApply,
  });

  @override
  State<_ValetFilterBottomSheet> createState() =>
      _ValetFilterBottomSheetState();
}

class _ValetFilterBottomSheetState extends State<_ValetFilterBottomSheet> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    final init = widget.initialStatus.toLowerCase().trim();
    if (init == 'new_request' || init == 'pending') {
      _selectedStatus = 'pending';
    } else if (init == 'in_progress' || init == 'inprogress') {
      _selectedStatus = 'inprogress';
    } else if (init == 'completed' || init == 'complected') {
      _selectedStatus = 'complected';
    } else if (init == 'confirmed') {
      _selectedStatus = 'confirmed';
    } else {
      _selectedStatus = 'pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.white,
        colorScheme: Theme.of(context).colorScheme.copyWith(
          surface: Colors.white,
          onSurface: const Color(0xFF0F172A),
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xFF0F172A),
          displayColor: const Color(0xFF0F172A),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header Title & Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: Color(0xFF0F172A),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Filter Valet Bookings',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Color(0xFF64748B),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 16),

                const Text(
                  'Booking Status',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 8),

                // Dropdown with "pending,confirmed,inprogress,complected"
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                  icon: const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.flag_rounded,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F172A),
                        width: 1.5,
                      ),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  selectedItemBuilder: (BuildContext context) {
                    return const [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pending (new_request)',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Confirmed',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'In Progress',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ];
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text(
                        'Pending (new_request)',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'confirmed',
                      child: Text(
                        'Confirmed',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'inprogress',
                      child: Text(
                        'In Progress',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'complected',
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedStatus = val);
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Buttons: Cancel & OK
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF475569),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => widget.onApply(_selectedStatus),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'OK',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.check_rounded, size: 18),
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
        ),
      ),
    );
  }
}
