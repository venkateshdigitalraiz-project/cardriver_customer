import 'package:equatable/equatable.dart';

class DriverJobData extends Equatable {
  final String id;
  final String jobId;
  final String jobTitle;
  final String jobType;
  final String status;
  final String salary;
  final String locationAddress;
  final String? createdAt;

  const DriverJobData({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.jobType,
    required this.status,
    required this.salary,
    required this.locationAddress,
    this.createdAt,
  });

  factory DriverJobData.fromJson(Map<String, dynamic> json) {
    return DriverJobData(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      jobId: json['jobId']?.toString() ??
          'JOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      jobTitle: json['jobTitle']?.toString() ?? 'Driver Requirement',
      jobType: json['jobType']?.toString() ?? 'Full-Time',
      status: json['status']?.toString() ?? 'ACTIVE',
      salary: json['salary']?.toString() ?? '',
      locationAddress: (json['location'] is Map
              ? json['location']['address']?.toString()
              : null) ??
          json['locationAddress']?.toString() ??
          '',
      createdAt: json['createdAt']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        jobId,
        jobTitle,
        jobType,
        status,
        salary,
        locationAddress,
        createdAt,
      ];
}

class DriverJobResponse extends Equatable {
  final bool success;
  final String message;
  final DriverJobData? data;

  const DriverJobResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DriverJobResponse.fromJson(Map<String, dynamic> json) {
    return DriverJobResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'Driver job posted successfully',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? DriverJobData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}

