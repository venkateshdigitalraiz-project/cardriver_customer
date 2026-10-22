import '../entities/home_data.dart';
import '../entities/valet_event_booking_item.dart';
import '../entities/valet_event_booking_response.dart';

abstract class HomeRepository {
  Future<ValetEventBookingResponse> addValetEventBooking(ValetEventBookingItem booking);
  Future<HomeData> getHomeData();
}
