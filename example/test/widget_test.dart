import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('navigates between multi-page editor examples', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('PV Grid Edit Examples'), findsOneWidget);
    expect(find.text('Fixed Shapes'), findsOneWidget);
    expect(find.text('Constraint Playground'), findsOneWidget);
    expect(find.text('Free Flow Layers'), findsOneWidget);

    await tester.tap(find.text('Constraint Playground'));
    await tester.pumpAndSettle();

    expect(find.text('Constraint Playground'), findsWidgets);
    expect(find.text('Grow within limits'), findsOneWidget);
    expect(find.text('Mixed layout'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Free Flow Layers'));
    await tester.pumpAndSettle();

    expect(find.text('Free Flow Layers'), findsWidgets);
    expect(find.text('Bring teal to front'), findsOneWidget);
    expect(find.text('Frozen frame + floating layers'), findsOneWidget);
  });
}
