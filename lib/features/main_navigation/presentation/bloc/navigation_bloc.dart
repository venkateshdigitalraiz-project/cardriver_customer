import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationInitial(tabIndex: 0)) {
    on<TabChanged>((event, emit) {
      emit(NavigationInitial(tabIndex: event.tabIndex));
    });
  }
}
