import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:n_sukumi_maker/ring_diagram_painter.dart';
import 'package:n_sukumi_maker/element_node.dart';

void main() {
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
}
