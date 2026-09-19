import 'package:equatable/equatable.dart';
import '../../domain/entities/location_entity.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class LoadLocations extends LocationEvent {}

class AddLocation extends LocationEvent {
  final LocationEntity location;

  const AddLocation(this.location);

  @override
  List<Object> get props => [location];
}

class RemoveLocation extends LocationEvent {
  final String locationId;

  const RemoveLocation(this.locationId);

  @override
  List<Object> get props => [locationId];
}
