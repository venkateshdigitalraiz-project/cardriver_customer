import '../../../domain/entities/booking_entity.dart';
import 'package:equatable/equatable.dart';

abstract class MyBookingsState extends Equatable {
  const MyBookingsState();

  @override
  List<Object?> get props => [];
}

class MyBookingsInitial extends MyBookingsState {}

class MyBookingsLoading extends MyBookingsState {}

class MyBookingsLoaded extends MyBookingsState {
  final List<BookingEntity> bookings;
  final BookingPaginationEntity pagination;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String currentStatus;

  const MyBookingsLoaded(
    this.bookings, {
    this.pagination = const BookingPaginationEntity(),
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentStatus = '',
  });

  /// Total count of bookings loaded or from pagination
  int get totalCount => pagination.total > 0 ? pagination.total : bookings.length;

  /// Returns all bookings if type is 'all', otherwise filters by statusGroup or status
  List<BookingEntity> getBookingsForType(String type) {
    if (type.toLowerCase() == 'all') {
      return bookings;
    }
    final lowerType = type.toLowerCase();
    return bookings.where((b) {
      return b.statusGroup.toLowerCase() == lowerType ||
             b.status.toLowerCase() == lowerType;
    }).toList();
  }

  /// Helper to get count for a specific type
  int getCountForType(String type) => getBookingsForType(type).length;

  MyBookingsLoaded copyWith({
    List<BookingEntity>? bookings,
    BookingPaginationEntity? pagination,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? currentStatus,
  }) {
    return MyBookingsLoaded(
      bookings ?? this.bookings,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentStatus: currentStatus ?? this.currentStatus,
    );
  }

  @override
  List<Object?> get props => [
        bookings,
        pagination,
        isLoadingMore,
        hasReachedMax,
        currentStatus,
      ];
}

class MyBookingsError extends MyBookingsState {
  final String message;

  const MyBookingsError(this.message);

  @override
  List<Object?> get props => [message];
}

