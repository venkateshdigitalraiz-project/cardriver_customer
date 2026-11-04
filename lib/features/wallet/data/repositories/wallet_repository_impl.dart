import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/wallet_transaction_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_local_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource localDataSource;

  WalletRepositoryImpl({required this.localDataSource});

  @override
  Future<WalletEntity> getWallet() async {
    return await localDataSource.getWallet();
  }

  @override
  Future<WalletEntity> addMoney({
    required double amount,
    required String paymentMethod,
  }) async {
    return await localDataSource.addMoney(amount, paymentMethod);
  }

  @override
  Future<List<WalletTransactionEntity>> getTransactions() async {
    return await localDataSource.getTransactions();
  }
}
