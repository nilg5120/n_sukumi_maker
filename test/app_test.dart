import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:n_sukumi_maker/ring_diagram_painter.dart';
import 'package:n_sukumi_maker/element_node.dart';
import 'package:n_sukumi_maker/element_node_input_page.dart';

void main() {

  /// -------- groupElementNodeのテスト --------
  group('groupElementNodeのテスト', () {

    test('単純なリンク', () {
      final nodes = [
        ElementNode(name: 'A', color: Colors.blue, target: 'B'),
        ElementNode(name: 'B', color: Colors.red),
      ];

      final painter = RingDiagramPainter(nodes);
      final groupMap = painter.groupElementNode(nodes);

      expect(groupMap['A'], equals(groupMap['B']));
    });

    test('別グループになるノード', () {
      final nodes = [
        ElementNode(name: 'A', color: Colors.blue, target: 'B'),
        ElementNode(name: 'B', color: Colors.red),
        ElementNode(name: 'C', color: Colors.green),
      ];

      final painter = RingDiagramPainter(nodes);
      final groupMap = painter.groupElementNode(nodes);

      expect(groupMap['A'], equals(groupMap['B']));
      expect(groupMap['C'], isNot(equals(groupMap['A'])));
    });

  });

  /// -------- ElementNodeInputPage のテスト --------
  group('ElementNodeInputPage Tests', () {

    testWidgets('最初に1人空の人物が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ElementNodeInputPage()));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('名前を入力すると空欄が増える', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ElementNodeInputPage()));

      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'テスト名前');

      await tester.pump();

      expect(find.byType(TextField), findsNWidgets(2));
    });

  });

}
