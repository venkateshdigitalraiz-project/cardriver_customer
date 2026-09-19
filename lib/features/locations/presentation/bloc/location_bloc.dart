import 'package:flutter_bloc/flutter_bloc.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    on<LoadLocations>(_onLoadLocations);
    on<AddLocation>(_onAddLocation);
    on<RemoveLocation>(_onRemoveLocation);
  }

  void _onLoadLocations(LoadLocations event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    // Simulate fetching from local database/API
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Some dummy initial locations
    emit(LocationLoaded(const []));
  }

  void _onAddLocation(AddLocation event, Emitter<LocationState> emit) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      final updatedLocations = List.of(currentState.locations)..insert(0, event.location);
      emit(LocationLoaded(updatedLocations));
    } else {
      emit(LocationLoaded([event.location]));
    }
  }

  void _onRemoveLocation(RemoveLocation event, Emitter<LocationState> emit) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      final updatedLocations = currentState.locations.where((loc) => loc.id != event.locationId).toList();
      emit(LocationLoaded(updatedLocations));
    }
  }
}
