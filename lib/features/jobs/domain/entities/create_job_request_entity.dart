import 'package:equatable/equatable.dart';

class CreateJobRequestEntity extends Equatable {
  final String title;
  final int monthlySalary;
  final String joiningDate;
  final String description;
  final double paymentAmount;
  final String paymentMethod;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final String location;
  final String jobType;

  const CreateJobRequestEntity({
    required this.title,
    required this.monthlySalary,
    required this.joiningDate,
    required this.description,
    this.paymentAmount = 499.0,
    this.paymentMethod = 'razorpay',
    this.razorpayOrderId = '',
    this.razorpayPaymentId = '',
    this.razorpaySignature = '',
    required this.location,
    required this.jobType,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'monthlySalary': monthlySalary,
      'joiningDate': joiningDate,
      'description': description,
      'paymentAmount': paymentAmount,
      'paymentMethod': paymentMethod,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
      'location': location,
      'jobType': jobType,
    };
  }

  factory CreateJobRequestEntity.fromJson(Map<String, dynamic> json) {
    return CreateJobRequestEntity(
      title: json['title']?.toString() ?? '',
      monthlySalary: (json['monthlySalary'] as num?)?.toInt() ?? 0,
      joiningDate: json['joiningDate']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble() ?? 499.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'razorpay',
      razorpayOrderId: json['razorpayOrderId']?.toString() ?? '',
      razorpayPaymentId: json['razorpayPaymentId']?.toString() ?? '',
      razorpaySignature: json['razorpaySignature']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      jobType: json['jobType']?.toString() ?? 'full_time',
    );
  }

  @override
  List<Object?> get props => [
        title,
        monthlySalary,
        joiningDate,
        description,
        paymentAmount,
        paymentMethod,
        razorpayOrderId,
        razorpayPaymentId,
        razorpaySignature,
        location,
        jobType,
      ];
}

