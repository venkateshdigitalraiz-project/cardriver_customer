import '../entities/driver_job_item.dart';
import '../entities/driver_job_response.dart';
import '../entities/home_data.dart';
import '../entities/valet_event_booking_item.dart';
import '../entities/valet_event_booking_response.dart';

abstract class HomeRepository {
  Future<ValetEventBookingResponse> addValetEventBooking(ValetEventBookingItem booking);
  Future<DriverJobResponse> postDriverJob(DriverJobItem job);
  Future<HomeData> getHomeData();
}

