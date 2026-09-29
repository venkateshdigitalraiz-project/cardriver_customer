import 'package:cardriver_customer/features/booking/domain/entities/booking_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_bookings_event.dart';
import 'my_bookings_state.dart';

class MyBookingsBloc extends Bloc<MyBookingsEvent, MyBookingsState> {
  MyBookingsBloc() : super(MyBookingsInitial()) {
    on<LoadMyBookings>(_onLoadMyBookings);
  }

  Future<void> _onLoadMyBookings(
    LoadMyBookings event,
    Emitter<MyBookingsState> emit,
  ) async {
    emit(MyBookingsLoading());

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Dummy Data
      final dummyBookings = [
        BookingEntity(
          id: 'BKG-10294',
          status: 'Upcoming',
          tripType: 'Local',
          pickupAddress: 'Gachibowli, Hyderabad, Telangana',
          scheduleDate: DateTime.now().add(const Duration(days: 1)),
          duration: 4,
          fare: 600.0,
          driverName: 'Unassigned',
          driverMobile: 'N/A',
          driverVehicle: 'DriveU Classic',
        ),
        BookingEntity(
          id: 'BKG-10183',
          status: 'Completed',
          tripType: 'Outstation',
          pickupAddress: 'Madhapur, Hyderabad',
          dropAddress: 'Vijayawada, Andhra Pradesh',
          scheduleDate: DateTime.now().subtract(const Duration(days: 5)),
          duration: 2,
          fare: 3000.0,
          driverName: 'Rajesh Kumar',
          driverMobile: '+91 9876543210',
          driverVehicle: 'DriveU Plus',
        ),
        BookingEntity(
          id: 'BKG-09822',
          status: 'Cancelled',
          tripType: 'Local',
          pickupAddress: 'Kondapur, Hyderabad',
          scheduleDate: DateTime.now().subtract(const Duration(days: 12)),
          duration: 8,
          fare: 1200.0,
          driverName: 'Suresh Singh',
          driverMobile: '+91 8765432109',
          driverVehicle: 'DriveU Classic',
        ),
      ];

      emit(MyBookingsLoaded(dummyBookings));
    } catch (e) {
      emit(MyBookingsError('Failed to load bookings: $e'));
    }
  }
}
