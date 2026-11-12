import '../../features/booking/domain/entities/charges_entity.dart';

/// Singleton in-memory cache for GET /api/common/charges in cardriver_customer (Customer App).
/// Provides fast, synchronous access to charges across all BLoCs (BookingFlowBloc, PostJobBloc),
/// UseCases, and screens, eliminating repeated network requests.
class ChargesCache {
  ChargesCache._internal();

  static final ChargesCache _instance = ChargesCache._internal();

  static ChargesCache get instance => _instance;

  ChargesEntity? _charges;
  Future<ChargesEntity>? inFlight;

  /// Returns true if valid cached charges exist.
  bool get hasData => _charges != null;

  /// Returns the cached charges entity, or null if not yet loaded.
  ChargesEntity? get charges => _charges;

  /// Stores charges in memory.
  void setCharges(ChargesEntity data) {
    _charges = data;
  }

  /// Clears in-memory cache (e.g. on logout or refresh).
  void clear() {
    _charges = null;
    inFlight = null;
  }
}

