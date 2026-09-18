import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class RatesPage extends StatelessWidget {
  const RatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rates', style: AppTypography.titleMedium.copyWith(color: Colors.white)),
        backgroundColor: const Color(0xFF26262B),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Rates Page Placeholder', style: AppTypography.bodyLarge),
      ),
    );
  }
}
