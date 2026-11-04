import '../entities/wallet_transaction_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletTransactionsUseCase {
  final WalletRepository repository;

  GetWalletTransactionsUseCase(this.repository);

  Future<List<WalletTransactionEntity>> call() async {
    return await repository.getTransactions();
  }
}
