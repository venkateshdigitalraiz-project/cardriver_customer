import 'package:flutter_bloc/flutter_bloc.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  SupportBloc() : super(SupportInitial()) {
    on<LoadSupportData>((event, emit) async {
      emit(SupportLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(SupportLoaded(
        categories: [
          HelpCategory(title: 'Trip issues', subtitle: 'Fare, route, cancellation', iconCode: 'receipt_long', colorCode: 'blue'),
          HelpCategory(title: 'Payments', subtitle: 'Payouts, wallet, bank', iconCode: 'payment', colorCode: 'green'),
          HelpCategory(title: 'Documents', subtitle: 'Upload, expiry, rejected', iconCode: 'folder_open', colorCode: 'deepPurple'),
          HelpCategory(title: 'Rewards', subtitle: 'Bonus, tiers, redeem', iconCode: 'card_giftcard', colorCode: 'orange'),
        ],
        recentTickets: [
          Ticket(title: 'Payout not received', id: '20418', date: '26 Sep', status: 'In progress'),
          Ticket(title: 'Wrong fare on trip', id: '19876', date: '18 Sep', status: 'Resolved'),
        ],
      ));
    });
  }
}
