import '../../domain/entities/wallet_entity.dart';
import 'wallet_transaction_model.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.balance,
    super.currency,
    required super.lastUpdated,
    super.transactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    var rawTxns = json['transactions'];
    List<WalletTransactionModel> txns = [];
    if (rawTxns is List) {
      txns = rawTxns
          .whereType<Map<String, dynamic>>()
          .map((e) => WalletTransactionModel.fromJson(e))
          .toList();
    }

    return WalletModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 450.0,
      currency: json['currency'] ?? '₹',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
      transactions: txns,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'currency': currency,
      'lastUpdated': lastUpdated.toIso8601String(),
      'transactions': transactions
          .map((e) => (e is WalletTransactionModel
              ? e
              : WalletTransactionModel(
                  id: e.id,
                  title: e.title,
                  description: e.description,
                  amount: e.amount,
                  timestamp: e.timestamp,
                  type: e.type,
                  status: e.status,
                )).toJson())
          .toList(),
    };
  }
}
