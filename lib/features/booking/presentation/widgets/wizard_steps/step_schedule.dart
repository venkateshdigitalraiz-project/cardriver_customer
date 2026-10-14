import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/flow/booking_flow_bloc.dart';
import '../../bloc/flow/booking_flow_event.dart';
import '../../bloc/flow/booking_flow_state.dart';
import 'step_duration.dart';

class StepSchedule extends StatefulWidget {
  const StepSchedule({super.key});

  @override
  State<StepSchedule> createState() => _StepScheduleState();
}

class _StepScheduleState extends State<StepSchedule> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    final req = context.read<BookingFlowBloc>().state.request;
    if (req.scheduleDate != null) {
      _selectedDate = req.scheduleDate!;
    }
    if (req.scheduleHour != null && req.scheduleMinute != null) {
      _selectedTime = TimeOfDay(
        hour: req.scheduleHour!,
        minute: req.scheduleMinute!,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateBloc(context);
      }
    });
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          );
        },
      );

      if (time != null && context.mounted) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
        _updateBloc(context);
      } else if (context.mounted) {
        setState(() {
          _selectedDate = date;
        });
        _updateBloc(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingFlowBloc, BookingFlowState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pickup Date & Time Header
            const Text(
              'Pickup Date & Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Pickup Date & Time Selector Card
            InkWell(
              onTap: () => _pickDateTime(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.green),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${state.request.isOutstation ? 'Outstation' : 'Local'} • ${state.request.tripType}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('dd MMM yyyy').format(_selectedDate)} at ${_selectedTime.format(context)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.edit_calendar,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Estimated Usage Duration Chips
            const StepDuration(padding: EdgeInsets.zero),
          ],
        );
      },
    );
  }

  void _updateBloc(BuildContext context) {
    context.read<BookingFlowBloc>().add(
      UpdateScheduleEvent(
        date: _selectedDate,
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      ),
    );
  }
}
