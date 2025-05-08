import 'package:flutter/material.dart';
import 'element_node.dart';
import 'ring_diagram_painter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// エレメントノードの入力ページ
class ElementNodeInputPage extends StatefulWidget {
  const ElementNodeInputPage({super.key});

  @override
  ElementNodeInputPageState createState() => ElementNodeInputPageState();
}

/// ElementNodeInputPage の状態を管理する State クラス
/// ユーザーが ElementNode を追加・削除・編集できる機能を提供
class ElementNodeInputPageState extends State<ElementNodeInputPage> {

  /// 現在入力されている ElementNode（エレメントノード）のリスト。
  List<ElementNode> elementNodes = [];

  /// デフォルトカラーを設定した空の ElementNode をリストに追加し、UI を更新する。
  void addElementNode() {
    setState(() {
      final color = defaultColors[elementNodes.length % defaultColors.length];
      elementNodes.add(ElementNode(name: '', color: color));
    });
  }

  /// 指定したインデックスの ElementNodeを削除し、UI を更新する。
  void removeElementNode(int index) {
    setState(() {
      elementNodes.removeAt(index);
    });
  }

  /// 初期化時
  @override
  void initState() {
    super.initState();
    // 最初のエレメントノードを追加する
    elementNodes.add(ElementNode(name: '', color: Colors.blue));
  }

  /// UI を構築する。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('nすくみメーカー')),
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
                      /// ElementNode の名前を入力するテキストフィールド。
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: '名前'),
                          onChanged: (value) {
                            setState(() {
                              // 空文字なら何もしない
                              if (value.trim().isEmpty) return;

                              // 同じ名前がすでに他のノードに存在するかチェック
                              final nameExists = elementNodes.any((node) =>
                                  node != elementNode && node.name == value.trim());

                              if (nameExists) {
                                return;
                              }

                              elementNode.name = value.trim();

                              bool isLast = index == elementNodes.length - 1;
                              if (value.isNotEmpty && isLast) {
                                addElementNode();
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      /// 他の ElementNode を対象として選択するプルダウンメニュー。
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
                      /// ElementNode の色を選択するボタン。
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
                      /// ElementNode を削除するボタン。
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
            height: 400,  // 必要に応じて大きく
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: CustomPaint(
                painter: RingDiagramPainter(elementNodes),
                child: Container(), // 必須
              ),
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
