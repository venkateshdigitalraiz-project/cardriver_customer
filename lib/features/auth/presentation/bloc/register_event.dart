import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;

  const RegisterSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, phone, address];
}

class ResetRegisterState extends RegisterEvent {
  const ResetRegisterState();
}
