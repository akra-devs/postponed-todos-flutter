import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:postponed_todos/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home loads and quick add task flow works', (tester) async {
    await tester.pumpWidget(const PostponedTodosApp());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('미뤄둔 할일들'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final titleField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == '할 일 제목',
    );
    final noteField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == '메모',
    );

    expect(titleField, findsOneWidget);
    expect(noteField, findsOneWidget);

    await tester.enterText(titleField, '통합 테스트 할 일');
    await tester.enterText(noteField, 'E2E/Playwright 후보 확인용 샘플');

    await tester.tap(find.text('미뤄둔 일 넣기'));
    await tester.pumpAndSettle();

    // 이동은 홈의 추천/리스트 화면이 렌더된 후 보조로 확인.
    expect(find.text('통합 테스트 할 일'), findsAtLeast(1));

    await tester.tap(find.text('미루는 중').first);
    await tester.pumpAndSettle();

    expect(find.text('당장은 아니어도 잊지 않는 보관 목록'), findsOneWidget);
    expect(find.text('통합 테스트 할 일'), findsAtLeast(1));
  });
}
