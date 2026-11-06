import 'package:flutter_test/flutter_test.dart';
import 'package:exam_dart/main.dart';

void main() {
  testWidgets('Order app displays My Order title and initial items', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyOrderApp());

    // Verify that "My Order" title is displayed
    expect(find.text('My Order'), findsOneWidget);

    // Verify that Add Item to Cart button is present
    expect(find.text('Add Item to Cart'), findsOneWidget);

    // Verify initial items from JSON exist
    expect(find.text('A1000'), findsOneWidget);
    expect(find.text('Iphone 15'), findsOneWidget);
    expect(find.text('A1001'), findsOneWidget);
    expect(find.text('Iphone 16'), findsOneWidget);
  });
}
