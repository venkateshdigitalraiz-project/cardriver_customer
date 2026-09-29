import 'package:flutter/material.dart';

enum LegalPageType { terms, privacy }

class LegalPage extends StatelessWidget {
  final LegalPageType pageType;

  const LegalPage({super.key, required this.pageType});

  @override
  Widget build(BuildContext context) {
    final isTerms = pageType == LegalPageType.terms;
    final title = isTerms ? 'Terms & Conditions' : 'Privacy Policy';
    final content = isTerms ? _getTermsContent() : _getPrivacyContent();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  String _getTermsContent() {
    return '''
Terms & Conditions

1. Introduction
Welcome to DriveU. By using our application, you agree to comply with and be bound by the following terms and conditions of use.

2. User Responsibilities
Users must provide accurate information when booking rides and ensure payment for services rendered. Any misuse of the application or violation of our community guidelines may result in account termination.

3. Service Availability
While we strive to provide 24/7 service, availability may vary based on location, driver supply, and unforeseen circumstances.

4. Payments and Cancellations
Fares are estimated based on time and distance. Cancellation fees may apply if a ride is canceled after a driver has been dispatched.

5. Limitation of Liability
We are not liable for any delays, missed appointments, or damages resulting from the use of our service.

6. Changes to Terms
We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of the modified terms.
''';
  }

  String _getPrivacyContent() {
    return '''
Privacy Policy

1. Information We Collect
We collect personal information such as your name, email, phone number, and location data to provide our services effectively.

2. How We Use Your Information
Your data is used to match you with drivers, process payments, improve our services, and communicate with you about your account.

3. Location Services
Our app requires background location access to track rides and provide accurate ETAs. You can manage these permissions in your device settings.

4. Data Sharing
We do not sell your personal data. We only share necessary information with drivers (like pickup location and name) to fulfill your ride request.

5. Data Security
We implement industry-standard security measures to protect your personal information from unauthorized access or disclosure.

6. Your Rights
You have the right to request access to, correction of, or deletion of your personal data stored in our systems.
''';
  }
}
