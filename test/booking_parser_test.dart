import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardriver_customer/features/booking/data/models/booking_model.dart';
import 'package:cardriver_customer/features/booking/data/models/booking_detail_model.dart';

void main() {
  test('parses booking list response json', () {
    const jsonStr = '''
    {
      "success": true,
      "data": {
        "bookings": [
          {
            "_id": "6ace03e49d216de59e600169",
            "userId": "6ab6427b440da47e3ac83da3",
            "driverId": null,
            "bookingMode": "scheduled",
            "serviceType": "local",
            "tripType": "round_trip",
            "scheduledStartTime": "2026-09-26T10:00:00.000Z",
            "durationHours": 4,
            "returnDate": null,
            "pickupLocation": {
              "address": "123 Main St, City",
              "location": {
                "type": "Point",
                "coordinates": [77.209, 28.6139]
              }
            },
            "dropLocation": {
              "address": "456 Side St, City",
              "location": {
                "type": "Point",
                "coordinates": [77.219, 28.6239]
              }
            },
            "vehicleType": "sedan",
            "transmission": "manual",
            "vehicleOwnership": "user_vehicle",
            "vehicleId": null,
            "vehicleNumber": "",
            "numberOfPassengers": 1,
            "estimatedDistance": 0,
            "actualDistance": 0,
            "estimatedDuration": 0,
            "tripStartedAt": null,
            "tripCompletedAt": null,
            "pricingId": "6ab6668b9f3e3c8ba8df7597",
            "baseAmount": 900,
            "extraKmAmount": 0,
            "driverAllowance": 0,
            "driverFee": 750,
            "platformFee": 0,
            "taxAmount": 45,
            "discountAmount": 0,
            "totalAmount": 945,
            "paymentMethod": "online",
            "paymentStatus": "pending",
            "paymentId": "",
            "bookingStatus": "pending",
            "isUserRated": false,
            "isDriverRated": false,
            "cancelledBy": null,
            "cancellationReason": "",
            "cancelledAt": null,
            "userNotes": "",
            "adminNotes": "",
            "bookingId": "BKG-859805",
            "startOtp": "9779",
            "createdAt": "2026-10-13T10:11:48.628Z",
            "updatedAt": "2026-10-13T10:11:48.628Z",
            "__v": 0
          }
        ],
        "pagination": {
          "total": 16,
          "page": 1,
          "limit": 5,
          "totalPages": 4
        }
      }
    }''';

    final decoded = json.decode(jsonStr) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>;
    final parsed = BookingListResponseModel.fromJson(data);
    expect(parsed.bookings.length, 1);
    expect(parsed.pagination.total, 16);
    expect(parsed.bookings.first.id, 'BKG-859805');
    expect(parsed.bookings.first.statusGroup, 'Upcoming');
    expect(parsed.bookings.first.fare, 945.0);
  });

  test('parses single booking detail response json', () {
    const detailJsonStr = '''
    {
      "success": true,
      "data": {
        "booking": {
          "_id": "6ace03e49d216de59e600169",
          "userId": "6ab6427b440da47e3ac83da3",
          "driverId": null,
          "bookingMode": "scheduled",
          "serviceType": "local",
          "tripType": "round_trip",
          "scheduledStartTime": "2026-09-26T10:00:00.000Z",
          "durationHours": 4,
          "returnDate": null,
          "pickupLocation": {
            "address": "123 Main St, City",
            "location": {
              "type": "Point",
              "coordinates": [
                77.209,
                28.6139
              ]
            }
          },
          "dropLocation": {
            "address": "456 Side St, City",
            "location": {
              "type": "Point",
              "coordinates": [
                77.219,
                28.6239
              ]
            }
          },
          "vehicleType": "sedan",
          "transmission": "manual",
          "vehicleOwnership": "user_vehicle",
          "vehicleId": null,
          "vehicleNumber": "",
          "numberOfPassengers": 1,
          "estimatedDistance": 0,
          "actualDistance": 0,
          "estimatedDuration": 0,
          "tripStartedAt": null,
          "tripCompletedAt": null,
          "pricingId": "6ab6668b9f3e3c8ba8df7597",
          "baseAmount": 900,
          "extraKmAmount": 0,
          "driverAllowance": 0,
          "driverFee": 750,
          "platformFee": 0,
          "taxAmount": 45,
          "discountAmount": 0,
          "totalAmount": 945,
          "paymentMethod": "online",
          "paymentStatus": "pending",
          "paymentId": "",
          "bookingStatus": "pending",
          "isUserRated": false,
          "isDriverRated": false,
          "cancelledBy": null,
          "cancellationReason": "",
          "cancelledAt": null,
          "userNotes": "",
          "adminNotes": "",
          "bookingId": "BKG-859805",
          "startOtp": "9779",
          "createdAt": "2026-10-13T10:11:48.628Z",
          "updatedAt": "2026-10-13T10:11:48.628Z",
          "__v": 0
        }
      }
    }''';

    final decoded = json.decode(detailJsonStr) as Map<String, dynamic>;
    final detail = BookingDetailModel.fromJson(decoded);

    expect(detail.id, '6ace03e49d216de59e600169');
    expect(detail.bookingId, 'BKG-859805');
    expect(detail.displayBookingId, 'BKG-859805');
    expect(detail.bookingStatus, 'pending');
    expect(detail.displayStatus, 'Pending');
    expect(detail.startOtp, '9779');
    expect(detail.durationHours, 4);
    expect(detail.pickupLocation.address, '123 Main St, City');
    expect(detail.pickupLocation.longitude, 77.209);
    expect(detail.pickupLocation.latitude, 28.6139);
    expect(detail.dropLocation.address, '456 Side St, City');
    expect(detail.dropLocation.longitude, 77.219);
    expect(detail.dropLocation.latitude, 28.6239);
    expect(detail.vehicleType, 'sedan');
    expect(detail.transmission, 'manual');
    expect(detail.baseAmount, 900.0);
    expect(detail.driverFee, 750.0);
    expect(detail.taxAmount, 45.0);
    expect(detail.totalAmount, 945.0);
    expect(detail.paymentMethod, 'online');
    expect(detail.paymentStatus, 'pending');
  });
}
