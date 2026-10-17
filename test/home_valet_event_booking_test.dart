import 'package:flutter_test/flutter_test.dart';
import 'package:cardriver_customer/features/home/domain/entities/valet_event_booking_item.dart';
import 'package:cardriver_customer/features/home/domain/entities/valet_event_booking_response.dart';
import 'package:cardriver_customer/features/home/domain/repositories/home_repository.dart';
import 'package:cardriver_customer/features/home/domain/usecases/add_valet_event_booking_usecase.dart';
import 'package:cardriver_customer/features/home/presentation/bloc/home_bloc.dart';
import 'package:cardriver_customer/features/home/presentation/bloc/home_event.dart';
import 'package:cardriver_customer/features/home/presentation/bloc/home_state.dart';

class MockHomeRepository implements HomeRepository {
  ValetEventBookingItem? lastAddedBooking;

  @override
  Future<ValetEventBookingResponse> addValetEventBooking(
      ValetEventBookingItem booking) async {
    lastAddedBooking = booking;
    return ValetEventBookingResponse(
      success: true,
      message: 'Valet parking booking created successfully',
      data: ValetBookingResponseData(
        id: '6ad23b007eed370ed331b195',
        bookingId: 'VLT-505174',
        userId: '6ab6427b440da47e3ac83da3',
        eventName: booking.eventName,
        eventType: booking.eventType,
        eventDate: booking.eventDate,
        startTime: booking.startTime,
        endTime: booking.endTime,
        hours: booking.hours,
        person: booking.person,
        venueName: booking.venueName,
        address: booking.address,
        coordinates: booking.coordinates,
        pricing: const ValetBookingPricing(
          customerPrice: 10000,
          driverPrice: 2400,
          taxAmount: 1800,
          totalAmount: 11800,
          staffPayoutTotal: 2400,
          platformCommission: 7600,
        ),
        assignedStaffIds: const [],
        status: 'new_request',
        paymentStatus: 'pending',
        paymentMethod: booking.paymentMethod,
        specialInstructions: booking.specialInstructions,
        createdAt: '2026-10-16T14:56:00.443Z',
        updatedAt: '2026-10-16T14:56:00.443Z',
      ),
    );
  }
}

void main() {
  group('Home Valet Event Booking Clean Architecture & BLoC Tests', () {
    late MockHomeRepository mockRepository;
    late AddValetEventBookingUseCase useCase;
    late HomeBloc homeBloc;

    const sampleBooking = ValetEventBookingItem(
      eventName: "Royals Grand Wedding Gala 2026",
      eventType: "wedding",
      eventDate: "2026-11-20T18:00:00.000Z",
      startTime: "18:00",
      endTime: "23:00",
      hours: 5,
      person: 4,
      venueName: "The Leela Palace",
      coordinates: [77.6483, 12.9606],
      locationAddress:
          "The Leela Palace, 23 HAL Old Airport Rd, Kodihalli, Bengaluru, Karnataka 560008",
      address:
          "The Leela Palace, 23 HAL Old Airport Rd, Kodihalli, Bengaluru, Karnataka 560008",
      specialInstructions:
          "Guests will arrive in luxury sedans and SUVs. Please maintain uniform valet etiquette.",
      paymentMethod: "online",
    );

    setUp(() {
      mockRepository = MockHomeRepository();
      useCase = AddValetEventBookingUseCase(mockRepository);
      homeBloc = HomeBloc(addValetEventBookingUseCase: useCase);
    });

    tearDown(() {
      homeBloc.close();
    });

    test('ValetEventBookingItem toJson and fromJson serialization', () {
      final json = sampleBooking.toJson();
      expect(json['eventName'], 'Royals Grand Wedding Gala 2026');
      expect(json['eventType'], 'wedding');
      expect(json['hours'], 5);
      expect(json['person'], 4);
      expect(json['location']['coordinates'], [77.6483, 12.9606]);

      final parsed = ValetEventBookingItem.fromJson(json);
      expect(parsed.eventName, sampleBooking.eventName);
      expect(parsed.eventType, sampleBooking.eventType);
      expect(parsed.coordinates, sampleBooking.coordinates);
      expect(parsed.address, sampleBooking.address);
    });

    test('ValetEventBookingResponse fromJson parses server response properly', () {
      final serverResponse = {
        "success": true,
        "message": "Valet parking booking created successfully",
        "data": {
          "userId": "6ab6427b440da47e3ac83da3",
          "eventName": "Royals Grand Wedding Gala 2026",
          "eventType": "wedding",
          "eventDate": "2026-11-20T18:00:00.000Z",
          "startTime": "18:00",
          "endTime": "23:00",
          "hours": 5,
          "person": 4,
          "location": {
            "type": "Point",
            "coordinates": [77.6483, 12.9606],
            "address": "The Leela Palace"
          },
          "address": "The Leela Palace",
          "venueName": "The Leela Palace",
          "pricing": {
            "customerPrice": 10000,
            "driverPrice": 2400,
            "taxAmount": 1800,
            "totalAmount": 11800,
            "staffPayoutTotal": 2400,
            "platformCommission": 7600
          },
          "assignedStaffIds": [],
          "status": "new_request",
          "paymentStatus": "pending",
          "paymentMethod": "online",
          "specialInstructions": "Guests will arrive in luxury sedans and SUVs.",
          "_id": "6ad23b007eed370ed331b195",
          "bookingId": "VLT-505174",
        }
      };

      final response = ValetEventBookingResponse.fromJson(serverResponse);
      expect(response.success, true);
      expect(response.message, 'Valet parking booking created successfully');
      expect(response.data.bookingId, 'VLT-505174');
      expect(response.data.id, '6ad23b007eed370ed331b195');
      expect(response.data.pricing.totalAmount, 11800);
      expect(response.data.status, 'new_request');
    });

    test('AddValetEventBookingUseCase calls repository successfully', () async {
      final result = await useCase(sampleBooking);
      expect(result.success, true);
      expect(result.data.bookingId, 'VLT-505174');
      expect(mockRepository.lastAddedBooking, sampleBooking);
    });

    test('HomeBloc emits isSubmittingValet and valetSubmitSuccess when SubmitValetEventBooking is added', () async {
      final expectedStates = [
        isA<HomeState>()
            .having((s) => s.isSubmittingValet, 'isSubmittingValet', true)
            .having((s) => s.valetSubmitSuccess, 'valetSubmitSuccess', false),
        isA<HomeState>()
            .having((s) => s.isSubmittingValet, 'isSubmittingValet', false)
            .having((s) => s.valetSubmitSuccess, 'valetSubmitSuccess', true)
            .having((s) => s.valetBookingResponse?.data.bookingId, 'bookingId',
                'VLT-505174'),
      ];

      expectLater(homeBloc.stream, emitsInOrder(expectedStates));

      homeBloc.add(SubmitValetEventBooking(sampleBooking));
    });

    test('BannerPageChanged updates currentBannerIndex', () async {
      expectLater(
        homeBloc.stream,
        emits(isA<HomeState>()
            .having((s) => s.currentBannerIndex, 'currentBannerIndex', 2)),
      );

      homeBloc.add(BannerPageChanged(2));
    });

    test('ResetValetBookingSubmission resets valetSubmitSuccess and clears response', () async {
      expectLater(
        homeBloc.stream,
        emits(isA<HomeState>()
            .having((s) => s.valetSubmitSuccess, 'valetSubmitSuccess', false)
            .having((s) => s.valetBookingResponse, 'valetBookingResponse', isNull)),
      );

      homeBloc.add(ResetValetBookingSubmission());
    });
  });
}
