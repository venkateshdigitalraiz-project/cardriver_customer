import '../../../drivers/domain/entities/driver_search_type.dart';

abstract class NavigationState {
  final int tabIndex;
  final DriverSearchType searchType;

  NavigationState({
    required this.tabIndex,
    this.searchType = DriverSearchType.local,
  });
}

class NavigationInitial extends NavigationState {
  NavigationInitial({
    required super.tabIndex,
    super.searchType = DriverSearchType.local,
  });
}
