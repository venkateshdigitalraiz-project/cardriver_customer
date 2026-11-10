import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/driver_job_item.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class PostDriverJobCard extends StatefulWidget {
  final bool isBottomSheet;

  const PostDriverJobCard({super.key, this.isBottomSheet = false});

  @override
  State<PostDriverJobCard> createState() => _PostDriverJobCardState();
}

class _PostDriverJobCardState extends State<PostDriverJobCard> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _jobTitleController;
  late final TextEditingController _salaryController;
  late final TextEditingController _workingHoursController;
  late final TextEditingController _dutyDaysController;
  late final TextEditingController _locationAddressController;
  late final TextEditingController _cityController;
  late final TextEditingController _startDateController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _contactPhoneController;
  late final TextEditingController _descriptionController;

  String _selectedJobType = 'Full-Time';
  String _selectedVehicleType = 'Sedan';
  String _selectedTransmission = 'Manual';
  String _selectedExperience = '2+ Years';

  final List<String> _jobTypes = [
    'Full-Time',
    'Part-Time',
    'Monthly Contract',
    'On-Demand',
  ];

  final List<String> _vehicleTypes = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Luxury',
    'Any Vehicle',
  ];

  final List<String> _transmissions = [
    'Manual',
    'Automatic',
    'Both / Any',
  ];

  final List<String> _experienceLevels = [
    '1-2 Years',
    '2+ Years',
    '3-5 Years',
    '5+ Years',
  ];

  @override
  void initState() {
    super.initState();
    _jobTitleController =
        TextEditingController(text: 'Personal Car Driver');
    _salaryController = TextEditingController(text: '22,000');
    _workingHoursController =
        TextEditingController(text: '9:00 AM - 6:00 PM (9 Hours)');
    _dutyDaysController = TextEditingController(text: '6 Days / Week');
    _locationAddressController = TextEditingController();
    _cityController = TextEditingController(text: 'Bengaluru');
    _startDateController = TextEditingController();
    _contactPersonController = TextEditingController();
    _contactPhoneController = TextEditingController();
    _descriptionController = TextEditingController(
      text: 'Need a disciplined, police-verified driver with clean driving record.',
    );

    // Pre-populate today's or tomorrow's date for start date
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final y = tomorrow.year.toString().padLeft(4, '0');
    final m = tomorrow.month.toString().padLeft(2, '0');
    final d = tomorrow.day.toString().padLeft(2, '0');
    _startDateController.text = '$y-$m-$d';
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _salaryController.dispose();
    _workingHoursController.dispose();
    _dutyDaysController.dispose();
    _locationAddressController.dispose();
    _cityController.dispose();
    _startDateController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    DateTime initialDate = now.add(const Duration(days: 1));
    final existingText = _startDateController.text.trim();
    if (existingText.isNotEmpty) {
      final parsed = DateTime.tryParse(existingText);
      if (parsed != null && !parsed.isBefore(now.subtract(const Duration(days: 1)))) {
        initialDate = parsed;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
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
      _startDateController.text = '$y-$m-$d';
      _formKey.currentState?.validate();
      setState(() {});
    }
  }

  void _submitJob() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final jobItem = DriverJobItem(
      jobTitle: _jobTitleController.text.trim(),
      jobType: _selectedJobType,
      vehicleType: _selectedVehicleType,
      transmission: _selectedTransmission,
      salary: _salaryController.text.trim().startsWith('₹')
          ? _salaryController.text.trim()
          : '₹${_salaryController.text.trim()}/mo',
      workingHours: _workingHoursController.text.trim(),
      dutyDays: _dutyDaysController.text.trim(),
      locationAddress: _locationAddressController.text.trim().isNotEmpty
          ? _locationAddressController.text.trim()
          : '${_cityController.text.trim()} Central',
      city: _cityController.text.trim(),
      coordinates: const [77.5946, 12.9716],
      startDate: _startDateController.text.trim(),
      experienceRequired: _selectedExperience,
      contactPerson: _contactPersonController.text.trim().isNotEmpty
          ? _contactPersonController.text.trim()
          : 'Customer',
      contactPhone: _contactPhoneController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    context.read<HomeBloc>().add(SubmitDriverJobEvent(jobItem));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          previous.driverJobSubmitSuccess != current.driverJobSubmitSuccess ||
          (current.driverJobErrorMessage != null &&
              previous.driverJobErrorMessage != current.driverJobErrorMessage),
      listener: (context, state) {
        if (state.driverJobSubmitSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.driverJobResponse?.message ??
                          'Driver job requirement posted successfully!',
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else if (state.driverJobErrorMessage != null &&
            state.driverJobErrorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.driverJobErrorMessage!),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.driverJobSubmitSuccess && state.driverJobResponse != null) {
          return _buildSuccessCard(context, state);
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.work_rounded,
                          color: Color(0xFF1E3A8A),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Post for Driver Job',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Hire verified permanent or contract drivers',
                              style: AppTypography.bodySmall.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isBottomSheet)
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.grey.shade600,
                          splashRadius: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Job Title Field
                  _buildLabel('Job Title / Role Requirement *'),
                  TextFormField(
                    controller: _jobTitleController,
                    decoration: _buildInputDecoration(
                      hint: 'e.g. Personal Car Driver, Office Chauffeur',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter job title' : null,
                  ),
                  const SizedBox(height: 16),

                  // Employment Type Selector
                  _buildLabel('Employment Type *'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _jobTypes.map((type) {
                      final isSelected = _selectedJobType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedJobType = type);
                        },
                        selectedColor: const Color(0xFF1E3A8A),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Type & Transmission Row
                  Row(
                    children: [
                      // Vehicle Type Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Vehicle Type *'),
                            DropdownButtonFormField<String>(
                              value: _selectedVehicleType,
                              decoration: _buildInputDecoration(
                                hint: 'Vehicle',
                                prefixIcon: Icons.directions_car_rounded,
                              ),
                              items: _vehicleTypes.map((v) {
                                return DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                    v,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedVehicleType = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Transmission Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Transmission *'),
                            DropdownButtonFormField<String>(
                              value: _selectedTransmission,
                              decoration: _buildInputDecoration(
                                hint: 'Transmission',
                                prefixIcon: Icons.settings_suggest_rounded,
                              ),
                              items: _transmissions.map((t) {
                                return DropdownMenuItem(
                                  value: t,
                                  child: Text(
                                    t,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedTransmission = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Monthly Budget / Salary & Experience Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Monthly Salary / Budget *'),
                            TextFormField(
                              controller: _salaryController,
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration(
                                hint: 'e.g. 20000',
                                prefixText: '₹ ',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter salary'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Min. Experience *'),
                            DropdownButtonFormField<String>(
                              value: _selectedExperience,
                              decoration: _buildInputDecoration(
                                hint: 'Experience',
                                prefixIcon: Icons.military_tech_rounded,
                              ),
                              items: _experienceLevels.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedExperience = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Working Hours & Duty Days Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Working Hours *'),
                            TextFormField(
                              controller: _workingHoursController,
                              decoration: _buildInputDecoration(
                                hint: '9 AM - 6 PM',
                                prefixIcon: Icons.schedule_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Duty Days *'),
                            TextFormField(
                              controller: _dutyDaysController,
                              decoration: _buildInputDecoration(
                                hint: '6 Days/Week',
                                prefixIcon: Icons.calendar_today_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location & City
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Work Location / Area *'),
                            TextFormField(
                              controller: _locationAddressController,
                              decoration: _buildInputDecoration(
                                hint: 'Area, Landmark or Address',
                                prefixIcon: Icons.location_on_rounded,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter work area'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('City *'),
                            TextFormField(
                              controller: _cityController,
                              decoration: _buildInputDecoration(
                                hint: 'City',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'City'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Expected Joining Date & Contact Phone
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Expected Start Date *'),
                            InkWell(
                              onTap: _pickStartDate,
                              borderRadius: BorderRadius.circular(12),
                              child: IgnorePointer(
                                child: TextFormField(
                                  controller: _startDateController,
                                  decoration: _buildInputDecoration(
                                    hint: 'YYYY-MM-DD',
                                    prefixIcon: Icons.event_available_rounded,
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? 'Select date'
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Contact Phone *'),
                            TextFormField(
                              controller: _contactPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: _buildInputDecoration(
                                hint: 'Phone number',
                                prefixIcon: Icons.phone_rounded,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter phone'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Requirements & Notes
                  _buildLabel('Additional Job Requirements / Notes'),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: _buildInputDecoration(
                      hint: 'e.g. Police verified, knows city shortcuts, punctual...',
                      prefixIcon: Icons.notes_rounded,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isSubmittingDriverJob ? null : _submitJob,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state.isSubmittingDriverJob
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Post Job Requirement',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessCard(BuildContext context, HomeState state) {
    final jobData = state.driverJobResponse?.data;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF059669),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Job Posted Successfully!',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your driver job requirement has been broadcasted to verified drivers.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          if (jobData != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Job ID',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          jobData.jobId,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Role',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        jobData.jobTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Salary / Budget',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        jobData.salary,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<HomeBloc>()
                        .add(ResetDriverJobSubmissionEvent());
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  child: const Text('Post Another'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.isBottomSheet) {
                      Navigator.of(context).pop();
                    } else {
                      context
                          .read<HomeBloc>()
                          .add(ResetDriverJobSubmissionEvent());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    IconData? prefixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF94A3B8),
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18, color: const Color(0xFF64748B))
          : null,
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
      ),
    );
  }
}

