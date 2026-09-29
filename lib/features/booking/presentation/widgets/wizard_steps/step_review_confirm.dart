import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/flow/booking_flow_bloc.dart';
import '../../bloc/flow/booking_flow_state.dart';

class StepReviewConfirm extends StatelessWidget {
  const StepReviewConfirm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingFlowBloc, BookingFlowState>(
      builder: (context, state) {
        final req = state.request;

        int _calculateFare(var req) {
          if (req.isOutstation) {
            return req.durationHours * 1500; // Assuming outstation daily flat rate
          }
          if (req.scheduleHour == null) {
            return req.durationHours * 150;
          }
          int totalFare = 0;
          int currentHour = req.scheduleHour!;
          for (int i = 0; i < req.durationHours; i++) {
            int h = (currentHour + i) % 24;
            if (h >= 0 && h < 4) {
              totalFare += 200; // 12 AM to 4 AM
            } else {
              totalFare += 150; // 4 AM to 12 AM
            }
          }
          return totalFare;
        }
        
        final baseFare = _calculateFare(req);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose Driver Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // DriveU Plus Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade800),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1E24),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DriveU Plus',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Top-rated chauffeurs',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹ $baseFare',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // DriveU Classic Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1E24),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.greenAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DriveU Classic',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Verified, trained & tested',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹ ${(baseFare * 0.9).round()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 150), // Space for sticky bottom bar
            ],
          ),
        );
      },
    );
  }
}
