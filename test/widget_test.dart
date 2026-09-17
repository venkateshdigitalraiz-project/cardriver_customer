import 'package:flutter_test/flutter_test.dart';
import 'package:cardriver_customer/main.dart';

void main() {
  testWidgets('Driver Customer App renders Login page smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DriverCustomerApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify key elements exist
    expect(find.text('CAR DRIVER'), findsOneWidget);
    expect(find.text('Hourly Driver'), findsOneWidget);
    expect(find.text('Phone Number'), findsWidgets);
    expect(find.text('Sign In & Find Drivers'), findsOneWidget);
  });
}
