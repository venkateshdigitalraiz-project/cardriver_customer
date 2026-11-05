import 'package:equatable/equatable.dart';

class UserJobEntity extends Equatable {
  final String id;
  final String jobId;
  final String title;
  final int monthlySalary;
  final String joiningDate;
  final String description;
  final String location;
  final String jobType;
  final String status;
  final double paymentAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? createdAt;

  const UserJobEntity({
    required this.id,
    required this.jobId,
    required this.title,
    required this.monthlySalary,
    required this.joiningDate,
    required this.description,
    required this.location,
    required this.jobType,
    required this.status,
    this.paymentAmount = 499.0,
    this.paymentStatus = 'completed',
    this.paymentMethod = 'razorpay',
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.createdAt,
  });

  factory UserJobEntity.fromJson(Map<String, dynamic> json) {
    return UserJobEntity(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      jobId: json['jobId']?.toString() ??
          (json['_id'] != null
              ? 'JOB-${json['_id'].toString().substring(json['_id'].toString().length > 6 ? json['_id'].toString().length - 6 : 0).toUpperCase()}'
              : 'JOB-POST'),
      title: json['title']?.toString() ?? 'Driver Requirement',
      monthlySalary: (json['monthlySalary'] as num?)?.toInt() ?? 0,
      joiningDate: json['joiningDate']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      jobType: json['jobType']?.toString() ?? 'full_time',
      status: json['status']?.toString().toLowerCase() ?? 'active',
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble() ?? 499.0,
      paymentStatus: json['paymentStatus']?.toString() ?? 'completed',
      paymentMethod: json['paymentMethod']?.toString() ?? 'razorpay',
      razorpayOrderId: json['razorpayOrderId']?.toString(),
      razorpayPaymentId: json['razorpayPaymentId']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  String get formattedSalary {
    if (monthlySalary <= 0) return 'Negotiable';
    final str = monthlySalary.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write(',');
      } else if (count > 3 && (count - 3) % 2 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    final formatted = buffer.toString().split('').reversed.join('');
    return '₹$formatted / mo';
  }

  String get formattedJobType {
    switch (jobType.toLowerCase()) {
      case 'full_time':
        return 'Full Time';
      case 'part_time':
        return 'Part Time';
      case 'contract':
        return 'Contract';
      case 'temporary':
        return 'Temporary';
      default:
        return jobType.replaceAll('_', ' ').toUpperCase();
    }
  }

  String get formattedJoiningDate {
    if (joiningDate.isEmpty) return 'Immediate';
    try {
      final dt = DateTime.parse(joiningDate).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year = dt.year;
      return '$day $month $year';
    } catch (_) {
      return joiningDate.split('T').first;
    }
  }

  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt!).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year = dt.year;
      return '$day $month $year';
    } catch (_) {
      return createdAt!.split('T').first;
    }
  }

  @override
  List<Object?> get props => [
        id,
        jobId,
        title,
        monthlySalary,
        joiningDate,
        description,
        location,
        jobType,
        status,
        paymentAmount,
        paymentStatus,
        paymentMethod,
        razorpayOrderId,
        razorpayPaymentId,
        createdAt,
      ];
}

class UserJobListResponseEntity extends Equatable {
  final bool success;
  final String message;
  final List<UserJobEntity> jobs;
  final int total;
  final int page;
  final int limit;

  const UserJobListResponseEntity({
    required this.success,
    required this.message,
    required this.jobs,
    this.total = 0,
    this.page = 1,
    this.limit = 10,
  });

  factory UserJobListResponseEntity.fromJson(Map<String, dynamic> json) {
    List<UserJobEntity> items = [];
    if (json['data'] is List) {
      items = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => UserJobEntity.fromJson(e))
          .toList();
    } else if (json['jobs'] is List) {
      items = (json['jobs'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => UserJobEntity.fromJson(e))
          .toList();
    } else if (json['data'] is Map<String, dynamic>) {
      final dataObj = json['data'] as Map<String, dynamic>;
      if (dataObj['jobs'] is List) {
        items = (dataObj['jobs'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => UserJobEntity.fromJson(e))
            .toList();
      } else if (dataObj['results'] is List) {
        items = (dataObj['results'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => UserJobEntity.fromJson(e))
            .toList();
      }
    }

    final totalCount = (json['total'] as num?)?.toInt() ??
        (json['totalCount'] as num?)?.toInt() ??
        (json['count'] as num?)?.toInt() ??
        items.length;

    final currPage = (json['page'] as num?)?.toInt() ??
        (json['currentPage'] as num?)?.toInt() ??
        1;

    return UserJobListResponseEntity(
      success: json['success'] == true || json['status'] == 'success',
      message: json['message']?.toString() ?? '',
      jobs: items,
      total: totalCount,
      page: currPage,
    );
  }

  @override
  List<Object?> get props => [success, message, jobs, total, page, limit];
}

