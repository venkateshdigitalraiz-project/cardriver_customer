abstract class NavigationState {
  final int tabIndex;
  NavigationState({required this.tabIndex});
}

class NavigationInitial extends NavigationState {
  NavigationInitial({required super.tabIndex});
}
