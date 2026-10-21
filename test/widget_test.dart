import 'package:flutter_test/flutter_test.dart';
import 'package:cardriver_customer/main.dart';
import 'package:cardriver_customer/features/main_navigation/presentation/pages/main_page.dart';

void main() {
  testWidgets('Driver Customer App renders MainPage when logged in', (WidgetTester tester) async {
    await tester.pumpWidget(const DriverCustomerApp(isLoggedIn: true));
    await tester.pump();
    expect(find.byType(DriverCustomerApp), findsOneWidget);
    expect(find.byType(MainPage), findsOneWidget);
  });
}
