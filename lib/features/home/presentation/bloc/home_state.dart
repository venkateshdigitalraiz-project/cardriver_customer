abstract class HomeState {
  final int currentBannerIndex;
  HomeState({required this.currentBannerIndex});
}

class HomeInitial extends HomeState {
  HomeInitial({required super.currentBannerIndex});
}
