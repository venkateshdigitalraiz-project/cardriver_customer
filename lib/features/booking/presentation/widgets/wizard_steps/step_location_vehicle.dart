import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/widgets/publish_location_field.dart';
import '../../bloc/flow/booking_flow_bloc.dart';
import '../../bloc/flow/booking_flow_event.dart';
import '../../bloc/flow/booking_flow_state.dart';

class StepLocationVehicle extends StatefulWidget {
  const StepLocationVehicle({super.key});

  @override
  State<StepLocationVehicle> createState() => _StepLocationVehicleState();
}

class _StepLocationVehicleState extends State<StepLocationVehicle> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();
  String _selectedTripType = 'One Way';

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingFlowBloc, BookingFlowState>(
      builder: (context, state) {
        if (_pickupController.text.isEmpty &&
            state.request.pickupAddress != null) {
          _pickupController.text = state.request.pickupAddress!;
        }
        if (_dropController.text.isEmpty && state.request.dropAddress != null) {
          _dropController.text = state.request.dropAddress!;
        }
        if (state.request.isOutstation && _selectedTripType != 'Outstation') {
          _selectedTripType = 'Outstation';
        } else if (!state.request.isOutstation &&
            _selectedTripType == 'Outstation') {
          _selectedTripType = 'One Way';
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Rapido Style Unified Location Picker
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Trip Type Selector (One Way, Round Trip, Outstation, Daily)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TripTypeTabBar(
                            selectedType: _selectedTripType,
                            onChanged: (type) {
                              setState(() {
                                _selectedTripType = type;
                                _pickupController.clear();
                                _dropController.clear();
                              });
                              context.read<BookingFlowBloc>().add(
                                ClearLocationEvent(),
                              );

                              if (type == 'Outstation') {
                                context.read<BookingFlowBloc>().add(
                                  const UpdateTripTypeEvent(true),
                                );
                              } else {
                                context.read<BookingFlowBloc>().add(
                                  const UpdateTripTypeEvent(false),
                                );
                              }
                            },
                          ),
                        ),

                        Row(
                          children: [
                            // Timeline Indicators
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.green,
                                    size: 14,
                                  ),
                                  _selectedTripType == 'Round Trip'
                                      ? Container(
                                          height: 48,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.swap_vert,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                        )
                                      : Container(
                                          width: 2,
                                          height: 48,
                                          color: Colors.grey.shade300,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                        ),
                                  const Icon(
                                    Icons.square,
                                    color: Colors.red,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                            // Text Fields
                            Expanded(
                              child: Column(
                                children: [
                                  PublishLocationField(
                                    label: 'Pickup Location',
                                    showLabel: false,
                                    showShadow: false,
                                    backgroundColor: Colors.transparent,
                                    hint: 'Search pickup location',
                                    controller: _pickupController,
                                    onChanged: (val) {},
                                    onAddressDetailsSelected: (details) {
                                      context.read<BookingFlowBloc>().add(
                                        UpdateLocationVehicleEvent(
                                          pickupAddress: details.shortAddress,
                                          pickupLat: details.lat,
                                          pickupLng: details.lng,
                                        ),
                                      );
                                    },
                                  ),
                                  Divider(
                                    height: 1,
                                    indent: 0,
                                    endIndent: 16,
                                    color: Colors.grey.shade300,
                                  ),
                                  PublishLocationField(
                                    label: _selectedTripType == 'Round Trip'
                                        ? 'Drop Location & Return'
                                        : 'Drop Location (Optional)',
                                    showLabel: false,
                                    showShadow: false,
                                    backgroundColor: Colors.transparent,
                                    hint: _selectedTripType == 'Round Trip'
                                        ? 'Search drop & return location'
                                        : 'Search drop location',
                                    controller: _dropController,
                                    onChanged: (val) {},
                                    onAddressDetailsSelected: (details) {
                                      context.read<BookingFlowBloc>().add(
                                        UpdateLocationVehicleEvent(
                                          dropAddress: details.shortAddress,
                                          dropLat: details.lat,
                                          dropLng: details.lng,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Car for Today
              const Text(
                'Car for Today',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () =>
                          _showCarEditDialog(context, state.request.carType),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.directions_car,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      state.request.carType.isEmpty
                                          ? 'Car Name'
                                          : state.request.carType,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _showTransmissionEditDialog(
                          context,
                          state.request.transmission,
                          state.request.vehicleCategory,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.settings,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      state.request.transmission.isEmpty
                                          ? 'Manual'
                                          : state.request.transmission,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCarEditDialog(
    BuildContext context,
    String currentCarType,
  ) async {
    String name = currentCarType;
    String color = '';

    if (currentCarType.contains('(') && currentCarType.endsWith(')')) {
      final start = currentCarType.lastIndexOf('(');
      name = currentCarType.substring(0, start).trim();
      color = currentCarType
          .substring(start + 1, currentCarType.length - 1)
          .trim();
    }

    final TextEditingController nameController = TextEditingController(
      text: name,
    );
    final TextEditingController colorController = TextEditingController(
      text: color,
    );

    final String? newCar = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 24, right: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter Car Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 16),
                    const Text(
                      'Car Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'e.g. Honda City',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Car Color',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: colorController,
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'e.g. White',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        String finalName = nameController.text.trim();
                        String finalColor = colorController.text.trim();
                        if (finalName.isNotEmpty && finalColor.isNotEmpty) {
                          finalName = '$finalName ($finalColor)';
                        } else if (finalName.isEmpty) {
                          finalName = 'Hatchback';
                        }
                        Navigator.pop(context, finalName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF101018),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF101018),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (newCar != null && newCar.isNotEmpty && context.mounted) {
      context.read<BookingFlowBloc>().add(
        UpdateLocationVehicleEvent(carType: newCar),
      );
    }
  }

  Future<void> _showTransmissionEditDialog(
    BuildContext context,
    String currentTransmission,
    String currentCategory,
  ) async {
    String transmission = currentTransmission.isEmpty ? 'Manual' : currentTransmission;
    String category = currentCategory.isEmpty ? 'Hatchback' : currentCategory;

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 24, right: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Select Transmission & Car Type',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Colors.black12),
                        const SizedBox(height: 16),
                        const Text(
                          'Transmission',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildTransmissionPill(
                              title: 'Manual',
                              isSelected: transmission == 'Manual',
                              onTap: () => setState(() => transmission = 'Manual'),
                            ),
                            const SizedBox(width: 12),
                            _buildTransmissionPill(
                              title: 'Automatic',
                              isSelected: transmission == 'Automatic',
                              onTap: () => setState(() => transmission = 'Automatic'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Car Type',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCarTypeCard(
                              title: 'Hatchback',
                              isSelected: category == 'Hatchback',
                              onTap: () => setState(() => category = 'Hatchback'),
                            ),
                            _buildCarTypeCard(
                              title: 'Sedan',
                              isSelected: category == 'Sedan',
                              onTap: () => setState(() => category = 'Sedan'),
                            ),
                            _buildCarTypeCard(
                              title: 'SUV',
                              isSelected: category == 'SUV',
                              onTap: () => setState(() => category = 'SUV'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, {
                              'transmission': transmission,
                              'category': category,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF101018),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF101018),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null && context.mounted) {
      context.read<BookingFlowBloc>().add(
        UpdateLocationVehicleEvent(
          transmission: result['transmission'],
          vehicleCategory: result['category'],
        ),
      );
    }
  }

  Widget _buildTransmissionPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.green.shade100 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) const Icon(Icons.check, color: Colors.green, size: 16),
              if (isSelected) const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black87 : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarTypeCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.green.shade100 : Colors.grey.shade200,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 40,
                      color: isSelected ? Colors.green : Colors.grey.shade400,
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.black87 : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingTypeSwitch extends StatelessWidget {
  final bool isOutstation;
  final ValueChanged<bool> onChanged;

  const BookingTypeSwitch({
    super.key,
    required this.isOutstation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isOutstation),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Stack(
          children: [
            // Sliding background
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: isOutstation
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Labels
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 14,
                        color: isOutstation
                            ? Colors.grey.shade600
                            : Colors.black87,
                        fontWeight: isOutstation
                            ? FontWeight.w500
                            : FontWeight.w600,
                      ),
                      child: const Text('Local'),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 14,
                        color: isOutstation
                            ? Colors.black87
                            : Colors.grey.shade600,
                        fontWeight: isOutstation
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      child: const Text('Outstation'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TripTypeTabBar extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const TripTypeTabBar({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTab('One Way', Icons.trending_flat, selectedType == 'One Way'),
          _buildTab('Round Trip', Icons.sync_alt, selectedType == 'Round Trip'),
          _buildTab(
            'Outstation',
            Icons.edit_road,
            selectedType == 'Outstation',
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => onChanged(title),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.green : Colors.black54,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black87 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.transparent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
