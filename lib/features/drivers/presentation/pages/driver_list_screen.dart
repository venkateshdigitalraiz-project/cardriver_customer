import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/driver_remote_datasource.dart';
import '../../data/repositories/driver_repository_impl.dart';
import '../../domain/entities/driver_filter_options.dart';
import '../../domain/entities/driver_search_type.dart';
import '../../domain/usecases/get_drivers_usecase.dart';
import '../bloc/driver_list_bloc.dart';
import '../bloc/driver_list_event.dart';
import '../bloc/driver_list_state.dart';
import '../widgets/driver_card.dart';
import '../widgets/driver_filter_bottom_sheet.dart';

class DriverListScreen extends StatelessWidget {
  final DriverSearchType searchType;

  const DriverListScreen({super.key, required this.searchType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DriverListBloc(
        getDriversUseCase: GetDriversUseCase(
          DriverRepositoryImpl(remoteDataSource: DriverRemoteDataSourceImpl()),
        ),
      )..add(FetchDriversEvent(searchType: searchType)),
      child: _DriverListScreenView(searchType: searchType),
    );
  }
}

class _DriverListScreenView extends StatefulWidget {
  final DriverSearchType searchType;

  const _DriverListScreenView({required this.searchType});

  @override
  State<_DriverListScreenView> createState() => _DriverListScreenViewState();
}

class _DriverListScreenViewState extends State<_DriverListScreenView> {
  final TextEditingController _driverSearchController = TextEditingController();
  final TextEditingController _locationSearchController =
      TextEditingController();

  @override
  void dispose() {
    _driverSearchController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
    context.read<DriverListBloc>().add(
      SearchDriversEvent(
        query: _driverSearchController.text,
        locationQuery: _locationSearchController.text,
      ),
    );
  }

  String get _appBarTitle {
    return widget.searchType == DriverSearchType.local
        ? 'Local Drivers'
        : 'Outstation Drivers';
  }

  String get _topHeaderSubtitle {
    return widget.searchType == DriverSearchType.local
        ? 'Drivers available within 100 KM'
        : 'Drivers available beyond 100 KM';
  }

  String get _emptyStateMessage {
    return widget.searchType == DriverSearchType.local
        ? 'No local drivers available within 100 KM'
        : 'No outstation drivers available beyond 100 KM';
  }

  Widget _buildSearchAndFilterBar(BuildContext context, DriverListState state) {
    final DriverFilterOptions currentFilter = (state is DriverListLoaded)
        ? state.filterOptions
        : ((state is DriverListEmpty)
              ? state.filterOptions
              : const DriverFilterOptions());

    final bool hasActiveFilter = currentFilter.hasActiveFilter;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              // 1. Search Driver / Car TextField
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _driverSearchController,
                    onChanged: (_) => _onSearchChanged(),
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search driver name, car...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: Colors.black38,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_search_rounded,
                        color: Color(0xFF266475),
                        size: 22,
                      ),
                      suffixIcon: _driverSearchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.black45,
                                size: 18,
                              ),
                              onPressed: () {
                                _driverSearchController.clear();
                                _onSearchChanged();
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF266475),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Filter Button (Opens Bottom Sheet)
              InkWell(
                onTap: () async {
                  final result =
                      await showModalBottomSheet<DriverFilterOptions>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (modalContext) => DriverFilterBottomSheet(
                          currentFilter: currentFilter,
                          searchType: widget.searchType,
                        ),
                      );

                  if (result != null && context.mounted) {
                    context.read<DriverListBloc>().add(
                      ApplyFilterEvent(result),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: hasActiveFilter
                        ? const Color(0xFF266475)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasActiveFilter
                          ? const Color(0xFF266475)
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: hasActiveFilter
                            ? Colors.white
                            : const Color(0xFF266475),
                        size: 22,
                      ),
                      if (hasActiveFilter)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBE74D),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. Search Location / City TextField
          // Container(
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(16),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withValues(alpha: 0.04),
          //         blurRadius: 10,
          //         offset: const Offset(0, 3),
          //       ),
          //     ],
          //   ),
          //   child: TextField(
          //     controller: _locationSearchController,
          //     onChanged: (_) => _onSearchChanged(),
          //     style: AppTypography.bodyMedium.copyWith(
          //       color: Colors.black87,
          //       fontWeight: FontWeight.w600,
          //     ),
          //     decoration: InputDecoration(
          //       filled: true,
          //       fillColor: Colors.white,
          //       hintText: 'Search location (e.g. Kukatpally, Hitec City)...',
          //       hintStyle: AppTypography.bodyMedium.copyWith(
          //         color: Colors.black38,
          //       ),
          //       prefixIcon: const Icon(
          //         Icons.location_on_outlined,
          //         color: Color(0xFF0277BD),
          //         size: 22,
          //       ),
          //       suffixIcon: _locationSearchController.text.isNotEmpty
          //           ? IconButton(
          //               icon: const Icon(
          //                 Icons.close_rounded,
          //                 color: Colors.black45,
          //                 size: 18,
          //               ),
          //               onPressed: () {
          //                 _locationSearchController.clear();
          //                 _onSearchChanged();
          //               },
          //             )
          //           : null,
          //       contentPadding: const EdgeInsets.symmetric(
          //         horizontal: 14,
          //         vertical: 12,
          //       ),
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(16),
          //         borderSide: BorderSide(
          //           color: Colors.grey.withValues(alpha: 0.2),
          //         ),
          //       ),
          //       enabledBorder: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(16),
          //         borderSide: BorderSide(
          //           color: Colors.grey.withValues(alpha: 0.2),
          //         ),
          //       ),
          //       focusedBorder: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(16),
          //         borderSide: const BorderSide(
          //           color: Color(0xFF0277BD),
          //           width: 1.5,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _appBarTitle,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: BlocBuilder<DriverListBloc, DriverListState>(
        builder: (context, state) {
          return Column(
            children: [
              // Search & Filter Bar
              _buildSearchAndFilterBar(context, state),

              // Driver List Content
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state is DriverListLoading ||
                        state is DriverListInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF266475),
                        ),
                      );
                    }

                    if (state is DriverListError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 56,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<DriverListBloc>().add(
                                    FetchDriversEvent(
                                      searchType: widget.searchType,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF266475),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is DriverListEmpty) {
                      final isQueryEmpty =
                          state.searchQuery.isEmpty &&
                          state.locationQuery.isEmpty;
                      final hasFilter = state.filterOptions.hasActiveFilter;

                      return RefreshIndicator(
                        color: const Color(0xFF266475),
                        onRefresh: () async {
                          context.read<DriverListBloc>().add(
                            FetchDriversEvent(
                              searchType: widget.searchType,
                              isRefresh: true,
                            ),
                          );
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        hasFilter || !isQueryEmpty
                                            ? Icons.filter_alt_off_rounded
                                            : (widget.searchType ==
                                                      DriverSearchType.local
                                                  ? Icons
                                                        .directions_car_filled_outlined
                                                  : Icons.alt_route_outlined),
                                        size: 64,
                                        color: Colors.black26,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        hasFilter
                                            ? 'No drivers match the selected filters'
                                            : (!isQueryEmpty
                                                  ? 'No drivers found matching your search'
                                                  : _emptyStateMessage),
                                        textAlign: TextAlign.center,
                                        style: AppTypography.titleMedium
                                            .copyWith(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      if (hasFilter || !isQueryEmpty) ...[
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            _driverSearchController.clear();
                                            _locationSearchController.clear();
                                            setState(() {});
                                            context.read<DriverListBloc>().add(
                                              const ResetFilterEvent(),
                                            );
                                            context.read<DriverListBloc>().add(
                                              const SearchDriversEvent(),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF266475,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.refresh_rounded,
                                          ),
                                          label: const Text(
                                            'Reset All Searches',
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is DriverListLoaded) {
                      return RefreshIndicator(
                        color: const Color(0xFF266475),
                        onRefresh: () async {
                          context.read<DriverListBloc>().add(
                            FetchDriversEvent(
                              searchType: widget.searchType,
                              isRefresh: true,
                            ),
                          );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 4, bottom: 24),
                          itemCount: state.drivers.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Top header subtitle banner
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  12,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        widget.searchType ==
                                            DriverSearchType.local
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          widget.searchType ==
                                              DriverSearchType.local
                                          ? const Color(0xFF81C784)
                                          : const Color(0xFFFFB74D),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        widget.searchType ==
                                                DriverSearchType.local
                                            ? Icons.near_me_rounded
                                            : Icons.map_rounded,
                                        size: 18,
                                        color:
                                            widget.searchType ==
                                                DriverSearchType.local
                                            ? const Color(0xFF2E7D32)
                                            : const Color(0xFFE65100),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _topHeaderSubtitle,
                                          style: AppTypography.labelMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    widget.searchType ==
                                                        DriverSearchType.local
                                                    ? const Color(0xFF1B5E20)
                                                    : const Color(0xFFBF360C),
                                              ),
                                        ),
                                      ),
                                      Text(
                                        '${state.drivers.length} Found',
                                        style: AppTypography.bodySmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final driver = state.drivers[index - 1];
                            return DriverCard(driver: driver);
                          },
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
