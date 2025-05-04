import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';


void main() {
  group('PeopleInputPage Tests', () {
    testWidgets('最初に1人空の人物が表示される', (WidgetTester tester) async {
      // アプリを起動する
      await tester.pumpWidget(MaterialApp(home: PeopleInputPage()));

      // テキストフィールドが1個あるか確認
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('名前を入力すると空欄が増える', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: PeopleInputPage()));

      // 最初は1個
      expect(find.byType(TextField), findsOneWidget);

      // テキストフィールドに入力
      await tester.enterText(find.byType(TextField).first, 'テスト名前');

      // リビルド反映
      await tester.pump();

      // 空欄がもう1個増えているはず（合計2個）
      expect(find.byType(TextField), findsNWidgets(2));
    });
  });
}
