import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.titleMedium.copyWith(color: Colors.white)),
        backgroundColor: const Color(0xFF26262B),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Profile Page Placeholder', style: AppTypography.bodyLarge),
      ),
    );
  }
}
