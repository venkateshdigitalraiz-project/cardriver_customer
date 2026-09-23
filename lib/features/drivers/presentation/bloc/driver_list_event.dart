import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_filter_options.dart';
import '../../domain/entities/driver_search_type.dart';

abstract class DriverListEvent extends Equatable {
  const DriverListEvent();

  @override
  List<Object?> get props => [];
}

class FetchDriversEvent extends DriverListEvent {
  final DriverSearchType searchType;
  final bool isRefresh;

  const FetchDriversEvent({
    required this.searchType,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [searchType, isRefresh];
}

class SearchDriversEvent extends DriverListEvent {
  final String query;
  final String locationQuery;

  const SearchDriversEvent({
    this.query = '',
    this.locationQuery = '',
  });

  @override
  List<Object?> get props => [query, locationQuery];
}

class ApplyFilterEvent extends DriverListEvent {
  final DriverFilterOptions filterOptions;

  const ApplyFilterEvent(this.filterOptions);

  @override
  List<Object?> get props => [filterOptions];
}

class ResetFilterEvent extends DriverListEvent {
  const ResetFilterEvent();
}
