import '../entities/wallet_entity.dart';
import '../entities/wallet_transaction_entity.dart';

abstract class WalletRepository {
  Future<WalletEntity> getWallet();
  Future<WalletEntity> addMoney({
    required double amount,
    required String paymentMethod,
  });
  Future<List<WalletTransactionEntity>> getTransactions();
}
