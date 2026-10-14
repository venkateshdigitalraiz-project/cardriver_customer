import '../entities/charges_entity.dart';
import '../repositories/booking_repository.dart';

class GetChargesUseCase {
  final BookingRepository repository;

  GetChargesUseCase(this.repository);

  Future<ChargesEntity> call() async {
    return await repository.getCharges();
  }
}
