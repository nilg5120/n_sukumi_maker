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
    test('グループIDが正しく割り当てられる（再帰チェック）', () {
      final nodes = [
        ElementNode(name: 'A', color: Colors.blue, target: 'B'),
        ElementNode(name: 'B', color: Colors.red, target: 'C'),
        ElementNode(name: 'C', color: Colors.green),
        ElementNode(name: 'X', color: Colors.purple, target: 'Y'),
        ElementNode(name: 'Y', color: Colors.orange),
      ];

      final painter = RingDiagramPainter(nodes);
      final groupMap = painter.groupElementNode(nodes);

      // A, B, C は同じグループになるはず
      expect(groupMap['A'], equals(groupMap['B']));
      expect(groupMap['B'], equals(groupMap['C']));

      // X と Y は別グループ（A~Cとは違う）
      expect(groupMap['X'], equals(groupMap['Y']));
      expect(groupMap['X'], isNot(equals(groupMap['A'])));
    });
    test('深い再帰でグループIDが正しく伝播する', () {
      final nodes = [
        ElementNode(name: '1', color: Colors.blue, target: '2'),
        ElementNode(name: '2', color: Colors.red, target: '3'),
        ElementNode(name: '3', color: Colors.green, target: '4'),
        ElementNode(name: '4', color: Colors.yellow),
      ];

      final painter = RingDiagramPainter(nodes);
      final groupMap = painter.groupElementNode(nodes);

      final groupId = groupMap['1']!;

      for (var i = 1; i <= 4; i++) {
        expect(groupMap['$i'], equals(groupId),
            reason: 'ノード $i はすべて同じグループに属しているはず');
      }
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

  group('RingDiagramPainter のユーティリティメソッドのテスト', () {
    test('矢印ヘッドの座標が正しく計算される', () {
      // painter を空リストで作成（ノードは必要ない）
      final painter = RingDiagramPainter([]);

      final from = Offset(0, 0);
      final to = Offset(10, 0);
      const arrowSize = 10.0;

      final points = painter.calculateArrowHeadPoints(from, to, arrowSize);

      // 頂点の数を確認
      expect(points.length, 3);

      // 頂点の1つ目は to と一致する
      expect(points[0], equals(to));

      // 残りの2点は to から左上・左下に伸びている（x座標が to より小さい）
      expect(points[1].dx, lessThan(to.dx));
      expect(points[2].dx, lessThan(to.dx));
    });
    testWidgets('矢印描画が行われる', (WidgetTester tester) async {
      final nodes = [
        ElementNode(name: 'A', color: Colors.blue, target: 'B'),
        ElementNode(name: 'B', color: Colors.red),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              key: Key('ringDiagram'),
              painter: RingDiagramPainter(nodes),
            ),
          ),
        ),
      );

      expect(find.byKey(Key('ringDiagram')), findsOneWidget);
    });

  });

}
