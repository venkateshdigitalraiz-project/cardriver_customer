import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_money_usecase.dart';
import '../../domain/usecases/get_wallet_usecase.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletUseCase getWalletUseCase;
  final AddMoneyUseCase addMoneyUseCase;

  WalletBloc({
    required this.getWalletUseCase,
    required this.addMoneyUseCase,
  }) : super(const WalletInitial()) {
    on<LoadWalletEvent>(_onLoadWallet);
    on<RefreshWalletEvent>(_onRefreshWallet);
    on<AddMoneyToWalletEvent>(_onAddMoney);
  }

  Future<void> _onLoadWallet(
    LoadWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      final wallet = await getWalletUseCase();
      emit(WalletLoaded(wallet: wallet));
    } catch (e) {
      emit(WalletError(message: 'Failed to load wallet: $e'));
    }
  }

  Future<void> _onRefreshWallet(
    RefreshWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    final current = state is WalletLoaded ? (state as WalletLoaded).wallet : null;
    try {
      final wallet = await getWalletUseCase();
      emit(WalletLoaded(wallet: wallet));
    } catch (e) {
      if (current != null) {
        emit(WalletLoaded(wallet: current));
      } else {
        emit(WalletError(message: 'Failed to refresh wallet: $e'));
      }
    }
  }

  Future<void> _onAddMoney(
    AddMoneyToWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    final current = state is WalletLoaded ? (state as WalletLoaded).wallet : null;
    emit(WalletLoading(currentWallet: current));
    try {
      if (event.amount <= 0) {
        emit(WalletError(
          message: 'Please enter a valid amount greater than ₹0',
          currentWallet: current,
        ));
        if (current != null) emit(WalletLoaded(wallet: current));
        return;
      }
      final updatedWallet = await addMoneyUseCase(
        amount: event.amount,
        paymentMethod: event.paymentMethod,
      );
      emit(WalletLoaded(
        wallet: updatedWallet,
        successMessage: '₹${event.amount.toStringAsFixed(0)} added successfully to wallet!',
      ));
    } catch (e) {
      emit(WalletError(
        message: 'Failed to add money: $e',
        currentWallet: current,
      ));
      if (current != null) emit(WalletLoaded(wallet: current));
    }
  }
}
