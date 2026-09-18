abstract class HomeEvent {}

class BannerPageChanged extends HomeEvent {
  final int index;
  BannerPageChanged(this.index);
}
