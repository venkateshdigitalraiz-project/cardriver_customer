import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial(currentBannerIndex: 0)) {
    on<BannerPageChanged>((event, emit) {
      emit(HomeInitial(currentBannerIndex: event.index));
    });
  }
}
