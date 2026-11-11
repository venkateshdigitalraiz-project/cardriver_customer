import 'package:equatable/equatable.dart';

abstract class ReferralEvent extends Equatable {
  const ReferralEvent();

  @override
  List<Object?> get props => [];
}

class LoadReferralInfoEvent extends ReferralEvent {
  const LoadReferralInfoEvent();
}

class CopyReferralCodeEvent extends ReferralEvent {
  final String code;

  const CopyReferralCodeEvent(this.code);

  @override
  List<Object?> get props => [code];
}

class ShareReferralEvent extends ReferralEvent {
  final String text;

  const ShareReferralEvent(this.text);

  @override
  List<Object?> get props => [text];
}

