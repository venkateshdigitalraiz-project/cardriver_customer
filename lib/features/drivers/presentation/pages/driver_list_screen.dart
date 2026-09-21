import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/driver_remote_datasource.dart';
import '../../data/repositories/driver_repository_impl.dart';
import '../../domain/entities/driver_search_type.dart';
import '../../domain/usecases/get_drivers_usecase.dart';
import '../bloc/driver_list_bloc.dart';
import '../bloc/driver_list_event.dart';
import '../bloc/driver_list_state.dart';
import '../widgets/driver_card.dart';

class DriverListScreen extends StatelessWidget {
  final DriverSearchType searchType;

  const DriverListScreen({
    super.key,
    required this.searchType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DriverListBloc(
        getDriversUseCase: GetDriversUseCase(
          DriverRepositoryImpl(
            remoteDataSource: DriverRemoteDataSourceImpl(),
          ),
        ),
      )..add(FetchDriversEvent(searchType: searchType)),
      child: _DriverListScreenView(searchType: searchType),
    );
  }
}

class _DriverListScreenView extends StatelessWidget {
  final DriverSearchType searchType;

  const _DriverListScreenView({required this.searchType});

  String get _appBarTitle {
    return searchType == DriverSearchType.local
        ? 'Local Drivers'
        : 'Outstation Drivers';
  }

  String get _topHeaderSubtitle {
    return searchType == DriverSearchType.local
        ? 'Drivers available within 100 KM'
        : 'Drivers available beyond 100 KM';
  }

  String get _emptyStateMessage {
    return searchType == DriverSearchType.local
        ? 'No local drivers available within 100 KM'
        : 'No outstation drivers available beyond 100 KM';
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
          if (state is DriverListLoading || state is DriverListInitial) {
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
                              FetchDriversEvent(searchType: searchType),
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
            return RefreshIndicator(
              color: const Color(0xFF266475),
              onRefresh: () async {
                context.read<DriverListBloc>().add(
                      FetchDriversEvent(
                        searchType: searchType,
                        isRefresh: true,
                      ),
                    );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              searchType == DriverSearchType.local
                                  ? Icons.directions_car_filled_outlined
                                  : Icons.alt_route_outlined,
                              size: 64,
                              color: Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _emptyStateMessage,
                              textAlign: TextAlign.center,
                              style: AppTypography.titleMedium.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
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

          if (state is DriverListLoaded) {
            return RefreshIndicator(
              color: const Color(0xFF266475),
              onRefresh: () async {
                context.read<DriverListBloc>().add(
                      FetchDriversEvent(
                        searchType: searchType,
                        isRefresh: true,
                      ),
                    );
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                itemCount: state.drivers.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Top header subtitle banner
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: searchType == DriverSearchType.local
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: searchType == DriverSearchType.local
                                ? const Color(0xFF81C784)
                                : const Color(0xFFFFB74D),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              searchType == DriverSearchType.local
                                  ? Icons.near_me_rounded
                                  : Icons.map_rounded,
                              size: 18,
                              color: searchType == DriverSearchType.local
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE65100),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _topHeaderSubtitle,
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: searchType == DriverSearchType.local
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
    );
  }
}
