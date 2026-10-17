import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/main.dart';

void main() {
  testWidgets('App loads and shows bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const RoamApp());

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Trips'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Hotels'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });
}