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
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

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
            final bookingData =
                state.bookingResponse?['booking'] ??
                state.bookingResponse?['data'];
            String? bookingId;
            if (bookingData is Map<String, dynamic>) {
              bookingId =
                  bookingData['bookingId']?.toString() ??
                  bookingData['_id']?.toString();
            }

            context.go(
              AppRoutes.bookingConfirmed,
              extra: {'request': state.request, 'bookingId': bookingId},
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

          final bool isLocal = !state.request.isOutstation;
          final bool isOneWay = !state.request.tripType.toLowerCase().contains(
            'round',
          );
          final bool isLocalOneWay = isLocal && isOneWay;
          final bool isOutstationOneWay =
              state.request.isOutstation && isOneWay;

          final num fareNum = (displayFare is num)
              ? displayFare
              : (num.tryParse(displayFare.toString()) ?? 0);

          final double tax = fareNum * 0.05;
          final double totalPrice = fareNum + tax;
          final formattedTax = tax % 1 == 0
              ? tax.toInt().toString()
              : tax.toStringAsFixed(2);
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
                  context.pop();
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
                            if (isLocalOneWay)
                              _buildReturnVehiclesSection(
                                context,
                                state,
                                isLocal: true,
                              ),
                            if (isOutstationOneWay)
                              _buildReturnVehiclesSection(
                                context,
                                state,
                                isLocal: false,
                              ),
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
                          onPressed:
                              (_isSubmitting ||
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

  Widget _buildReturnVehiclesSection(
    BuildContext context,
    BookingFlowState state, {
    required bool isLocal,
  }) {
    final charges = state.charges;
    final List<String> vehicles = isLocal
        ? (charges?.local.oneWay.returnVehicles ?? const [])
        : (charges?.outstation.oneWay.returnVehicles ?? const []);

    if (vehicles.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedVehicles = state.request.returnVehicles;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        isLocal ? Colors.orange.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isLocal
                        ? Icons.two_wheeler_rounded
                        : Icons.directions_bus_filled_rounded,
                    color:
                        isLocal ? Colors.orange.shade800 : Colors.blue.shade800,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLocal
                            ? 'Driver Return Travel'
                            : 'Driver Return Charges',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        isLocal
                            ? 'Select return transit conveyance for local one-way'
                            : 'Select return conveyance options for outstation one-way',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: vehicles.map((vehicle) {
                  final isSelected = selectedVehicles.contains(vehicle);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildVehicleCheckboxCard(
                      context,
                      vehicle: vehicle,
                      isSelected: isSelected,
                      isLocal: isLocal,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCheckboxCard(
    BuildContext context, {
    required String vehicle,
    required bool isSelected,
    required bool isLocal,
  }) {
    final Color activeBorderColor =
        isLocal ? Colors.orange.shade600 : Colors.blue.shade600;
    final Color activeBgColor = isSelected
        ? (isLocal ? Colors.orange.shade50 : Colors.blue.shade50)
        : Colors.white;
    final Color activeIndicatorColor =
        isLocal ? Colors.orange.shade800 : Colors.blue.shade800;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: activeBgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? activeBorderColor : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.05 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            context.read<BookingFlowBloc>().add(
              ToggleReturnVehicleEvent(vehicle),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? activeIndicatorColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isSelected
                          ? activeIndicatorColor
                          : Colors.grey.shade400,
                      width: 1.6,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Icon(
                  _getTransitIcon(vehicle),
                  size: 18,
                  color: isSelected
                      ? activeIndicatorColor
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  vehicle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTransitIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('bus')) {
      return Icons.directions_bus_filled_rounded;
    } else if (lower.contains('train')) {
      return Icons.train_rounded;
    } else if (lower.contains('cab') || lower.contains('taxi')) {
      return Icons.local_taxi_rounded;
    } else if (lower.contains('bike') ||
        lower.contains('rapido') ||
        lower.contains('two')) {
      return Icons.two_wheeler_rounded;
    } else {
      return Icons.directions_car_rounded;
    }
  }
}
