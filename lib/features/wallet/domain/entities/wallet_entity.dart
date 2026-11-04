import 'package:equatable/equatable.dart';
import 'wallet_transaction_entity.dart';

class WalletEntity extends Equatable {
  final double balance;
  final String currency;
  final DateTime lastUpdated;
  final List<WalletTransactionEntity> transactions;

  const WalletEntity({
    required this.balance,
    this.currency = '₹',
    required this.lastUpdated,
    this.transactions = const [],
  });

  WalletEntity copyWith({
    double? balance,
    String? currency,
    DateTime? lastUpdated,
    List<WalletTransactionEntity>? transactions,
  }) {
    return WalletEntity(
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [balance, currency, lastUpdated, transactions];
}
