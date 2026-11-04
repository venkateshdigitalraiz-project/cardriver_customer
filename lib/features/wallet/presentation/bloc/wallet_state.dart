import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  final WalletEntity? currentWallet;
  const WalletLoading({this.currentWallet});

  @override
  List<Object?> get props => [currentWallet];
}

class WalletLoaded extends WalletState {
  final WalletEntity wallet;
  final String? successMessage;

  const WalletLoaded({
    required this.wallet,
    this.successMessage,
  });

  @override
  List<Object?> get props => [wallet, successMessage];
}

class WalletError extends WalletState {
  final String message;
  final WalletEntity? currentWallet;

  const WalletError({
    required this.message,
    this.currentWallet,
  });

  @override
  List<Object?> get props => [message, currentWallet];
}
