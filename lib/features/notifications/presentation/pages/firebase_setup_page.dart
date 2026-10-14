import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../../data/datasources/firebase_notification_service.dart';

class FirebaseSetupPage extends StatelessWidget {
  const FirebaseSetupPage({super.key});

  static const String packageName = 'com.example.cardriver_customer';
  static const String channelId = 'high_importance_channel';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          'Firebase Setup & Status',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Status',
            onPressed: () {
              context.read<NotificationBloc>().add(const InitializeNotifications());
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          final isConfigured = state is NotificationLoaded && state.isFirebaseConfigured;
          final token = state is NotificationLoaded ? state.deviceToken : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Connection Status Card
              _buildStatusCard(isConfigured),
              const SizedBox(height: 16),

              // 2. Package & Token Info Card
              _buildAppInfoCard(context, token),
              const SizedBox(height: 16),

              // 3. Step-by-Step Setup Guide
              _buildSetupInstructionsCard(context),
              const SizedBox(height: 16),

              // 4. Quick Testing Section
              _buildTestNotificationSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(bool isConfigured) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConfigured ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConfigured ? Colors.green.shade300 : Colors.amber.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isConfigured ? Colors.green.shade100 : Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isConfigured ? Icons.cloud_done_rounded : Icons.offline_bolt_rounded,
              color: isConfigured ? Colors.green.shade800 : Colors.amber.shade900,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConfigured ? 'Firebase FCM: Live & Active' : 'Notification Engine: Ready',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isConfigured ? Colors.green.shade900 : Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isConfigured
                      ? 'Push notifications are connected directly to Google Cloud Messaging server.'
                      : 'Local heads-up banner notifications & in-app message stream are fully active. Add google-services.json to connect live cloud push.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: isConfigured ? Colors.green.shade800 : Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context, String? token) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuration Details',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context: context,
            label: 'Firebase Project ID',
            value: 'driverbooking-4b700',
            showCopy: true,
          ),
          const Divider(height: 20),
          _buildInfoRow(
            context: context,
            label: 'Project Number (Sender ID)',
            value: '538470397018',
            showCopy: true,
          ),
          const Divider(height: 20),
          _buildInfoRow(
            context: context,
            label: 'Android Package Name',
            value: packageName,
            showCopy: true,
          ),
          const Divider(height: 20),
          _buildInfoRow(
            context: context,
            label: 'Notification Channel ID',
            value: channelId,
            showCopy: true,
          ),
          const Divider(height: 20),
          _buildInfoRow(
            context: context,
            label: 'FCM Device Token',
            value: token != null && token.isNotEmpty ? token : 'Generating / Standby...',
            showCopy: token != null && token.isNotEmpty,
            isMultiLine: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    bool showCopy = false,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              SelectableText(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (showCopy)
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.black54),
            tooltip: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSetupInstructionsCard(BuildContext context) {
    final steps = [
      {
        'step': '1',
        'title': 'Go to Firebase Console',
        'desc': 'Visit https://console.firebase.google.com and open or create your project.',
      },
      {
        'step': '2',
        'title': 'Register Android Application',
        'desc': 'Add an Android app with Package Name: $packageName',
      },
      {
        'step': '3',
        'title': 'Download Configuration File',
        'desc': 'Download google-services.json from the Firebase settings.',
      },
      {
        'step': '4',
        'title': 'Place in Android App Directory',
        'desc': 'Paste the file into: cardriver_customer/android/app/google-services.json',
      },
      {
        'step': '5',
        'title': 'Rebuild and Run',
        'desc': 'Run flutter run. The app will immediately activate live Google Cloud Messaging!',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist_rounded, color: AppColors.primaryDark),
              SizedBox(width: 8),
              Text(
                'Firebase Cloud Setup Steps',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.map((s) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      s['step']!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['title']!,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s['desc']!,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTestNotificationSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instant Live Notification Test',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            'Dispatch an immediate test alert to verify the heads-up banner and real-time stream.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickTestButton(
                context: context,
                label: 'Driver Arrived',
                icon: Icons.directions_car_rounded,
                color: Colors.blue.shade600,
                title: 'Driver Arrived 🚗',
                body: 'Your driver is waiting at the designated pickup spot.',
                type: 'driver',
              ),
              _buildQuickTestButton(
                context: context,
                label: 'Booking Alert',
                icon: Icons.calendar_month_rounded,
                color: Colors.amber.shade800,
                title: 'Booking Confirmed ⚡',
                body: 'Your scheduled booking #6ace03e49 has been confirmed.',
                type: 'booking',
              ),
              _buildQuickTestButton(
                context: context,
                label: 'Payment Done',
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.green.shade600,
                title: 'Payment Received ₹450 💳',
                body: 'Receipt for driver service has been generated.',
                type: 'payment',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Background & Permission Diagnostics',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.security_rounded, size: 16),
                  label: const Text('Check Permissions', style: TextStyle(fontSize: 12)),
                  onPressed: () async {
                    final granted = await FirebaseNotificationService.instance.requestPermissions();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(granted
                              ? '✅ Notification permissions are GRANTED!'
                              : '⚠️ Notification permissions are not granted yet.'),
                          backgroundColor: granted ? Colors.green.shade800 : Colors.red.shade800,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.timer_rounded, size: 16),
                  label: const Text('Test in 5s (Minimize)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⏱️ Alert scheduled in 5 seconds! Minimize the app now to test background banner.'),
                        duration: Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Future.delayed(const Duration(seconds: 5), () {
                      FirebaseNotificationService.instance.showNotification(
                        title: 'Background Alert Test 🚀',
                        body: 'This notification popped up successfully while the app was in the background!',
                        payload: 'test',
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTestButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required String title,
    required String body,
    required String type,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      onPressed: () {
        context.read<NotificationBloc>().add(
              SendNotificationEvent(
                title: title,
                message: body,
                type: type,
              ),
            );
      },
    );
  }
}
