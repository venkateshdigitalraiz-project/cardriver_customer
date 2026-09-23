import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/driver_filter_options.dart';
import '../../domain/entities/driver_search_type.dart';

class DriverFilterBottomSheet extends StatefulWidget {
  final DriverFilterOptions currentFilter;
  final DriverSearchType searchType;

  const DriverFilterBottomSheet({
    super.key,
    required this.currentFilter,
    this.searchType = DriverSearchType.local,
  });

  @override
  State<DriverFilterBottomSheet> createState() =>
      _DriverFilterBottomSheetState();
}

class _DriverFilterBottomSheetState extends State<DriverFilterBottomSheet> {
  late DistanceFilterOption _selectedDistance;
  late PriceSortOption _selectedPriceSort;
  late bool _nearByOnly;

  @override
  void initState() {
    super.initState();
    _selectedDistance = widget.currentFilter.distanceFilter;
    _selectedPriceSort = widget.currentFilter.priceSort;
    _nearByOnly = widget.currentFilter.nearByOnly;
  }

  void _reset() {
    setState(() {
      _selectedDistance = DistanceFilterOption.all;
      _selectedPriceSort = PriceSortOption.defaultSort;
      _nearByOnly = false;
    });
  }

  void _apply() {
    final updated = DriverFilterOptions(
      distanceFilter: _selectedDistance,
      priceSort: _selectedPriceSort,
      nearByOnly: _nearByOnly,
    );
    Navigator.pop(context, updated);
  }

  bool get _isOutstation => widget.searchType == DriverSearchType.outstation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Title & Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFF266475),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter Drivers',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. NEAR BY TOGGLE CARD
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F8F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF266475).withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.my_location_rounded,
                              color: Color(0xFF266475),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isOutstation ? 'Closest Outstation' : 'Near By Drivers',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  _isOutstation
                                      ? 'Drivers within 150 KM only'
                                      : 'Drivers within 15 KM only',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _nearByOnly,
                          activeTrackColor: const Color(0xFF266475),
                          onChanged: (val) {
                            setState(() {
                              _nearByOnly = val;
                              if (val) {
                                _selectedDistance = _isOutstation
                                    ? DistanceFilterOption.outstation100To200km
                                    : DistanceFilterOption.nearBy15km;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. DISTANCE CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.navigation_rounded, size: 18, color: Color(0xFF266475)),
                            const SizedBox(width: 8),
                            Text(
                              'Distance Radius',
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChoiceChip(
                              label: 'All Distances',
                              selected: _selectedDistance == DistanceFilterOption.all,
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() {
                                    _selectedDistance = DistanceFilterOption.all;
                                    _nearByOnly = false;
                                  });
                                }
                              },
                            ),
                            if (!_isOutstation) ...[
                              _buildChoiceChip(
                                label: 'Near By (<= 15 KM)',
                                selected: _selectedDistance == DistanceFilterOption.nearBy15km,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() {
                                      _selectedDistance = DistanceFilterOption.nearBy15km;
                                      _nearByOnly = true;
                                    });
                                  }
                                },
                              ),
                              _buildChoiceChip(
                                label: 'Under 50 KM',
                                selected: _selectedDistance == DistanceFilterOption.under50km,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() {
                                      _selectedDistance = DistanceFilterOption.under50km;
                                    });
                                  }
                                },
                              ),
                              _buildChoiceChip(
                                label: 'Under 100 KM',
                                selected: _selectedDistance == DistanceFilterOption.under100km,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() {
                                      _selectedDistance = DistanceFilterOption.under100km;
                                    });
                                  }
                                },
                              ),
                            ] else ...[
                              _buildChoiceChip(
                                label: '100 - 200 KM',
                                selected:
                                    _selectedDistance == DistanceFilterOption.outstation100To200km,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() {
                                      _selectedDistance =
                                          DistanceFilterOption.outstation100To200km;
                                    });
                                  }
                                },
                              ),
                              _buildChoiceChip(
                                label: '200 - 500 KM',
                                selected:
                                    _selectedDistance == DistanceFilterOption.outstation200To500km,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() {
                                      _selectedDistance =
                                          DistanceFilterOption.outstation200To500km;
                                    });
                                  }
                                },
                              ),
                              _buildChoiceChip(
                                label: 'Above 500 KM',
                                selected:
                                    _selectedDistance == DistanceFilterOption.outstationAbove500km,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() {
                                      _selectedDistance =
                                          DistanceFilterOption.outstationAbove500km;
                                    });
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. SORT BY CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.sort_rounded, size: 18, color: Color(0xFF266475)),
                            const SizedBox(width: 8),
                            Text(
                              'Sort By',
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChoiceChip(
                              label: 'Default Sort',
                              selected: _selectedPriceSort == PriceSortOption.defaultSort,
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() {
                                    _selectedPriceSort = PriceSortOption.defaultSort;
                                  });
                                }
                              },
                            ),
                            _buildChoiceChip(
                              label: 'Price: Low to High',
                              selected: _selectedPriceSort == PriceSortOption.lowToHigh,
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() {
                                    _selectedPriceSort = PriceSortOption.lowToHigh;
                                  });
                                }
                              },
                            ),
                            _buildChoiceChip(
                              label: 'Price: High to Low',
                              selected: _selectedPriceSort == PriceSortOption.highToLow,
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() {
                                    _selectedPriceSort = PriceSortOption.highToLow;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. PRICE FILTER CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.currency_rupee_rounded, size: 18, color: Color(0xFF266475)),
                            const SizedBox(width: 8),
                            Text(
                              'Price Filter',
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChoiceChip(
                              label: 'Under ₹300/hr',
                              selected: _selectedPriceSort == PriceSortOption.under300,
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() {
                                    _selectedPriceSort = PriceSortOption.under300;
                                  });
                                }
                              },
                            ),
                            _buildChoiceChip(
                              label: 'Under ₹500/hr',
                              selected: _selectedPriceSort == PriceSortOption.under500,
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() {
                                    _selectedPriceSort = PriceSortOption.under500;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ACTION BUTTONS: RESET & APPLY
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Reset All',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF266475),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: const Color(0xFF266475),
      backgroundColor: const Color(0xFFF5F7FA),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? const Color(0xFF266475) : Colors.grey.shade300,
        ),
      ),
      showCheckmark: false,
    );
  }
}
