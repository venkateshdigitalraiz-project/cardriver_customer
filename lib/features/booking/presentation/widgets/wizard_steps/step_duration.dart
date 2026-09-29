import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/flow/booking_flow_bloc.dart';
import '../../bloc/flow/booking_flow_event.dart';
import '../../bloc/flow/booking_flow_state.dart';

class StepDuration extends StatelessWidget {
  const StepDuration({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingFlowBloc, BookingFlowState>(
      builder: (context, state) {
        final isOutstation = state.request.isOutstation;
        final tripType = state.request.tripType;
        
        List<int> durations;
        if (tripType == 'Outstation') {
          durations = [1, 2, 3, 4, 5, 6]; // Days for outstation
        } else {
          durations = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]; // Hours for local
        }
            
        final selectedHours = state.request.durationHours;

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Estimated Usage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Horizontally Scrollable Duration Chips
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: durations.length,
                  itemBuilder: (context, index) {
                    final hours = durations[index];
                    final isSelected = hours == selectedHours;

                    return GestureDetector(
                      onTap: () {
                        context
                            .read<BookingFlowBloc>()
                            .add(UpdateDurationEvent(hours));
                      },
                      child: Container(
                        width: 56,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green.shade50 : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isOutstation ? '$hours' : (hours >= 24 ? '${hours ~/ 24}' : '$hours'),
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    isOutstation
                                        ? (hours > 1 ? 'Days' : 'Day')
                                        : (hours >= 24 ? (hours > 24 ? 'Days' : 'Day') : (hours > 1 ? 'Hrs' : 'Hr')),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
