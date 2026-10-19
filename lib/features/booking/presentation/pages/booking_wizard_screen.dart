import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/flow/booking_flow_bloc.dart';
import '../bloc/flow/booking_flow_event.dart';
import '../bloc/flow/booking_flow_state.dart';
import '../widgets/wizard_steps/step_location_vehicle.dart';
import '../widgets/booking_map_preview.dart';
import '../../domain/usecases/submit_booking_usecase.dart';
import '../../domain/usecases/get_charges_usecase.dart';
import '../../domain/usecases/calculate_fare_usecase.dart';
import 'booking_confirmed_screen.dart';

class BookingWizardScreen extends StatefulWidget {
  final String initialTripType;
  const BookingWizardScreen({super.key, this.initialTripType = 'Local'});

  @override
  State<BookingWizardScreen> createState() => _BookingWizardScreenState();
}

class _BookingWizardScreenState extends State<BookingWizardScreen> {
  bool _isSubmitting = false;
  DateTime? _lastSubmitTime;

  @override
  Widget build(BuildContext context) {
    final bool isOutstation = widget.initialTripType.toLowerCase().contains(
      'outstation',
    );
    final String journeyType =
        widget.initialTripType.toLowerCase().contains('round')
        ? 'Round Trip'
        : 'One Way';

    return BlocProvider(
      create: (context) =>
          BookingFlowBloc(
              submitBookingUseCase: context.read<SubmitBookingUseCase>(),
              getChargesUseCase: context.read<GetChargesUseCase>(),
              calculateFareUseCase: context.read<CalculateFareUseCase>(),
            )
            ..add(
              UpdateTripTypeEvent(
                isOutstation: isOutstation,
                tripType: journeyType,
              ),
            )
            ..add(const FetchChargesEvent()),
      child: BlocConsumer<BookingFlowBloc, BookingFlowState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == BookingFlowStatus.error ||
              state.status == BookingFlowStatus.success) {
            if (_isSubmitting) {
              setState(() {
                _isSubmitting = false;
              });
            }
          }

          if (state.status == BookingFlowStatus.success) {
            final bookingBloc = context.read<BookingFlowBloc>();
            final bookingData = state.bookingResponse?['booking'] ??
                state.bookingResponse?['data'];
            String? bookingId;
            if (bookingData is Map<String, dynamic>) {
              bookingId = bookingData['bookingId']?.toString() ??
                  bookingData['_id']?.toString();
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: bookingBloc,
                  child: BookingConfirmedScreen(
                    request: state.request,
                    bookingId: bookingId,
                  ),
                ),
              ),
            );
          } else if (state.status == BookingFlowStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final baseFare = state.request.estimatedFare?.round() ?? 0;
          final responseData = state.bookingResponse;
          final displayFare =
              responseData?['totalAmount'] ??
              responseData?['price'] ??
              (responseData?['data'] is Map
                  ? responseData!['data']['totalAmount']
                  : null) ??
              (responseData?['data'] is Map
                  ? responseData!['data']['price']
                  : null) ??
              (responseData?['booking'] is Map
                  ? responseData!['booking']['totalAmount']
                  : null) ??
              (responseData?['booking'] is Map
                  ? responseData!['booking']['price']
                  : null) ??
              baseFare;

          final num fareNum = (displayFare is num)
              ? displayFare
              : (num.tryParse(displayFare.toString()) ?? 0);
          final double tax = fareNum * 0.05;
          final double totalPrice = fareNum + tax;
          final formattedTax =
              tax % 1 == 0 ? tax.toInt().toString() : tax.toStringAsFixed(2);
          final formattedTotalPrice = totalPrice % 1 == 0
              ? totalPrice.toInt().toString()
              : totalPrice.toStringAsFixed(2);

          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              backgroundColor: const Color(
                0xFF1E1E24,
              ), // Dark header like DriveU
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                '${state.request.isOutstation ? 'Outstation' : 'Local'} • ${state.request.tripType}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),
            body: Stack(
              children: [
                // 1. Map Background
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: const BookingMapPreview(),
                ),

                // 2. Scrollable Form Panel
                DraggableScrollableSheet(
                  initialChildSize: 0.65,
                  minChildSize: 0.4,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            const StepLocationVehicle(),
                            if (displayFare > 0 ||
                                state.status == BookingFlowStatus.success)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Estimated Total Price',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            '₹ $displayFare',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Tax (5%)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            '₹ $formattedTax',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        height: 20,
                                        thickness: 1,
                                        color: Colors.green.shade200,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total Price',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            '₹ $formattedTotalPrice',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 150),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // 3. Sticky Bottom Checkout Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Offers and Cash
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_offer,
                                  color: Colors.green.shade700,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Select Offers',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.money,
                                    color: Colors.green.shade700,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pay after your trip',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        'Cash',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_up, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: (_isSubmitting ||
                                  state.status == BookingFlowStatus.submitting)
                              ? null
                              : () {
                                  final now = DateTime.now();
                                  if (_lastSubmitTime != null &&
                                      now.difference(_lastSubmitTime!) <
                                          const Duration(milliseconds: 1500)) {
                                    return;
                                  }
                                  _lastSubmitTime = now;

                                  debugPrint(
                                    '🚗 User clicked: Confirm Booking',
                                  );

                                  final request = state.request;
                                  String? validationError;

                                  if (request.pickupAddress == null ||
                                      request.pickupLat == null ||
                                      request.pickupLng == null) {
                                    validationError =
                                        'Please select a pickup location';
                                  } else if (request.dropAddress == null ||
                                      request.dropLat == null ||
                                      request.dropLng == null) {
                                    validationError =
                                        'Please select a drop location';
                                  } else if (request.scheduleDate == null ||
                                      request.scheduleHour == null ||
                                      request.scheduleMinute == null) {
                                    validationError =
                                        'Please select a schedule time';
                                  }

                                  if (validationError != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(validationError),
                                        backgroundColor: Colors.red.shade600,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _isSubmitting = true;
                                  });

                                  context.read<BookingFlowBloc>().add(
                                    SubmitBookingEvent(),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E1E24),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Confirm Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (state.status == BookingFlowStatus.submitting)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
