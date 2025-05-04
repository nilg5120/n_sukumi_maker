import 'package:flutter/material.dart';
import 'element_node.dart';
import 'ring_diagram_painter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ElementNodeInputPage extends StatefulWidget {
  const ElementNodeInputPage({super.key});

  @override
  ElementNodeInputPageState createState() => ElementNodeInputPageState();
}

class ElementNodeInputPageState extends State<ElementNodeInputPage> {


  List<ElementNode> elementNodes = [];


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

  @override
  void initState() {
    super.initState();
    elementNodes.add(ElementNode(name: '', color: Colors.blue));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('メンバー入力')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: elementNodes.length,
              itemBuilder: (context, index) {
                final elementNode = elementNodes[index];
                final otherNames = elementNodes
                    .where((p) => p != elementNode && p.name.isNotEmpty)
                    .map((p) => p.name)
                    .toList();

                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration:
                              const InputDecoration(labelText: '名前'),
                          onChanged: (value) {
                            setState(() {
                              elementNode.name = value;
                              bool isLast = index == elementNodes.length - 1;
                              if (value.isNotEmpty && isLast) {
                                addElementNode();
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: elementNode.target,
                          hint: const Text('対象を選択'),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('無選択'),
                            ),
                            ...otherNames.map(
                              (name) => DropdownMenuItem(
                                value: name,
                                child: Text(name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => elementNode.target = value);
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.color_lens, color: elementNode.color),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              Color tempColor = elementNode.color;
                              return AlertDialog(
                                title: const Text('色を選択'),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: tempColor,
                                    onColorChanged: (color) {
                                      tempColor = color;
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      setState(() {
                                        elementNode.color = tempColor;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          removeElementNode(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 300,
            child: CustomPaint(
              painter: RingDiagramPainter(elementNodes),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
  final List<Color> defaultColors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  ];
}
