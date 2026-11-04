import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletEvent extends WalletEvent {
  const LoadWalletEvent();
}

class AddMoneyToWalletEvent extends WalletEvent {
  final double amount;
  final String paymentMethod;

  const AddMoneyToWalletEvent({
    required this.amount,
    this.paymentMethod = 'UPI / NetBanking',
  });

  @override
  List<Object?> get props => [amount, paymentMethod];
}

class RefreshWalletEvent extends WalletEvent {
  const RefreshWalletEvent();
}
