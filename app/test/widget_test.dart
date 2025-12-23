import 'package:flutter_test/flutter_test.dart';

import 'package:app/presentation/app/app_root.dart';

void main() {
  testWidgets('Root contains text "Let\'s go!', (WidgetTester tester) async {
    await tester.pumpWidget(const AppRoot());

    final textFinder = find.text("Let's go!");

    expect(textFinder, findsOneWidget);
  });
}
