import 'package:equatable/equatable.dart';

abstract class MyBookingsEvent extends Equatable {
  const MyBookingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyBookings extends MyBookingsEvent {
  final int page;
  final int limit;
  final String status;
  final String startDate;
  final String endDate;
  final String search;

  const LoadMyBookings({
    this.page = 1,
    this.limit = 5,
    this.status = '',
    this.startDate = '',
    this.endDate = '',
    this.search = '',
  });

  @override
  List<Object?> get props => [page, limit, status, startDate, endDate, search];
}

class RefreshMyBookings extends MyBookingsEvent {
  final int limit;
  final String status;
  final String startDate;
  final String endDate;
  final String search;

  const RefreshMyBookings({
    this.limit = 5,
    this.status = '',
    this.startDate = '',
    this.endDate = '',
    this.search = '',
  });

  @override
  List<Object?> get props => [limit, status, startDate, endDate, search];
}

class LoadMoreMyBookings extends MyBookingsEvent {}

