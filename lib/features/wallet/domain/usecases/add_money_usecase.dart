import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class AddMoneyUseCase {
  final WalletRepository repository;

  AddMoneyUseCase(this.repository);

  Future<WalletEntity> call({
    required double amount,
    String paymentMethod = 'UPI / Card',
  }) async {
    return await repository.addMoney(
      amount: amount,
      paymentMethod: paymentMethod,
    );
  }
}
