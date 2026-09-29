abstract class SupportState {}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class HelpCategory {
  final String title;
  final String subtitle;
  final String iconCode;
  final String colorCode;

  HelpCategory({
    required this.title,
    required this.subtitle,
    required this.iconCode,
    required this.colorCode,
  });
}

class Ticket {
  final String title;
  final String id;
  final String date;
  final String status;

  Ticket({
    required this.title,
    required this.id,
    required this.date,
    required this.status,
  });
}

class SupportLoaded extends SupportState {
  final List<HelpCategory> categories;
  final List<Ticket> recentTickets;

  SupportLoaded({
    required this.categories,
    required this.recentTickets,
  });
}

class SupportError extends SupportState {
  final String message;
  SupportError(this.message);
}
