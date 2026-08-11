import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postponed_todos/core/theme/app_theme.dart';
import 'package:postponed_todos/features/tasks/presentation/widgets/quick_add_card.dart';

void main() {
  testWidgets('keeps the draft and shows an inline message when saving fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: QuickAddCard(onSubmit: (_, _) async => false)),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, '병원 예약');
    await tester.tap(find.text('미뤄둔 일 넣기'));
    await tester.pump();

    expect(find.text('저장하지 못했어요. 입력 내용은 그대로 두었으니 다시 시도해 주세요.'), findsOneWidget);
    expect(find.text('병원 예약'), findsOneWidget);
  });

  testWidgets('validates an empty title close to the field', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: QuickAddCard(onSubmit: (_, _) async => true)),
      ),
    );

    await tester.tap(find.text('미뤄둔 일 넣기'));
    await tester.pump();

    expect(find.text('할 일을 한 줄로 적어주세요.'), findsOneWidget);
  });
}
