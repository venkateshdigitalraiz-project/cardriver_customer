import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/entities/driver_filter_options.dart';
import '../../domain/entities/driver_search_type.dart';
import '../../domain/usecases/get_drivers_usecase.dart';
import 'driver_list_event.dart';
import 'driver_list_state.dart';

class DriverListBloc extends Bloc<DriverListEvent, DriverListState> {
  final GetDriversUseCase getDriversUseCase;

  List<DriverEntity> _allFetchedDrivers = [];
  DriverSearchType? _currentSearchType;
  String _currentQuery = '';
  String _currentLocationQuery = '';
  DriverFilterOptions _currentFilterOptions = const DriverFilterOptions();

  DriverListBloc({required this.getDriversUseCase}) : super(DriverListInitial()) {
    on<FetchDriversEvent>(_onFetchDrivers);
    on<SearchDriversEvent>(_onSearchDrivers);
    on<ApplyFilterEvent>(_onApplyFilter);
    on<ResetFilterEvent>(_onResetFilter);
  }

  Future<void> _onFetchDrivers(
    FetchDriversEvent event,
    Emitter<DriverListState> emit,
  ) async {
    _currentSearchType = event.searchType;
    if (!event.isRefresh) {
      emit(DriverListLoading());
    }

    try {
      double? lat;
      double? lng;

      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
          );
          lat = pos.latitude;
          lng = pos.longitude;
        }
      } catch (_) {
        // Fallback gracefully if location permission/service unavailable
      }

      _allFetchedDrivers = await getDriversUseCase(
        searchType: event.searchType,
        userLat: lat,
        userLng: lng,
      );

      _emitFilteredDrivers(emit);
    } catch (e) {
      emit(DriverListError(
        message: 'Unable to load drivers',
        searchType: event.searchType,
      ));
    }
  }

  void _onSearchDrivers(
    SearchDriversEvent event,
    Emitter<DriverListState> emit,
  ) {
    _currentQuery = event.query.trim().toLowerCase();
    _currentLocationQuery = event.locationQuery.trim().toLowerCase();
    _emitFilteredDrivers(emit);
  }

  void _onApplyFilter(
    ApplyFilterEvent event,
    Emitter<DriverListState> emit,
  ) {
    _currentFilterOptions = event.filterOptions;
    _emitFilteredDrivers(emit);
  }

  void _onResetFilter(
    ResetFilterEvent event,
    Emitter<DriverListState> emit,
  ) {
    _currentQuery = '';
    _currentLocationQuery = '';
    _currentFilterOptions = const DriverFilterOptions();
    _emitFilteredDrivers(emit);
  }

  void _emitFilteredDrivers(Emitter<DriverListState> emit) {
    final searchType = _currentSearchType ?? DriverSearchType.local;

    List<DriverEntity> result = List.from(_allFetchedDrivers);

    // 1. Driver Name / Car Search Query Filter
    if (_currentQuery.isNotEmpty) {
      result = result.where((driver) {
        final nameMatch = driver.name.toLowerCase().contains(_currentQuery);
        final carNameMatch = driver.carName.toLowerCase().contains(_currentQuery);
        final carTypeMatch = driver.carType.toLowerCase().contains(_currentQuery);
        final mobileMatch = driver.mobileNumber.toLowerCase().contains(_currentQuery);
        return nameMatch || carNameMatch || carTypeMatch || mobileMatch;
      }).toList();
    }

    // 2. Location Search Query Filter
    if (_currentLocationQuery.isNotEmpty) {
      result = result.where((driver) {
        return driver.address.toLowerCase().contains(_currentLocationQuery);
      }).toList();
    }

    // 3. Near By Filter
    if (_currentFilterOptions.nearByOnly) {
      if (searchType == DriverSearchType.local) {
        result = result.where((driver) => driver.distance <= 15.0).toList();
      } else {
        result = result.where((driver) => driver.distance <= 150.0).toList();
      }
    }

    // 4. Distance Filter
    switch (_currentFilterOptions.distanceFilter) {
      case DistanceFilterOption.nearBy15km:
        result = result.where((driver) => driver.distance <= 15.0).toList();
        break;
      case DistanceFilterOption.under50km:
        result = result.where((driver) => driver.distance <= 50.0).toList();
        break;
      case DistanceFilterOption.under100km:
        result = result.where((driver) => driver.distance <= 100.0).toList();
        break;
      case DistanceFilterOption.outstation100To200km:
        result = result.where((driver) => driver.distance >= 100.0 && driver.distance <= 200.0).toList();
        break;
      case DistanceFilterOption.outstation200To500km:
        result = result.where((driver) => driver.distance > 200.0 && driver.distance <= 500.0).toList();
        break;
      case DistanceFilterOption.outstationAbove500km:
        result = result.where((driver) => driver.distance > 500.0).toList();
        break;
      case DistanceFilterOption.all:
        break;
    }

    // 5. Price Sort / Filter
    switch (_currentFilterOptions.priceSort) {
      case PriceSortOption.lowToHigh:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case PriceSortOption.highToLow:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case PriceSortOption.under300:
        result = result.where((driver) => driver.price <= 300.0).toList();
        break;
      case PriceSortOption.under500:
        result = result.where((driver) => driver.price <= 500.0).toList();
        break;
      case PriceSortOption.defaultSort:
        // Default sort by distance
        result.sort((a, b) => a.distance.compareTo(b.distance));
        break;
    }

    if (result.isEmpty) {
      emit(DriverListEmpty(
        searchType: searchType,
        searchQuery: _currentQuery,
        locationQuery: _currentLocationQuery,
        filterOptions: _currentFilterOptions,
      ));
    } else {
      emit(DriverListLoaded(
        drivers: result,
        searchType: searchType,
        searchQuery: _currentQuery,
        locationQuery: _currentLocationQuery,
        filterOptions: _currentFilterOptions,
      ));
    }
  }
}
