// element_node_input_page.dart
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

  @override
  void initState() {
    super.initState();
    elementNodes.add(ElementNode(name: '', color: Colors.blue));
  }

  void addElementNode() {
    setState(() {
      final color = defaultColors[elementNodes.length % defaultColors.length];
      elementNodes.add(ElementNode(name: '', color: color));
    });
  }

  void removeElementNode(int index) {
    setState(() {
      elementNodes.removeAt(index);
    });
  }

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
      appBar: AppBar(title: const Text('nすくみメーカー')),
      body: Column(
        children: [
          Expanded(
            child: ElementNodeListView(
              elementNodes: elementNodes,
              onAdd: addElementNode,
              onRemove: removeElementNode,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 400,
            child: RingDiagramView(nodes: elementNodes),
          ),
        ],
      ),
    );
  }
}
