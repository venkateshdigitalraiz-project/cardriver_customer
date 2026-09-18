abstract class NavigationEvent {}

class TabChanged extends NavigationEvent {
  final int tabIndex;

  TabChanged(this.tabIndex);
}
