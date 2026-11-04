import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/app/app.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';

void main() {
  testWidgets('should show the home placeholder when the app starts', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: RumboApp()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.homeTitle), findsOneWidget);
    expect(find.text(AppStrings.homeSubtitle), findsOneWidget);
  });
}
