import 'package:flutter_test/flutter_test.dart';
import 'package:cardriver_customer/features/valet_parking/data/datasources/valet_parking_remote_datasource.dart';
import 'package:cardriver_customer/features/valet_parking/data/repositories/valet_parking_repository_impl.dart';
import 'package:cardriver_customer/features/valet_parking/domain/usecases/get_valet_bookings_usecase.dart';
import 'package:cardriver_customer/features/valet_parking/domain/usecases/get_valet_locations_usecase.dart';
import 'package:cardriver_customer/features/valet_parking/domain/usecases/get_active_valet_tickets_usecase.dart';
import 'package:cardriver_customer/features/valet_parking/domain/usecases/request_valet_booking_usecase.dart';
import 'package:cardriver_customer/features/valet_parking/domain/usecases/request_vehicle_retrieval_usecase.dart';
import 'package:cardriver_customer/features/valet_parking/presentation/bloc/valet_parking_bloc.dart';
import 'package:cardriver_customer/features/valet_parking/presentation/bloc/valet_parking_event.dart';
import 'package:cardriver_customer/features/valet_parking/presentation/bloc/valet_parking_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ValetParking Clean Architecture & BLoC Test', () {
    late ValetParkingRemoteDataSource remoteDataSource;
    late ValetParkingRepositoryImpl repository;
    late GetValetBookingsUseCase getValetBookingsUseCase;
    late GetValetLocationsUseCase getValetLocationsUseCase;
    late GetActiveValetTicketsUseCase getActiveValetTicketsUseCase;
    late RequestValetBookingUseCase requestValetBookingUseCase;
    late RequestVehicleRetrievalUseCase requestVehicleRetrievalUseCase;
    late ValetParkingBloc bloc;

    setUp(() {
      remoteDataSource = ValetParkingRemoteDataSourceImpl();
      repository = ValetParkingRepositoryImpl(remoteDataSource: remoteDataSource);
      getValetBookingsUseCase = GetValetBookingsUseCase(repository);
      getValetLocationsUseCase = GetValetLocationsUseCase(repository);
      getActiveValetTicketsUseCase = GetActiveValetTicketsUseCase(repository);
      requestValetBookingUseCase = RequestValetBookingUseCase(repository);
      requestVehicleRetrievalUseCase = RequestVehicleRetrievalUseCase(repository);

      bloc = ValetParkingBloc(
        getValetBookingsUseCase: getValetBookingsUseCase,
        getValetLocationsUseCase: getValetLocationsUseCase,
        getActiveValetTicketsUseCase: getActiveValetTicketsUseCase,
        requestValetBookingUseCase: requestValetBookingUseCase,
        requestVehicleRetrievalUseCase: requestVehicleRetrievalUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should be ValetParkingStatus.initial', () {
      expect(bloc.state.status, ValetParkingStatus.initial);
      expect(bloc.state.bookings, isEmpty);
      expect(bloc.state.locations, isEmpty);
      expect(bloc.state.activeTickets, isEmpty);
    });

    test('LoadValetParkingData loads API bookings successfully', () async {
      bloc.add(const LoadValetParkingData());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ValetParkingState>().having((s) => s.status, 'status', ValetParkingStatus.loading),
          isA<ValetParkingState>()
              .having((s) => s.status, 'status', ValetParkingStatus.loaded)
              .having((s) => s.bookings.isNotEmpty, 'has bookings', true)
              .having((s) => s.bookings.first.bookingId, 'booking ID', 'VLT-167998'),
        ]),
      );
    });

    test('FilterValetBookingsByStatus filters bookings by status', () async {
      bloc.add(const LoadValetParkingData());
      await bloc.stream.firstWhere((s) => s.status == ValetParkingStatus.loaded);

      bloc.add(const FilterValetBookingsByStatus('in_progress'));
      final filteredState = await bloc.stream.first;
      expect(filteredState.selectedStatusFilter, 'in_progress');
      expect(filteredState.filteredBookings.length, 1);
      expect(filteredState.filteredBookings.first.bookingId, 'VLT-785688');
    });

    test('SearchValetBookings searches by keyword', () async {
      bloc.add(const LoadValetParkingData());
      await bloc.stream.firstWhere((s) => s.status == ValetParkingStatus.loaded);

      bloc.add(const SearchValetBookings('Wedding'));
      final searchedState = await bloc.stream.first;
      expect(searchedState.filteredBookings.length, 1);
      expect(searchedState.filteredBookings.first.eventName, contains('Wedding'));
    });
  });
}
