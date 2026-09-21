import 'package:equatable/equatable.dart';
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
