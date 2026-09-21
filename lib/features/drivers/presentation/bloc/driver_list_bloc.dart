import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/usecases/get_drivers_usecase.dart';
import 'driver_list_event.dart';
import 'driver_list_state.dart';

class DriverListBloc extends Bloc<DriverListEvent, DriverListState> {
  final GetDriversUseCase getDriversUseCase;

  DriverListBloc({required this.getDriversUseCase}) : super(DriverListInitial()) {
    on<FetchDriversEvent>(_onFetchDrivers);
  }

  Future<void> _onFetchDrivers(
    FetchDriversEvent event,
    Emitter<DriverListState> emit,
  ) async {
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

      final drivers = await getDriversUseCase(
        searchType: event.searchType,
        userLat: lat,
        userLng: lng,
      );

      if (drivers.isEmpty) {
        emit(DriverListEmpty(searchType: event.searchType));
      } else {
        emit(DriverListLoaded(drivers: drivers, searchType: event.searchType));
      }
    } catch (e) {
      emit(DriverListError(
        message: 'Unable to load drivers',
        searchType: event.searchType,
      ));
    }
  }
}
