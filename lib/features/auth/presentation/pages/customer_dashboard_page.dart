import 'package:flutter/material.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

class CustomerDashboardPage extends StatefulWidget {
  const CustomerDashboardPage({super.key});

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  int _selectedUsageIndex = 1; // Default to 6 Hrs
  TimeOfDay _fromTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _toTime = const TimeOfDay(hour: 13, minute: 0);
  List<String> _selectedLanguages = [];
  bool _isLanguageDropdownOpen = false;
  bool _isSubmitted = false;

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

  // static const List<String> _dummyLocations = [
  //   'Meenakshi Mall, Bannerghatta Road, Bangalore',
  //   'MG Road, Shivaji Nagar, Bangalore',
  //   'Mekhri Circle, Jayamahal, Bangalore',
  //   'Marathahalli, Outer Ring Road, Bangalore',
  //   'Majestic, Kempegowda Bus Station, Bangalore',
  //   'Malleswaram, 18th Cross, Bangalore',
  //   'Manyata Tech Park, Nagavara, Bangalore',
  //   '21, 1st Cross Rd, KHB Colony, 7th Block, Koramangala',
  // ];

  final List<String> _usageOptions = [
    '4\nHrs',
    '6\nHrs',
    '8\nHrs',
    '10\nHrs',
    '12\nHrs',
    "1\n day",
    "2\n day",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26262B), // Dark app bar from reference
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Drive You Daily',
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
        ],
      ),
      body: Column(
        children: [
          // Yellow Banner
          Container(
            width: double.infinity,
            color: const Color(0xFFFBE74D), // Yellow banner
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month, size: 20, color: Colors.green),
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
                  // _buildSectionTitle('Choose pick-up location', required: true),
                  // const SizedBox(height: 8),
                  // _buildLocationInput(),
                  // const SizedBox(height: 24),
                  _buildSectionTitle('Select estimated usage', required: true),
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
                  // _buildSectionTitle('Your car details', required: true),
                  // const SizedBox(height: 8),
                  // Row(
                  //   children: [
                  //     Expanded(child: _buildDropdown('Manual')),
                  //     const SizedBox(width: 16),
                  //     Expanded(child: _buildDropdown('Hatchback')),
                  //   ],
                  // ),
                  // const SizedBox(height: 24),
                  _buildSectionTitle('Set driver languages', required: true),
                  const SizedBox(height: 8),
                  _buildLanguageSelector(),
                  const SizedBox(height: 32),

                  // Show available drivers list
                  if (_isSubmitted) _buildAvailableDriversList(),
                  const SizedBox(height: 40),
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

  // Widget _buildLocationInput() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //     child: Autocomplete<String>(
  //       optionsBuilder: (TextEditingValue textEditingValue) {
  //         if (textEditingValue.text.isEmpty) {
  //           return const Iterable<String>.empty();
  //         }
  //         return _dummyLocations.where((String option) {
  //           return option.toLowerCase().contains(
  //             textEditingValue.text.toLowerCase(),
  //           );
  //         });
  //       },
  //       fieldViewBuilder:
  //           (
  //             BuildContext context,
  //             TextEditingController textEditingController,
  //             FocusNode focusNode,
  //             VoidCallback onFieldSubmitted,
  //           ) {
  //             return Row(
  //               children: [
  //                 Expanded(
  //                   child: TextField(
  //                     controller: textEditingController,
  //                     focusNode: focusNode,
  //                     decoration: const InputDecoration(
  //                       hintText: 'Search location...',
  //                       border: InputBorder.none,
  //                       isDense: true,
  //                     ),
  //                     style: AppTypography.bodyMedium,
  //                   ),
  //                 ),
  //                 ValueListenableBuilder<TextEditingValue>(
  //                   valueListenable: textEditingController,
  //                   builder: (context, value, child) {
  //                     if (value.text.isEmpty) {
  //                       return const SizedBox.shrink();
  //                     }
  //                     return IconButton(
  //                       icon: const Icon(
  //                         Icons.close,
  //                         size: 20,
  //                         color: Colors.black54,
  //                       ),
  //                       onPressed: () {
  //                         textEditingController.clear();
  //                         focusNode.unfocus();
  //                       },
  //                       padding: EdgeInsets.zero,
  //                       constraints: const BoxConstraints(),
  //                     );
  //                   },
  //                 ),
  //               ],
  //             );
  //           },
  //       optionsViewBuilder:
  //           (
  //             BuildContext context,
  //             AutocompleteOnSelected<String> onSelected,
  //             Iterable<String> options,
  //           ) {
  //             return Align(
  //               alignment: Alignment.topLeft,
  //               child: Material(
  //                 elevation: 4.0,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: ConstrainedBox(
  //                   constraints: BoxConstraints(
  //                     maxHeight: 250,
  //                     maxWidth: MediaQuery.of(context).size.width - 40,
  //                   ),
  //                   child: ListView.separated(
  //                     padding: EdgeInsets.zero,
  //                     shrinkWrap: true,
  //                     itemCount: options.length,
  //                     separatorBuilder: (context, index) =>
  //                         const Divider(height: 1, color: Colors.black12),
  //                     itemBuilder: (BuildContext context, int index) {
  //                       final String option = options.elementAt(index);
  //                       return InkWell(
  //                         onTap: () {
  //                           onSelected(option);
  //                         },
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(16.0),
  //                           child: Row(
  //                             children: [
  //                               const Icon(
  //                                 Icons.location_on_outlined,
  //                                 color: Colors.grey,
  //                                 size: 20,
  //                               ),
  //                               const SizedBox(width: 12),
  //                               Expanded(
  //                                 child: Text(
  //                                   option,
  //                                   style: AppTypography.bodyMedium,
  //                                   maxLines: 2,
  //                                   overflow: TextOverflow.ellipsis,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //     ),
  //   );
  // }

  Widget _buildUsageSelection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_usageOptions.length, (index) {
          final isSelected = index == _selectedUsageIndex;
          return Padding(
            padding: EdgeInsets.only(
              right: index == _usageOptions.length - 1 ? 0 : 12.0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedUsageIndex = index;
                });
                _validateDuration();
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
                  _usageOptions[index],
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
    int fromMinutes = _fromTime.hour * 60 + _fromTime.minute;
    int toMinutes = _toTime.hour * 60 + _toTime.minute;

    if (toMinutes < fromMinutes) {
      toMinutes += 24 * 60;
    }

    int durationMinutes = toMinutes - fromMinutes;
    double durationHours = durationMinutes / 60.0;

    int estimatedUsageHours = (_selectedUsageIndex * 2) + 4;

    if (durationHours > estimatedUsageHours) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selected duration (${durationHours.toStringAsFixed(1)} hrs) exceeds estimated usage ($estimatedUsageHours hrs).',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildTimeRangePicker() {
    return GestureDetector(
      onTap: () async {
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
            Text.rich(
              TextSpan(
                text: _fromTime.format(context),
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
                  TextSpan(text: _toTime.format(context)),
                ],
              ),
            ),
            const Icon(Icons.access_time, color: Colors.black54, size: 20),
          ],
        ),
      ),
    );
  }

  // Widget _buildDropdown(String text) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           text,
  //           style: AppTypography.bodyMedium.copyWith(color: Colors.black87),
  //         ),
  //         const Icon(Icons.arrow_drop_down, color: Colors.black54),
  //       ],
  //     ),
  //   );
  // }

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

  Widget _buildAvailableDriversList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Available Drivers'),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(Icons.person, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Driver ${index + 1}',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '4.${8 - index}',
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '• 15 mins away',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${800 + (index * 150)}',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
