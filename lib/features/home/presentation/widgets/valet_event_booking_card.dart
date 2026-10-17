import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/valet_event_booking_item.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class _CityLocationItem {
  final String name;
  final String state;
  final double lng;
  final double lat;
  final String? placeId;

  const _CityLocationItem({
    required this.name,
    required this.state,
    required this.lng,
    required this.lat,
    this.placeId,
  });

  String get fullDescription => state.isNotEmpty ? '$name, $state' : name;
}

class ValetEventBookingCard extends StatefulWidget {
  final bool isBottomSheet;

  const ValetEventBookingCard({super.key, this.isBottomSheet = false});

  @override
  State<ValetEventBookingCard> createState() => _ValetEventBookingCardState();
}

class _ValetEventBookingCardState extends State<ValetEventBookingCard> {
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers pre-populated with the exact sample data
  late final TextEditingController _eventNameController;
  late final TextEditingController _eventTypeController;
  late final TextEditingController _eventDateController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;
  late final TextEditingController _hoursController;
  late final TextEditingController _personController;
  late final TextEditingController _venueNameController;
  late final TextEditingController _coordinatesController;
  late final TextEditingController _cityLocationController;
  late final TextEditingController _locationAddressController;
  late final TextEditingController _addressController;
  late final TextEditingController _specialInstructionsController;
  late final TextEditingController _paymentMethodController;

  List<_CityLocationItem> _citySuggestions = [];
  bool _isSearchingCities = false;

  @override
  void initState() {
    super.initState();
    // Start with all textfields clean and empty as requested
    _eventNameController = TextEditingController();
    _eventTypeController = TextEditingController();
    _eventDateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    _hoursController = TextEditingController();
    _personController = TextEditingController();
    _venueNameController = TextEditingController();
    _coordinatesController = TextEditingController();
    _cityLocationController = TextEditingController();
    _locationAddressController = TextEditingController();
    _addressController = TextEditingController();
    _specialInstructionsController = TextEditingController();
    _paymentMethodController = TextEditingController();
  }

  void _clearAllFields() {
    _eventNameController.clear();
    _eventTypeController.clear();
    _eventDateController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _hoursController.clear();
    _personController.clear();
    _venueNameController.clear();
    _coordinatesController.clear();
    _cityLocationController.clear();
    _locationAddressController.clear();
    _addressController.clear();
    _specialInstructionsController.clear();
    _paymentMethodController.clear();
    _citySuggestions = [];
    _isSearchingCities = false;
    setState(() {});
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventTypeController.dispose();
    _eventDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _hoursController.dispose();
    _personController.dispose();
    _venueNameController.dispose();
    _coordinatesController.dispose();
    _cityLocationController.dispose();
    _locationAddressController.dispose();
    _addressController.dispose();
    _specialInstructionsController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  Future<void> _pickEventDate() async {
    final now = DateTime.now();
    DateTime initialDate = now.add(const Duration(days: 1));
    final existingText = _eventDateController.text.trim();
    if (existingText.isNotEmpty) {
      final parsed = DateTime.tryParse(existingText);
      if (parsed != null &&
          !parsed.isBefore(now.subtract(const Duration(days: 1)))) {
        initialDate = parsed;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFB800),
              onPrimary: Colors.black87,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      _eventDateController.text = '$y-$m-$d';
      _formKey.currentState?.validate();
      setState(() {});
    }
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    final controller = isStartTime ? _startTimeController : _endTimeController;
    TimeOfDay initialTime = isStartTime
        ? const TimeOfDay(hour: 18, minute: 0)
        : const TimeOfDay(hour: 23, minute: 0);

    final currentText = controller.text.trim();
    if (currentText.isNotEmpty) {
      try {
        final parts = currentText.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0].trim());
          final m = int.tryParse(parts[1].trim());
          if (h != null && m != null) {
            initialTime = TimeOfDay(hour: h, minute: m);
          }
        }
      } catch (_) {}
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFB800),
              onPrimary: Colors.black87,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      controller.text = '$hourStr:$minuteStr';

      _updateHoursFromTimes();
      _formKey.currentState?.validate();
      setState(() {});
    }
  }

  void _updateHoursFromTimes() {
    final startText = _startTimeController.text.trim();
    final endText = _endTimeController.text.trim();
    if (startText.isNotEmpty && endText.isNotEmpty) {
      try {
        final sParts = startText.split(':');
        final eParts = endText.split(':');
        if (sParts.length >= 2 && eParts.length >= 2) {
          final sHour = int.tryParse(sParts[0].trim());
          final sMin = int.tryParse(sParts[1].trim());
          final eHour = int.tryParse(eParts[0].trim());
          final eMin = int.tryParse(eParts[1].trim());
          if (sHour != null && sMin != null && eHour != null && eMin != null) {
            var diffMinutes = (eHour * 60 + eMin) - (sHour * 60 + sMin);
            if (diffMinutes < 0) {
              diffMinutes += 24 * 60;
            }
            final calculatedHours = (diffMinutes / 60).round();
            if (calculatedHours > 0) {
              _hoursController.text = calculatedHours.toString();
            }
          }
        }
      } catch (_) {}
    }
  }

  void _submitForm() {
    // 1. Form validation trigger
    final isFormValid = _formKey.currentState?.validate() ?? false;

    final eventName = _eventNameController.text.trim();
    final eventType = _eventTypeController.text.trim();
    final rawEventDate = _eventDateController.text.trim();
    final personStr = _personController.text.trim();
    final startTimeStr = _startTimeController.text.trim();
    final endTimeStr = _endTimeController.text.trim();
    final venueName = _venueNameController.text.trim();
    final addressText = _addressController.text.trim();
    final searchCityText = _cityLocationController.text.trim();
    final coordText = _coordinatesController.text.trim();

    // 2. Validate all 9 required fields
    if (!isFormValid ||
        eventName.isEmpty ||
        eventType.isEmpty ||
        rawEventDate.isEmpty ||
        personStr.isEmpty ||
        startTimeStr.isEmpty ||
        endTimeStr.isEmpty ||
        venueName.isEmpty ||
        addressText.isEmpty ||
        searchCityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please fill in all required fields before submitting.',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // 3. Validate Person (staff count) is a valid positive number
    final staffCount = int.tryParse(personStr);
    if (staffCount == null || staffCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please enter a valid staff count greater than 0.',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // 4. Validate and collect Location Coordinates
    List<double> coordinates = [];
    if (coordText.isNotEmpty) {
      try {
        final parts = coordText.split(',');
        if (parts.length >= 2) {
          final lng = double.tryParse(parts[0].trim());
          final lat = double.tryParse(parts[1].trim());
          if (lng != null && lat != null) {
            coordinates = [lng, lat];
          }
        }
      } catch (_) {}
    }

    if (coordinates.isEmpty && searchCityText.isNotEmpty) {
      // Check if user typed numeric coordinates into the search text field
      if (searchCityText.contains(',')) {
        try {
          final parts = searchCityText.split(',');
          if (parts.length >= 2) {
            final lng = double.tryParse(parts[0].trim());
            final lat = double.tryParse(parts[1].trim());
            if (lng != null && lat != null) {
              coordinates = [lng, lat];
            }
          }
        } catch (_) {}
      }
    }

    if (coordinates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.location_off_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please select a valid city or place from the suggestions to resolve coordinates.',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // 5. Construct ISO/UTC Event Date payload
    String eventDatePayload = DateTime.now().toUtc().toIso8601String();
    if (rawEventDate.contains('T')) {
      eventDatePayload = rawEventDate;
    } else {
      try {
        final timeParts = startTimeStr.split(':');
        final hour = timeParts.isNotEmpty
            ? int.tryParse(timeParts[0]) ?? 18
            : 18;
        final minute = timeParts.length > 1
            ? int.tryParse(timeParts[1]) ?? 0
            : 0;
        final dateParts = rawEventDate.split('-');
        if (dateParts.length == 3) {
          final y = int.tryParse(dateParts[0]) ?? DateTime.now().year;
          final m = int.tryParse(dateParts[1]) ?? DateTime.now().month;
          final d = int.tryParse(dateParts[2]) ?? DateTime.now().day;
          final dt = DateTime.utc(y, m, d, hour, minute);
          eventDatePayload = dt.toIso8601String();
        } else {
          eventDatePayload = '${rawEventDate}T18:00:00.000Z';
        }
      } catch (_) {
        eventDatePayload = '${rawEventDate}T18:00:00.000Z';
      }
    }

    // 6. Calculate hours
    int calculatedHours = int.tryParse(_hoursController.text.trim()) ?? 1;
    if (calculatedHours <= 0) {
      calculatedHours = 1;
    }

    final locationAddressText =
        _locationAddressController.text.trim().isNotEmpty
        ? _locationAddressController.text.trim()
        : addressText;

    final booking = ValetEventBookingItem(
      eventName: eventName,
      eventType: eventType,
      eventDate: eventDatePayload,
      startTime: startTimeStr,
      endTime: endTimeStr,
      hours: calculatedHours,
      person: staffCount,
      venueName: venueName,
      coordinates: coordinates,
      locationAddress: locationAddressText,
      address: addressText,
      specialInstructions: _specialInstructionsController.text.trim(),
      paymentMethod: _paymentMethodController.text.trim().isNotEmpty
          ? _paymentMethodController.text.trim()
          : 'online',
    );

    context.read<HomeBloc>().add(SubmitValetEventBooking(booking));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.valetSubmitSuccess && state.valetBookingResponse != null) {
          final res = state.valetBookingResponse!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${res.message}! Booking ID: ${res.data.bookingId}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );

          // Close current screen / bottom sheet immediately
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          // Reset submission state in BLoC
          context.read<HomeBloc>().add(ResetValetBookingSubmission());
        } else if (state.valetErrorMessage != null &&
            state.valetErrorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Submission notice: ${state.valetErrorMessage}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isBottomSheet ? 0 : 20,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFFFB800).withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: const Color(0xFFFFB800).withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar with Luxury Gradient Accent
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFBE74D).withValues(alpha: 0.22),
                            const Color(0xFFFFB800).withValues(alpha: 0.12),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBE74D),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_parking_rounded,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Valet Event Booking',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          if (widget.isBottomSheet) ...[
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.black54,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Card Form Fields Container
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Event Name
                          _buildLabeledTextField(
                            label: 'Event Name',
                            controller: _eventNameController,
                            icon: Icons.celebration_rounded,
                            hintText: 'Enter event name',
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter event name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // 2. Event Type & Payment Method Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildLabeledTextField(
                                  label: 'Event Type',
                                  controller: _eventTypeController,
                                  icon: Icons.category_rounded,
                                  hintText: 'e.g. wedding, corporate',
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please enter event type';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Expanded(
                              //   child: _buildLabeledTextField(
                              //     label: 'Payment Method',
                              //     controller: _paymentMethodController,
                              //     icon: Icons.payment_rounded,
                              //     hintText: 'e.g. online, cash',
                              //     isOptional: true,
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // 3. Event Date (Calendar Date Picker)
                          Row(
                            children: [
                              Expanded(
                                child: _buildLabeledTextField(
                                  label: 'Event Date',
                                  controller: _eventDateController,
                                  icon: Icons.calendar_month_rounded,
                                  hintText: 'Tap to select date (YYYY-MM-DD)',
                                  readOnly: true,
                                  onTap: _pickEventDate,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please select event date';
                                    }
                                    return null;
                                  },
                                  suffixIcon:
                                      _eventDateController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear_rounded,
                                            size: 16,
                                            color: Colors.black45,
                                          ),
                                          onPressed: () {
                                            _eventDateController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 18,
                                            color: Color(0xFFD97706),
                                          ),
                                          onPressed: _pickEventDate,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildLabeledTextField(
                                  label: 'Person (Staff count)',
                                  controller: _personController,
                                  icon: Icons.people_alt_rounded,
                                  hintText: '4',
                                  keyboardType: TextInputType.number,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please enter staff count';
                                    }
                                    final count = int.tryParse(val.trim());
                                    if (count == null || count <= 0) {
                                      return 'Enter valid count (> 0)';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // 4. Start Time & End Time Row (Time Pickers)
                          Row(
                            children: [
                              Expanded(
                                child: _buildLabeledTextField(
                                  label: 'Start Time',
                                  controller: _startTimeController,
                                  icon: Icons.schedule_rounded,
                                  hintText: 'HH:mm (e.g. 18:00)',
                                  readOnly: true,
                                  onTap: () => _pickTime(isStartTime: true),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please select start time';
                                    }
                                    return null;
                                  },
                                  suffixIcon:
                                      _startTimeController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear_rounded,
                                            size: 16,
                                            color: Colors.black45,
                                          ),
                                          onPressed: () {
                                            _startTimeController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.access_time_rounded,
                                            size: 18,
                                            color: Color(0xFFD97706),
                                          ),
                                          onPressed: () =>
                                              _pickTime(isStartTime: true),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildLabeledTextField(
                                  label: 'End Time',
                                  controller: _endTimeController,
                                  icon: Icons.timelapse_rounded,
                                  hintText: 'HH:mm (e.g. 23:00)',
                                  readOnly: true,
                                  onTap: () => _pickTime(isStartTime: false),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please select end time';
                                    }
                                    return null;
                                  },
                                  suffixIcon: _endTimeController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear_rounded,
                                            size: 16,
                                            color: Colors.black45,
                                          ),
                                          onPressed: () {
                                            _endTimeController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.access_time_rounded,
                                            size: 18,
                                            color: Color(0xFFD97706),
                                          ),
                                          onPressed: () =>
                                              _pickTime(isStartTime: false),
                                        ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // 6. Venue Name
                          _buildLabeledTextField(
                            label: 'Venue Name',
                            controller: _venueNameController,
                            icon: Icons.apartment_rounded,
                            hintText: 'Venue or Hotel Name',
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter venue name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // 7. Location Coordinates via PublishLocationField
                          _buildLocationCoordinatesField(),
                          const SizedBox(height: 14),

                          // 9. Address
                          _buildLabeledTextField(
                            label: 'Address',
                            controller: _addressController,
                            icon: Icons.pin_drop_rounded,
                            hintText: 'Full booking address',
                            maxLines: 2,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // 10. Special Instructions
                          _buildLabeledTextField(
                            label: 'Special Instructions',
                            controller: _specialInstructionsController,
                            icon: Icons.receipt_long_rounded,
                            hintText: 'Special instructions for valet staff',
                            maxLines: 2,
                            isOptional: true,
                          ),
                          const SizedBox(height: 20),

                          // 11. Add Event Booking Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: state.isSubmittingValet
                                  ? null
                                  : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFBE74D),
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(
                                  color: Colors.black.withValues(alpha: 0.08),
                                ),
                              ),
                              child: state.isSubmittingValet
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Sending to API...',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.add_circle_rounded,
                                          color: Colors.black87,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Add Event Booking',
                                          style: AppTypography.labelLarge
                                              .copyWith(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          // Quick Clear Fields action
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton.icon(
                              onPressed: _clearAllFields,
                              icon: const Icon(
                                Icons.cleaning_services_outlined,
                                size: 14,
                                color: Colors.black54,
                              ),
                              label: Text(
                                'Clear all fields',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _searchCities(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _citySuggestions = [];
        _isSearchingCities = false;
      });
      return;
    }

    setState(() {
      _isSearchingCities = true;
    });

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(q)}'
        '&types=(cities)'
        '&components=country:in'
        '&key=AIzaSyCvBoWiQ4Eh2UQusV3fjjfVeqyf6HiAO2s',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['predictions'] != null) {
          final List predictions = data['predictions'];
          final List<_CityLocationItem> apiMatches = [];
          for (final p in predictions) {
            final desc = p['description']?.toString() ?? '';
            final mainText =
                p['structured_formatting']?['main_text']?.toString() ?? desc;
            final secText =
                p['structured_formatting']?['secondary_text']?.toString() ?? '';
            final placeId = p['place_id']?.toString();

            apiMatches.add(
              _CityLocationItem(
                name: mainText,
                state: secText,
                placeId: placeId,
                lng: 0.0,
                lat: 0.0,
              ),
            );
          }
          if (mounted &&
              _cityLocationController.text.trim().toLowerCase() ==
                  q.toLowerCase()) {
            setState(() {
              _citySuggestions = apiMatches;
              _isSearchingCities = false;
            });
            return;
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isSearchingCities = false;
      });
    }
  }

  Future<void> _selectCitySuggestion(_CityLocationItem item) async {
    double lng = item.lng;
    double lat = item.lat;

    if ((lng == 0.0 || lat == 0.0) && item.placeId != null) {
      try {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=${item.placeId}'
          '&fields=geometry,formatted_address'
          '&key=AIzaSyCvBoWiQ4Eh2UQusV3fjjfVeqyf6HiAO2s',
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final loc = data['result']?['geometry']?['location'];
          if (loc != null) {
            lat = double.tryParse(loc['lat'].toString()) ?? 0.0;
            lng = double.tryParse(loc['lng'].toString()) ?? 0.0;
          }
        }
      } catch (_) {}
    }

    _cityLocationController.text = item.fullDescription;
    if (lng != 0.0 && lat != 0.0) {
      _coordinatesController.text = '$lng, $lat';
    }

    if (_locationAddressController.text.trim().isEmpty) {
      _locationAddressController.text = item.fullDescription;
    }
    if (_addressController.text.trim().isEmpty) {
      _addressController.text = item.fullDescription;
    }
    if (_venueNameController.text.trim().isEmpty) {
      _venueNameController.text = item.name;
    }

    if (mounted) {
      _formKey.currentState?.validate();
      setState(() {
        _citySuggestions = [];
        _isSearchingCities = false;
      });
      FocusScope.of(context).unfocus();
    }
  }

  Widget _buildLocationCoordinatesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Label
        Row(
          children: [
            const Icon(
              Icons.explore_rounded,
              size: 14,
              color: Color(0xFFD97706), // Warm amber accent
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Location Coordinates (City / Place)',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                    fontSize: 12,
                  ),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // In-place City Search Input (pure text field, no map)
        TextFormField(
          controller: _cityLocationController,
          style: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          onChanged: (val) {
            final trimmed = val.trim();
            if (trimmed.isEmpty) {
              _coordinatesController.clear();
              setState(() {
                _citySuggestions = [];
              });
            } else if (trimmed.contains(',') &&
                RegExp(r'^[0-9.,\s\-]+$').hasMatch(trimmed)) {
              _coordinatesController.text = trimmed;
              setState(() {
                _citySuggestions = [];
              });
            } else {
              _searchCities(trimmed);
            }
          },
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please enter or search city / place';
            }
            if (_coordinatesController.text.trim().isEmpty) {
              final trimmed = val.trim();
              if (trimmed.contains(',') &&
                  RegExp(r'^[0-9.,\s\-]+$').hasMatch(trimmed)) {
                return null;
              }
              return 'Please select a city from suggestions to resolve coordinates';
            }
            return null;
          },
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search city name (e.g. Bengaluru, Mumbai, Delhi)',
            hintStyle: AppTypography.bodySmall.copyWith(
              color: Colors.black38,
              fontSize: 12,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: const Icon(
              Icons.location_city_rounded,
              color: Color(0xFFD97706),
              size: 18,
            ),
            suffixIcon: _isSearchingCities
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  )
                : (_cityLocationController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            size: 16,
                            color: Colors.black45,
                          ),
                          onPressed: () {
                            _cityLocationController.clear();
                            _coordinatesController.clear();
                            setState(() {
                              _citySuggestions = [];
                            });
                          },
                        )
                      : null),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFFB800),
                width: 1.6,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3366),
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3366),
                width: 1.6,
              ),
            ),
            errorStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF3366),
            ),
          ),
        ),

        // Suggestions Dropdown List displayed directly when entering text
        if (_citySuggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _citySuggestions.length,
                separatorBuilder: (ctx, i) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
                itemBuilder: (context, index) {
                  final item = _citySuggestions[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectCitySuggestion(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFBE74D,
                                ).withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.state.isNotEmpty) ...[
                                    const SizedBox(height: 1),
                                    Text(
                                      item.state,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: const Color(0xFF64748B),
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (item.lat != 0.0 && item.lng != 0.0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${item.lng.toStringAsFixed(2)}, ${item.lat.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],

        // Visual feedback chip showing the resolved coordinates
        if (_coordinatesController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.gps_fixed_rounded,
                  size: 13,
                  color: Color(0xFF047857),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Resolved Coordinates: ${_coordinatesController.text.trim()}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF047857),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    bool isOptional = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Label
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: const Color(0xFFD97706), // Warm amber accent
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                    fontSize: 12,
                  ),
                  children: [
                    if (isOptional)
                      TextSpan(
                        text: ' (Optional)',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.black38,
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Text Field with validation styling
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          validator:
              validator ??
              (!isOptional
                  ? (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter $label';
                      }
                      return null;
                    }
                  : null),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: AppTypography.bodySmall.copyWith(
              color: Colors.black38,
              fontSize: 12,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines > 1 ? 12 : 11,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFFB800),
                width: 1.6,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3366),
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3366),
                width: 1.6,
              ),
            ),
            errorStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF3366),
            ),
          ),
        ),
      ],
    );
  }
}
