import 'package:equatable/equatable.dart';

enum DistanceFilterOption {
  all,
  nearBy15km,
  under50km,
  under100km,
  outstation100To200km,
  outstation200To500km,
  outstationAbove500km,
}

enum PriceSortOption { defaultSort, lowToHigh, highToLow, under300, under500 }

class DriverFilterOptions extends Equatable {
  final DistanceFilterOption distanceFilter;
  final PriceSortOption priceSort;
  final bool nearByOnly;

  const DriverFilterOptions({
    this.distanceFilter = DistanceFilterOption.all,
    this.priceSort = PriceSortOption.defaultSort,
    this.nearByOnly = false,
  });

  DriverFilterOptions copyWith({
    DistanceFilterOption? distanceFilter,
    PriceSortOption? priceSort,
    bool? nearByOnly,
  }) {
    return DriverFilterOptions(
      distanceFilter: distanceFilter ?? this.distanceFilter,
      priceSort: priceSort ?? this.priceSort,
      nearByOnly: nearByOnly ?? this.nearByOnly,
    );
  }

  bool get hasActiveFilter =>
      distanceFilter != DistanceFilterOption.all ||
      priceSort != PriceSortOption.defaultSort ||
      nearByOnly;

  @override
  List<Object?> get props => [distanceFilter, priceSort, nearByOnly];
}
