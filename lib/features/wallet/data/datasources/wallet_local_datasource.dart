import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/wallet_transaction_entity.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

abstract class WalletLocalDataSource {
  Future<WalletModel> getWallet();
  Future<WalletModel> addMoney(double amount, String paymentMethod);
  Future<List<WalletTransactionModel>> getTransactions();
}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  static const String _kWalletKey = 'customer_wallet_cache_v1';

  WalletModel _getDefaultWallet() {
    return WalletModel(
      balance: 450.0,
      currency: '₹',
      lastUpdated: DateTime.now(),
      transactions: [
        WalletTransactionModel(
          id: 'TXN${DateTime.now().millisecondsSinceEpoch - 1000000}',
          title: 'Added to Wallet',
          description: 'Payment via Google Pay UPI',
          amount: 500.0,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: TransactionType.credit,
          status: 'Completed',
        ),
        WalletTransactionModel(
          id: 'TXN${DateTime.now().millisecondsSinceEpoch - 2500000}',
          title: 'Ride Payment - Local Trip',
          description: 'Booking #CD-9281',
          amount: 150.0,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          type: TransactionType.debit,
          status: 'Completed',
        ),
        WalletTransactionModel(
          id: 'TXN${DateTime.now().millisecondsSinceEpoch - 5000000}',
          title: 'Promo Cashback',
          description: 'First booking reward credited',
          amount: 100.0,
          timestamp: DateTime.now().subtract(const Duration(days: 4)),
          type: TransactionType.credit,
          status: 'Completed',
        ),
      ],
    );
  }

  @override
  Future<WalletModel> getWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_kWalletKey);
    if (data != null) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return WalletModel.fromJson(decoded);
        }
      } catch (_) {}
    }
    final defaultWallet = _getDefaultWallet();
    await prefs.setString(_kWalletKey, jsonEncode(defaultWallet.toJson()));
    return defaultWallet;
  }

  @override
  Future<WalletModel> addMoney(double amount, String paymentMethod) async {
    final current = await getWallet();
    final newBalance = current.balance + amount;
    final newTxn = WalletTransactionModel(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      title: 'Added to Wallet',
      description: 'Payment via $paymentMethod',
      amount: amount,
      timestamp: DateTime.now(),
      type: TransactionType.credit,
      status: 'Completed',
    );

    final updatedTxns = [newTxn, ...current.transactions];
    final updatedWallet = WalletModel(
      balance: newBalance,
      currency: current.currency,
      lastUpdated: DateTime.now(),
      transactions: updatedTxns,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kWalletKey, jsonEncode(updatedWallet.toJson()));
    return updatedWallet;
  }

  @override
  Future<List<WalletTransactionModel>> getTransactions() async {
    final wallet = await getWallet();
    return wallet.transactions.cast<WalletTransactionModel>();
  }
}
