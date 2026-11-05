import 'package:equatable/equatable.dart';

class JobPostDataEntity extends Equatable {
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
  final String? createdAt;

  const JobPostDataEntity({
    required this.id,
    required this.jobId,
    required this.title,
    required this.monthlySalary,
    required this.joiningDate,
    required this.description,
    required this.location,
    required this.jobType,
    required this.status,
    required this.paymentAmount,
    this.createdAt,
  });

  factory JobPostDataEntity.fromJson(Map<String, dynamic> json) {
    return JobPostDataEntity(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      jobId: json['jobId']?.toString() ??
          json['_id']?.toString() ??
          'JOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: json['title']?.toString() ?? '',
      monthlySalary: (json['monthlySalary'] as num?)?.toInt() ?? 0,
      joiningDate: json['joiningDate']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      jobType: json['jobType']?.toString() ?? 'full_time',
      status: json['status']?.toString() ?? 'active',
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble() ?? 499.0,
      createdAt: json['createdAt']?.toString(),
    );
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
        createdAt,
      ];
}

class JobPostResponseEntity extends Equatable {
  final bool success;
  final String message;
  final JobPostDataEntity? data;

  const JobPostResponseEntity({
    required this.success,
    required this.message,
    this.data,
  });

  factory JobPostResponseEntity.fromJson(Map<String, dynamic> json) {
    JobPostDataEntity? jobData;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      jobData = JobPostDataEntity.fromJson(json['data'] as Map<String, dynamic>);
    } else if (json['job'] != null && json['job'] is Map<String, dynamic>) {
      jobData = JobPostDataEntity.fromJson(json['job'] as Map<String, dynamic>);
    }

    return JobPostResponseEntity(
      success: json['success'] == true || json['status'] == 'success',
      message: json['message']?.toString() ?? 'Job posted successfully!',
      data: jobData,
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}

