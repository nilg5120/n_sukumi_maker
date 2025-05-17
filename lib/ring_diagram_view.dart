import 'package:flutter/material.dart';
import 'ring_diagram_painter.dart';
import 'element_node.dart';

/// ノードの相関図を描画するビュー。
class RingDiagramView extends StatelessWidget {
  final List<ElementNode> nodes;

  const RingDiagramView({super.key, required this.nodes});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 10.0,
      child: CustomPaint(
        painter: RingDiagramPainter(nodes),
        child: Container(),
      ),
    );
  }
}
