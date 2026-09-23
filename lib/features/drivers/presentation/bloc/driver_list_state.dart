import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/entities/driver_filter_options.dart';
import '../../domain/entities/driver_search_type.dart';

abstract class DriverListState extends Equatable {
  const DriverListState();

  @override
  List<Object?> get props => [];
}

class DriverListInitial extends DriverListState {}

class DriverListLoading extends DriverListState {}

class DriverListLoaded extends DriverListState {
  final List<DriverEntity> drivers;
  final DriverSearchType searchType;
  final String searchQuery;
  final String locationQuery;
  final DriverFilterOptions filterOptions;

  const DriverListLoaded({
    required this.drivers,
    required this.searchType,
    this.searchQuery = '',
    this.locationQuery = '',
    this.filterOptions = const DriverFilterOptions(),
  });

  @override
  List<Object?> get props =>
      [drivers, searchType, searchQuery, locationQuery, filterOptions];
}

class DriverListEmpty extends DriverListState {
  final DriverSearchType searchType;
  final String searchQuery;
  final String locationQuery;
  final DriverFilterOptions filterOptions;

  const DriverListEmpty({
    required this.searchType,
    this.searchQuery = '',
    this.locationQuery = '',
    this.filterOptions = const DriverFilterOptions(),
  });

  @override
  List<Object?> get props =>
      [searchType, searchQuery, locationQuery, filterOptions];
}

class DriverListError extends DriverListState {
  final String message;
  final DriverSearchType searchType;

  const DriverListError({
    required this.message,
    required this.searchType,
  });

  @override
  List<Object?> get props => [message, searchType];
}
