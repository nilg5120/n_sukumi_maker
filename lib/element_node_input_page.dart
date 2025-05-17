import 'package:flutter/material.dart';
import 'element_node.dart';
import 'element_node_list_view.dart';
import 'ring_diagram_view.dart';

class ElementNodeInputPage extends StatefulWidget {
  const ElementNodeInputPage({super.key});

  @override
  ElementNodeInputPageState createState() => ElementNodeInputPageState();
}

class ElementNodeInputPageState extends State<ElementNodeInputPage> {
  List<ElementNode> elementNodes = [];

  /// 初期化時にデフォルトのノードを追加
  @override
  void initState() {
    super.initState();
    elementNodes.add(ElementNode(name: '', color: Colors.blue));
  }

  /// ノードを追加するメソッド
  /// 新しいノードはデフォルトの色を持つ
  void addElementNode() {
    setState(() {
      final color = defaultColors[elementNodes.length % defaultColors.length];
      elementNodes.add(ElementNode(name: '', color: color));
    });
  }

  /// ノードを削除するメソッド
  /// [index]は削除するノードのインデックス
  void removeElementNode(int index) {
    setState(() {
      elementNodes.removeAt(index);
    });
  }

  /// デフォルトの色リスト
  final List<Color> defaultColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // アプリバーのタイトル
      appBar: AppBar(title: const Text('nすくみメーカー')),

      // ノードリストと図を表示するカラム
      body: Column(
        children: [
          // ノードリストの表示
          Expanded(
            child: ElementNodeListView(
              elementNodes: elementNodes,
              onAdd: addElementNode,
              onRemove: removeElementNode,
            ),
          ),

          // ノードリストと図の間にスペースを追加
          const SizedBox(height: 8),

          // ノードの相関図を描画する
          SizedBox(
            height: 400,
            child: RingDiagramView(nodes: elementNodes),
          ),
        ],
      ),
    );
  }
}
