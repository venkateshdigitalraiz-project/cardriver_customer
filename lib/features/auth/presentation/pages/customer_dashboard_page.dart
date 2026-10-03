import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../booking/data/datasources/booking_remote_datasource.dart';
import '../../../booking/data/repositories/booking_repository_impl.dart';
import '../../../booking/domain/usecases/calculate_fare_usecase.dart';
import '../../../booking/domain/usecases/check_booking_radius_usecase.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../drivers/data/datasources/driver_remote_datasource.dart';
import '../../../drivers/data/repositories/driver_repository_impl.dart';
import '../../../drivers/domain/entities/driver_search_type.dart';
import '../../../drivers/domain/usecases/get_drivers_usecase.dart';
import '../../../drivers/presentation/bloc/driver_list_bloc.dart';
import '../../../drivers/presentation/bloc/driver_list_event.dart';
import '../../../drivers/presentation/bloc/driver_list_state.dart';
import '../../../drivers/presentation/pages/driver_list_screen.dart';
import 'login_page.dart';

class CustomerDashboardPage extends StatelessWidget {
  final DriverSearchType searchType;

  const CustomerDashboardPage({
    super.key,
    this.searchType = DriverSearchType.local,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DriverListBloc>(
          create: (_) => DriverListBloc(
            getDriversUseCase: GetDriversUseCase(
              DriverRepositoryImpl(
                remoteDataSource: DriverRemoteDataSourceImpl(),
              ),
            ),
          )..add(FetchDriversEvent(searchType: searchType)),
        ),
        BlocProvider<BookingBloc>(
          create: (_) => BookingBloc(
            repository: BookingRepositoryImpl(
              remoteDataSource: BookingRemoteDataSourceImpl(dio: Dio()),
            ),
            calculateFareUseCase: CalculateFareUseCase(),
            checkBookingRadiusUseCase: CheckBookingRadiusUseCase(),
          )..add(const LoadRateConfigEvent()),
        ),
      ],
      child: _CustomerDashboardPageView(searchType: searchType),
    );
  }
}

class _CustomerDashboardPageView extends StatefulWidget {
  final DriverSearchType searchType;

  const _CustomerDashboardPageView({this.searchType = DriverSearchType.local});

  @override
  State<_CustomerDashboardPageView> createState() =>
      _CustomerDashboardPageViewState();
}

class _CustomerDashboardPageViewState
    extends State<_CustomerDashboardPageView> {
  int _selectedUsageIndex = 1; // Default to 6 Hrs
  TimeOfDay _fromTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _toTime = const TimeOfDay(hour: 13, minute: 0);
  final List<String> _selectedLanguages = [];
  bool _isLanguageDropdownOpen = false;
  bool _isSubmitted = false;
  int _selectedPricingModel = 0; // 0 = Fixed Package, 1 = Cost per Hour

  final TextEditingController _searchController = TextEditingController();

  static const List<String> _driverLanguages = [
    'English',
    'Hindi',
    'Kannada',
    'Telugu',
    'Tamil',
    "Bengali",
    "Gujarati",
    "Marathi",
    "Punjabi",
    "Odia",
    "Urdu",
    "Malayalam",
    "Other",
  ];

  static const List<String> _localUsageOptions = [
    '4\nHrs',
    '6\nHrs',
    '8\nHrs',
    '10\nHrs',
    '12\nHrs',
    '18\nHrs',
  ];

  static const List<String> _outstationUsageOptions = [
    '4\nHrs',
    '8\nHrs',
    '12\nHrs',
    '18\nHrs',
    '1\n day',
    '2\n day',
    '3\n day',
    '4\n day',
    '5\n day',
  ];

  List<String> get _currentUsageOptions =>
      widget.searchType == DriverSearchType.outstation
      ? _outstationUsageOptions
      : _localUsageOptions;

  int _getLocalHours(int index) {
    switch (index) {
      case 0:
        return 4;
      case 1:
        return 6;
      case 2:
        return 8;
      case 3:
        return 10;
      case 4:
        return 12;
      case 5:
        return 18;
      default:
        return 6;
    }
  }

  int _getOutstationDays(int index) {
    switch (index) {
      case 0:
        return 1; // 4 Hrs
      case 1:
        return 1; // 8 Hrs
      case 2:
        return 1; // 12 Hrs
      case 3:
        return 1; // 18 Hrs
      case 4:
        return 1; // 1 day
      case 5:
        return 2; // 2 days
      case 6:
        return 3; // 3 days
      case 7:
        return 4; // 4 days
      case 8:
        return 5; // 5 days
      default:
        return 1;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.searchType == DriverSearchType.outstation) {
      _selectedUsageIndex = 3; // Default to "1 day" for Outstation
    } else {
      _selectedUsageIndex = 1; // Default to "6 Hrs" for Local
    }
    _triggerFareCalculation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerFareCalculation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.searchType == DriverSearchType.outstation) {
        int days = _getOutstationDays(_selectedUsageIndex);
        context.read<BookingBloc>().add(
          CalculateOutstationBookingFareEvent(totalDays: days),
        );
      } else {
        int hours = _getLocalHours(_selectedUsageIndex);
        context.read<BookingBloc>().add(
          CalculateLocalBookingFareEvent(
            startHour: _fromTime.hour,
            startMinute: _fromTime.minute,
            durationHours: hours,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26262B),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.searchType == DriverSearchType.local
              ? 'Local Booking'
              : (widget.searchType == DriverSearchType.outstation
                    ? 'Outstation Booking'
                    : 'Drive You Daily'),
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DriverListBloc, DriverListState>(
        builder: (context, state) {
          return Column(
            children: [
              // Yellow Banner
              Container(
                width: double.infinity,
                color: const Color(0xFFFBE74D),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      size: 20,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text.rich(
                      TextSpan(
                        text: 'RoundTrip',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: ' - same pickup & drop location',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SEARCH TEXT FIELD & FILTER BUTTON AT THE VERY TOP OF PAGE
                      // _buildSearchAndFilterBar(context, state),
                      // const SizedBox(height: 20),
                      _buildSectionTitle(
                        'Select estimated usage',
                        required: true,
                      ),
                      const SizedBox(height: 8),
                      _buildUsageSelection(),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          _buildSectionTitle(
                            'Select pickup & drop-off time',
                            required: true,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTimeRangePicker(),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        'Set driver languages',
                        required: true,
                      ),
                      const SizedBox(height: 8),
                      _buildLanguageSelector(),
                      const SizedBox(height: 24),

                      // Fare Breakdown Card
                      _buildFareBreakdownCard(),
                      const SizedBox(height: 32),

                      // Show available drivers list with searching and filtering
                      // if (_isSubmitted) _buildAvailableDriversList(state),
                      // const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              if (!_isSubmitted)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedLanguages.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please select at least one driver language.',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _isSubmitted = true;
                          });
                          context.read<DriverListBloc>().add(
                            FetchDriversEvent(searchType: widget.searchType),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverListScreen(
                                searchType: widget.searchType,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF333333),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Continue to Schedule Driver',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool required = false}) {
    return Text.rich(
      TextSpan(
        text: title,
        style: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
        children: required
            ? [
                TextSpan(
                  text: '*',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildUsageSelection() {
    final options = _currentUsageOptions;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = index == _selectedUsageIndex;
          return Padding(
            padding: EdgeInsets.only(
              right: index == options.length - 1 ? 0 : 12.0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedUsageIndex = index;
                });
                _validateDuration();
                _triggerFareCalculation();
              },
              child: Container(
                width: 56,
                height: 64,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Colors.green
                        : Colors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? Colors.green.withValues(alpha: 0.05)
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  options[index],
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? Colors.black87 : Colors.black54,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _validateDuration() {
    double durationHours = 0.0;

    if (widget.searchType == DriverSearchType.outstation) {
      DateTime start = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _fromTime.hour,
        _fromTime.minute,
      );
      DateTime end = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _toTime.hour,
        _toTime.minute,
      );

      Duration diff = end.difference(start);
      if (!diff.isNegative) {
        durationHours = diff.inMinutes / 60.0;
      }
    } else {
      int fromMinutes = _fromTime.hour * 60 + _fromTime.minute;
      int toMinutes = _toTime.hour * 60 + _toTime.minute;

      if (toMinutes < fromMinutes) {
        toMinutes += 24 * 60;
      }

      int durationMinutes = toMinutes - fromMinutes;
      durationHours = durationMinutes / 60.0;
    }

    int estimatedUsageHours = widget.searchType == DriverSearchType.outstation
        ? (_getOutstationDays(_selectedUsageIndex) * 24)
        : _getLocalHours(_selectedUsageIndex);

    if (durationHours > estimatedUsageHours) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      String durationText = widget.searchType == DriverSearchType.outstation
          ? '${(durationHours / 24).toStringAsFixed(1)} days'
          : '${durationHours.toStringAsFixed(1)} hrs';

      String estimatedText = widget.searchType == DriverSearchType.outstation
          ? '${_getOutstationDays(_selectedUsageIndex)} days'
          : '$estimatedUsageHours hrs';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selected duration ($durationText) exceeds estimated usage ($estimatedText).',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

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
    return months[(month - 1) % 12];
  }

  Widget _buildTimeRangePicker() {
    final bool isOutstation = widget.searchType == DriverSearchType.outstation;

    return GestureDetector(
      onTap: () async {
        if (isOutstation) {
          final DateTimeRange? dateRange = await showDateRangePicker(
            context: context,
            initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
            firstDate: DateTime.now().subtract(const Duration(days: 1)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            helpText: 'SELECT OUTSTATION TRIP DATES',
          );

          if (dateRange != null) {
            if (!mounted) return;
            final TimeOfDay? fromPicked = await showTimePicker(
              context: context,
              initialTime: _fromTime,
              helpText: 'SELECT PICKUP TIME',
            );

            if (fromPicked != null) {
              if (!mounted) return;
              final TimeOfDay? toPicked = await showTimePicker(
                context: context,
                initialTime: _toTime,
                helpText: 'SELECT DROP-OFF TIME',
              );

              if (toPicked != null) {
                if (!mounted) return;
                setState(() {
                  _startDate = dateRange.start;
                  _endDate = dateRange.end;
                  _fromTime = fromPicked;
                  _toTime = toPicked;
                });

                int days = dateRange.duration.inDays;
                if (days < 1) days = 1;

                if (days == 1) {
                  _selectedUsageIndex = 3;
                } else if (days == 2) {
                  _selectedUsageIndex = 4;
                } else if (days == 3) {
                  _selectedUsageIndex = 5;
                } else if (days >= 4) {
                  _selectedUsageIndex = 6;
                }

                _validateDuration();
                _triggerFareCalculation();
              }
            }
          }
        } else {
          final TimeOfDay? fromPicked = await showTimePicker(
            context: context,
            initialTime: _fromTime,
            helpText: 'SELECT PICKUP TIME',
          );

          if (fromPicked != null) {
            if (!mounted) return;
            final TimeOfDay? toPicked = await showTimePicker(
              context: context,
              initialTime: _toTime,
              helpText: 'SELECT DROP-OFF TIME',
            );

            if (toPicked != null) {
              setState(() {
                _fromTime = fromPicked;
                _toTime = toPicked;
              });
              _validateDuration();
              _triggerFareCalculation();
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: isOutstation
                      ? '${_startDate.day} ${_monthName(_startDate.month)}, ${_fromTime.format(context)}'
                      : _fromTime.format(context),
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: '  to  ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: isOutstation
                          ? '${_endDate.day} ${_monthName(_endDate.month)}, ${_toTime.format(context)}'
                          : _toTime.format(context),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isOutstation ? Icons.calendar_month_rounded : Icons.access_time,
              color: Colors.black54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    String displayText = _selectedLanguages.isEmpty
        ? 'Choose'
        : _selectedLanguages.join(', ');

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isLanguageDropdownOpen = !_isLanguageDropdownOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isLanguageDropdownOpen
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        if (_isLanguageDropdownOpen)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Material(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: _driverLanguages.map((String language) {
                    return CheckboxListTile(
                      value: _selectedLanguages.contains(language),
                      title: Text(
                        language,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      onChanged: (bool? isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            _selectedLanguages.add(language);
                          } else {
                            _selectedLanguages.remove(language);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPricingOptionCard({
    required int value,
    required String title,
    required String priceText,
    required String subtitle,
    Widget? extraContent,
  }) {
    final bool isSelected = _selectedPricingModel == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPricingModel = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2F8F9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF266475)
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF266475).withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected
                  ? const Color(0xFF266475)
                  : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF266475)
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        priceText,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF266475),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                  if (extraContent != null) ...[
                    const SizedBox(height: 8),
                    extraContent,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareBreakdownCard() {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingFareCalculated) {
          final res = state.fareResult;

          Widget? fixedPackageExtra;
          if (res.searchType == DriverSearchType.outstation) {
            fixedPackageExtra = Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Color(0xFF266475),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Duration: ${res.totalDays} Day(s)',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          } else if (res.isCrossedDayNight) {
            fixedPackageExtra = Row(
              children: [
                const Icon(
                  Icons.nightlight_round,
                  size: 14,
                  color: Colors.orange,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Includes ${res.dayHours} Day hrs & ${res.nightHours} Night hrs',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            );
          }

          int estimatedUsageHours =
              res.searchType == DriverSearchType.outstation
              ? (_getOutstationDays(_selectedUsageIndex) * 24)
              : _getLocalHours(_selectedUsageIndex);

          double finalCustomerFare = res.customerFare;
          if (_selectedPricingModel == 1) {
            finalCustomerFare = 150.0 * estimatedUsageHours;
          } else if (_selectedPricingModel == 2) {
            finalCustomerFare = 180.0 * estimatedUsageHours;
          } else if (_selectedPricingModel == 3) {
            finalCustomerFare = 200.0 * estimatedUsageHours;
          } else if (_selectedPricingModel == 4) {
            finalCustomerFare = 250.0 * estimatedUsageHours;
          }

          double finalDriverEarnings = res.customerFare > 0
              ? (res.driverEarnings / res.customerFare) * finalCustomerFare
              : 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Select Pricing Model', required: true),
              const SizedBox(height: 12),

              _buildPricingOptionCard(
                value: 1,
                title: 'Basic Hourly',
                priceText: '₹150/hr',
                subtitle: 'Standard car & basic requirements',
              ),
              _buildPricingOptionCard(
                value: 2,
                title: 'Comfort Hourly',
                priceText: '₹180/hr',
                subtitle: 'Premium car & experienced driver',
              ),
              _buildPricingOptionCard(
                value: 3,
                title: 'Premium Hourly',
                priceText: '₹200/hr',
                subtitle: 'Luxury car & top-rated driver',
              ),
              _buildPricingOptionCard(
                value: 4,
                title: 'Elite Hourly',
                priceText: '₹250/hr',
                subtitle: 'Luxury SUV & professional chauffeur',
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(
                _selectedPricingModel == 0
                    ? 'Fixed Package Fare'
                    : 'Estimated Total Fare',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F8F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF266475).withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Customer Fare',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '₹${finalCustomerFare.toStringAsFixed(0)}',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF266475),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Driver Earnings',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          '₹${finalDriverEarnings.toStringAsFixed(0)}',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (fixedPackageExtra != null) ...[
                      const Divider(height: 16),
                      fixedPackageExtra,
                    ],
                  ],
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
