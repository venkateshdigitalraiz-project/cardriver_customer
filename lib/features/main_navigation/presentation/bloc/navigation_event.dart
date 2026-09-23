import '../../../drivers/domain/entities/driver_search_type.dart';

abstract class NavigationEvent {}

class TabChanged extends NavigationEvent {
  final int tabIndex;
  final DriverSearchType searchType;

  TabChanged(this.tabIndex, {this.searchType = DriverSearchType.local});
}
