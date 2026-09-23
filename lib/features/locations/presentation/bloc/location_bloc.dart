import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/location_entity.dart';
import 'location_event.dart';
import 'location_state.dart';

const _kLocationsKey = 'saved_locations';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    on<LoadLocations>(_onLoadLocations);
    on<AddLocation>(_onAddLocation);
    on<RemoveLocation>(_onRemoveLocation);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<List<LocationEntity>> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kLocationsKey) ?? [];
    return raw.map((s) {
      final map = json.decode(s) as Map<String, dynamic>;
      return LocationEntity(
        id: map['id'] as String,
        name: map['name'] as String,
        address: map['address'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        isCurrentLocation: map['isCurrentLocation'] as bool? ?? false,
      );
    }).toList();
  }

  Future<void> _saveToPrefs(List<LocationEntity> locations) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = locations.map((loc) {
      return json.encode({
        'id': loc.id,
        'name': loc.name,
        'address': loc.address,
        'latitude': loc.latitude,
        'longitude': loc.longitude,
        'isCurrentLocation': loc.isCurrentLocation,
      });
    }).toList();
    await prefs.setStringList(_kLocationsKey, raw);
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onLoadLocations(
    LoadLocations event,
    Emitter<LocationState> emit,
  ) async {
    // If already loaded with data in memory, keep it
    if (state is LocationLoaded &&
        (state as LocationLoaded).locations.isNotEmpty) {
      return;
    }

    emit(LocationLoading());
    final locations = await _loadFromPrefs();
    emit(LocationLoaded(locations));
  }

  Future<void> _onAddLocation(
    AddLocation event,
    Emitter<LocationState> emit,
  ) async {
    final current = state is LocationLoaded
        ? (state as LocationLoaded).locations
        : <LocationEntity>[];
    final updated = [event.location, ...current];
    await _saveToPrefs(updated);
    emit(LocationLoaded(updated));
  }

  Future<void> _onRemoveLocation(
    RemoveLocation event,
    Emitter<LocationState> emit,
  ) async {
    if (state is LocationLoaded) {
      final updated = (state as LocationLoaded)
          .locations
          .where((loc) => loc.id != event.locationId)
          .toList();
      await _saveToPrefs(updated);
      emit(LocationLoaded(updated));
    }
  }
}
