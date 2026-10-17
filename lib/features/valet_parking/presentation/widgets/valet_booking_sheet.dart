import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/valet_parking_location.dart';

class ValetBookingSheet extends StatefulWidget {
  final ValetParkingLocation location;
  final Function({
    required String locationId,
    required String vehicleNumber,
    required String vehicleModel,
    required int estimatedHours,
    String? specialInstructions,
  }) onConfirm;

  const ValetBookingSheet({
    super.key,
    required this.location,
    required this.onConfirm,
  });

  @override
  State<ValetBookingSheet> createState() => _ValetBookingSheetState();
}

class _ValetBookingSheetState extends State<ValetBookingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  int _selectedHours = 2;

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _vehicleModelController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF161D29) : Colors.white;
    final textCol = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF0F141D) : const Color(0xFFF8FAFC);
    final inputBorder = isDark ? const Color(0xFF263347) : const Color(0xFFE2E8F0);

    final totalFare = widget.location.ratePerHour * _selectedHours;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and Location Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_parking_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Valet Parking',
                          style: AppTypography.titleLarge.copyWith(
                            color: textCol,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.location.name,
                          style: AppTypography.bodySmall.copyWith(
                            color: subTextCol,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: subTextCol,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Vehicle Number Field
              Text(
                'Vehicle Plate Number',
                style: AppTypography.labelMedium.copyWith(
                  color: textCol,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _vehicleNumberController,
                style: TextStyle(
                  color: textCol,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
                textCapitalization: TextCapitalization.characters,
                decoration: _inputDecoration(
                  hint: 'e.g. MH 02 CZ 4488',
                  icon: Icons.pin_rounded,
                  fillColor: inputBg,
                  borderColor: inputBorder,
                ),
                validator: null,
              ),
              const SizedBox(height: 14),

              // Vehicle Model Field
              Text(
                'Vehicle Make & Model',
                style: AppTypography.labelMedium.copyWith(
                  color: textCol,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _vehicleModelController,
                style: TextStyle(color: textCol, fontWeight: FontWeight.w600),
                decoration: _inputDecoration(
                  hint: 'e.g. BMW 3 Series / Creta',
                  icon: Icons.directions_car_rounded,
                  fillColor: inputBg,
                  borderColor: inputBorder,
                ),
                validator: null,
              ),
              const SizedBox(height: 16),

              // Duration selector
              Text(
                'Estimated Parking Duration',
                style: AppTypography.labelMedium.copyWith(
                  color: textCol,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [1, 2, 3, 4, 6, 8].map((hours) {
                  final isSelected = _selectedHours == hours;
                  return ChoiceChip(
                    label: Text(
                      '$hours hr${hours > 1 ? 's' : ''}',
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? const Color(0xFF0B0E14) : textCol,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: inputBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : inputBorder,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedHours = hours);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Special Instructions (Optional)
              Text(
                'Special Instructions (Optional)',
                style: AppTypography.labelMedium.copyWith(
                  color: textCol,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _specialInstructionsController,
                style: TextStyle(color: textCol),
                decoration: _inputDecoration(
                  hint: 'e.g. Key drop at concierge desk, AC on before pickup',
                  icon: Icons.note_alt_outlined,
                  fillColor: inputBg,
                  borderColor: inputBorder,
                ),
              ),
              const SizedBox(height: 20),

              // Total Fare Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Total Fare',
                          style: AppTypography.bodySmall.copyWith(
                            color: subTextCol,
                          ),
                        ),
                        Text(
                          '₹${widget.location.ratePerHour.toInt()} x $_selectedHours hrs',
                          style: AppTypography.labelSmall.copyWith(
                            color: textCol,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${totalFare.toInt()}',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final vNum = _vehicleNumberController.text.trim();
                    final vModel = _vehicleModelController.text.trim();
                    widget.onConfirm(
                      locationId: widget.location.id,
                      vehicleNumber: vNum.isNotEmpty ? vNum : 'MH 02 CZ 4488',
                      vehicleModel:
                          vModel.isNotEmpty ? vModel : 'Standard Vehicle',
                      estimatedHours: _selectedHours,
                      specialInstructions: _specialInstructionsController
                              .text
                              .trim()
                              .isNotEmpty
                          ? _specialInstructionsController.text.trim()
                          : null,
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: const Text('Confirm Valet Booking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: const Color(0xFF0B0E14),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    textStyle: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color fillColor,
    required Color borderColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
