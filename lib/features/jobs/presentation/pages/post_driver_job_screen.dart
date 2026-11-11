// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_places_flutter/model/prediction.dart';
// import 'package:http/http.dart' as http;
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/place_address_utils.dart';
import '../../data/datasources/jobs_remote_datasource.dart';
import '../../data/repositories/jobs_repository_impl.dart';
import '../../domain/entities/create_job_request_entity.dart';
import '../../domain/usecases/post_user_job_usecase.dart';
import '../../../booking/domain/entities/charges_entity.dart';
import '../../../booking/domain/usecases/get_charges_usecase.dart';
import '../bloc/post_job_bloc.dart';
import '../bloc/post_job_event.dart';
import '../bloc/post_job_state.dart';

class PostDriverJobScreen extends StatelessWidget {
  const PostDriverJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostJobBloc(
        postUserJobUseCase: PostUserJobUseCase(
          JobsRepositoryImpl(remoteDataSource: JobsRemoteDataSourceImpl()),
        ),
        getChargesUseCase: context.read<GetChargesUseCase>(),
      )..add(const LoadJobChargesEvent()),
      child: const _PostDriverJobView(),
    );
  }
}

class _PostDriverJobView extends StatefulWidget {
  const _PostDriverJobView();

  @override
  State<_PostDriverJobView> createState() => _PostDriverJobViewState();
}

class _PostDriverJobViewState extends State<_PostDriverJobView> {
  // static const String _apiKey = 'AIzaSyCvBoWiQ4Eh2UQusV3fjjfVeqyf6HiAO2s';
  final _formKey = GlobalKey<FormState>();
  final FocusNode _locationFocus = FocusNode();

  late final TextEditingController _titleController;
  late final TextEditingController _salaryController;
  late final TextEditingController _locationController;
  late final TextEditingController _joiningDateDisplayController;
  late final TextEditingController _descriptionController;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String _selectedJobType = 'full_time';
  int? _selectedTotalHours;
  int? _minMonthlySalary;
  String _selectedPaymentMethod = 'razorpay';
  final double _paymentFee = 499.0;

  final Map<String, String> _jobTypeLabels = {
    'full_time': 'Full Time',
    'part_time': 'Part Time',
    'contract': 'Contractual',
    'temporary': 'Temporary / On-Demand',
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: 'Private Chauffeur for Luxury Sedan',
    );
    _salaryController = TextEditingController();
    _locationController = TextEditingController(
      text: 'Jubilee Hills, Hyderabad',
    );
    _descriptionController = TextEditingController(
      text:
          'Looking for a punctual, well-mannered private driver for daily office commute and occasional weekend family trips. Minimum 3 years experience with luxury sedans.',
    );
    _joiningDateDisplayController = TextEditingController();
    _updateDateDisplay();
  }

  void _updateDateDisplay() {
    final d = _selectedDate.day.toString().padLeft(2, '0');
    final m = _monthName(_selectedDate.month);
    final y = _selectedDate.year.toString();
    _joiningDateDisplayController.text = '$d $m $y';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    _locationFocus.dispose();
    _joiningDateDisplayController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  double? _selectedLat;
  double? _selectedLng;

  Future<void> _openMapPicker() async {
    _locationFocus.unfocus();
    final result = await context.push<PlaceAddressDetails>(
      AppRoutes.locationPickerMap,
      extra: {'initialLat': _selectedLat, 'initialLng': _selectedLng},
    );

    if (result != null) {
      _selectedLat = result.lat;
      _selectedLng = result.lng;
      final display = result.formattedAddress.isNotEmpty
          ? result.formattedAddress
          : result.shortAddress;
      _locationController.text = display;
      setState(() {});
      _formKey.currentState?.validate();
    }
  }

  // Future<void> _onSuggestionSelected(Prediction prediction) async {
  //   _locationFocus.unfocus();
  //   final description = prediction.description ?? '';
  //   if (description.isNotEmpty) {
  //     _locationController.text = description;
  //     setState(() {});
  //   }

  //   if (prediction.placeId == null || prediction.placeId!.isEmpty) return;

  //   try {
  //     final url = Uri.parse(
  //       'https://maps.googleapis.com/maps/api/place/details/json'
  //       '?place_id=${prediction.placeId!}'
  //       '&fields=formatted_address,geometry'
  //       '&key=$_apiKey',
  //     );
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['status'] == 'OK' && data['result'] != null) {
  //         final formatted =
  //             data['result']['formatted_address']?.toString() ?? '';
  //         if (formatted.isNotEmpty) {
  //           _locationController.text = formatted;
  //           setState(() {});
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('⚠️ Error fetching place details: $e');
  //   }
  // }

  Future<void> _pickJoiningDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
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
      setState(() {
        _selectedDate = picked;
        _updateDateDisplay();
      });
      _formKey.currentState?.validate();
    }
  }

  void _submitJob() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please search and select a work location'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedTotalHours == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select working hours from the dropdown'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final salary = int.tryParse(
      _salaryController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    if (salary == null || salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid monthly salary'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_minMonthlySalary != null && salary < _minMonthlySalary!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Monthly salary cannot be less than ₹$_minMonthlySalary for $_selectedTotalHours hours/day',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Format ISO 8601 UTC timestamp: e.g. 2026-12-01T00:00:00.000Z
    final isoDate = DateTime.utc(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    ).toIso8601String();

    final orderId =
        'order_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final paymentId =
        'pay_${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';

    final request = CreateJobRequestEntity(
      title: _titleController.text.trim(),
      monthlySalary: salary,
      totalHours: _selectedTotalHours!,
      joiningDate: isoDate,
      description: _descriptionController.text.trim(),
      paymentAmount: _paymentFee,
      paymentMethod: _selectedPaymentMethod,
      razorpayOrderId: orderId,
      razorpayPaymentId: paymentId,
      razorpaySignature: 'sig_${DateTime.now().millisecondsSinceEpoch}',
      location: _locationController.text.trim(),
      jobType: _selectedJobType,
    );

    context.read<PostJobBloc>().add(SubmitJobPostEvent(request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Post a Driver Job',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: BlocConsumer<PostJobBloc, PostJobState>(
        listenWhen: (previous, current) =>
            previous.isFailure != current.isFailure ||
            (current.errorMessage != null &&
                previous.errorMessage != current.errorMessage),
        listener: (context, state) {
          if (state.isFailure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
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
          if (state.isSuccess) {
            return _buildSuccessView(context, state);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Banner Card
                  _buildHeaderBanner(),
                  const SizedBox(height: 20),

                  // Job Title
                  _buildSectionHeader('Job Title *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: _inputDecoration(
                      hint: 'e.g. Private Chauffeur for Luxury Sedan',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter job title'
                        : null,
                  ),
                  const SizedBox(height: 18),

                  // Job Type Selection
                  _buildSectionHeader('Job Type *'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _jobTypeLabels.entries.map((entry) {
                      final isSelected = _selectedJobType == entry.key;
                      return ChoiceChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected)
                            setState(() => _selectedJobType = entry.key);
                        },
                        selectedColor: const Color(0xFF1E3A8A),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                        backgroundColor: Colors.white,
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
                  const SizedBox(height: 18),

                  // Working Hours Dropdown
                  _buildSectionHeader('Working Hours (Per Day) *'),
                  const SizedBox(height: 6),
                  _buildHoursDropdown(state),
                  const SizedBox(height: 18),

                  // Monthly Salary & Joining Date Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Monthly Salary
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Monthly Salary (₹) *'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _salaryController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              decoration: _inputDecoration(
                                hint: _minMonthlySalary != null
                                    ? 'Min ₹$_minMonthlySalary'
                                    : 'Select hours first',
                                prefixText: '₹ ',
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter salary';
                                }
                                final salary = int.tryParse(
                                  v.trim().replaceAll(RegExp(r'[^0-9]'), ''),
                                );
                                if (salary == null) {
                                  return 'Numbers only';
                                }
                                if (_minMonthlySalary != null &&
                                    salary < _minMonthlySalary!) {
                                  return 'Minimum ₹$_minMonthlySalary required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Joining Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Joining Date *'),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _pickJoiningDate,
                              borderRadius: BorderRadius.circular(12),
                              child: IgnorePointer(
                                child: TextFormField(
                                  controller: _joiningDateDisplayController,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                  decoration: _inputDecoration(
                                    hint: 'DD MMM YYYY',
                                    prefixIcon: Icons.calendar_month_rounded,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Location
                  _buildSectionHeader('Work Location / Area *'),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _openMapPicker,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _locationController.text.isNotEmpty
                                  ? _locationController.text
                                  : 'Search for a location on map…',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: _locationController.text.isNotEmpty
                                    ? const Color(0xFF0F172A)
                                    : AppColors.textSecondary,
                                fontWeight: _locationController.text.isNotEmpty
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_locationController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _locationController.clear();
                                setState(() {});
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.textSecondary,
                                  size: 18,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.map_rounded,
                              color: Color(0xFF1E3A8A),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Description
                  _buildSectionHeader('Job Description & Requirements *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: _inputDecoration(
                      hint:
                          'Describe daily duties, preferred working hours, vehicle type, and experience requirements...',
                      prefixIcon: null,
                    ),
                    validator: (v) => (v == null || v.trim().length < 10)
                        ? 'Please write at least 10 characters'
                        : null,
                  ),
                  const SizedBox(height: 22),

                  // Payment & Verification Fee Card
                  // _buildPaymentSummaryCard(),
                  // const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _submitJob,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state.isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Posting Job...',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flash_on_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Post Job Requirement',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reach Verified Drivers Instantly',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Your requirement is broadcasted to verified, licensed drivers matching your location & vehicle.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildPaymentSummaryCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: const Color(0xFFE2E8F0)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.03),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Row(
  //               children: [
  //                 const Icon(
  //                   Icons.shield_rounded,
  //                   color: Color(0xFF10B981),
  //                   size: 18,
  //                 ),
  //                 const SizedBox(width: 6),
  //                 Text(
  //                   'Listing & Verification Fee',
  //                   style: AppTypography.titleMedium.copyWith(
  //                     fontSize: 13.5,
  //                     fontWeight: FontWeight.w700,
  //                     color: const Color(0xFF0F172A),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const Text(
  //               '₹499',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w900,
  //                 color: Color(0xFF1E3A8A),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const Divider(height: 18, color: Color(0xFFF1F5F9)),
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFFEFF6FF),
  //                 borderRadius: BorderRadius.circular(6),
  //               ),
  //               child: const Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(
  //                     Icons.payment_rounded,
  //                     size: 13,
  //                     color: Color(0xFF2563EB),
  //                   ),
  //                   SizedBox(width: 4),
  //                   Text(
  //                     'Razorpay Secured',
  //                     style: TextStyle(
  //                       fontSize: 11,
  //                       fontWeight: FontWeight.bold,
  //                       color: Color(0xFF1D4ED8),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             const Spacer(),
  //             const Text(
  //               'Includes 30 days active listing',
  //               style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildHoursDropdown(PostJobState state) {
    if (state.isLoadingCharges) {
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading hours...',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final options = state.permanentJobs;

    final effectiveValue =
        options.any((o) => o.totalHours == _selectedTotalHours)
        ? _selectedTotalHours
        : null;

    return DropdownButtonFormField<int>(
      value: effectiveValue,
      decoration: _inputDecoration(
        hint: options.isEmpty
            ? 'No hours available'
            : 'Select Hours (e.g. 8, 10)',
        prefixIcon: Icons.schedule_rounded,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF0F172A),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      validator: (v) => v == null ? 'Please select hours' : null,
      items: options.map((job) {
        return DropdownMenuItem<int>(
          value: job.totalHours,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${job.totalHours} Hours',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        );
      }).toList(),
      onChanged: (newHours) {
        if (newHours == null) return;
        setState(() {
          _selectedTotalHours = newHours;
          final matched = options.where((j) => j.totalHours == newHours);
          if (matched.isNotEmpty) {
            final job = matched.first;
            _minMonthlySalary = job.monthlySalary;
            _salaryController.text = job.monthlySalary.toString();
          }
          _formKey.currentState?.validate();
        });
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
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
      fillColor: Colors.white,
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

  Widget _buildSuccessView(BuildContext context, PostJobState state) {
    final jobData = state.response?.data;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF059669),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Job Posted Successfully!',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.response?.message ??
                    'Your job requirement is now active and live for verified drivers.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 20),

              if (jobData != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
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
                              color: Color(0xFF64748B),
                              fontSize: 12,
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
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D4ED8),
                                fontSize: 12,
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
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              jobData.title,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Monthly Salary',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '₹${jobData.monthlySalary}/mo',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              jobData.location,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<PostJobBloc>().add(
                          const ResetJobPostEvent(),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Post Another'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
