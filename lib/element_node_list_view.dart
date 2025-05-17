import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'element_node.dart';

class ElementNodeListView extends StatelessWidget {
  final List<ElementNode> elementNodes;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  const ElementNodeListView({
    super.key,
    required this.elementNodes,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
              // 名前入力フィールド
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: '名前'),
                  onChanged: (value) {
                    if (value.trim().isEmpty) return;
                    final nameExists = elementNodes.any((node) =>
                        node != elementNode && node.name == value.trim());
                    if (nameExists) return;

                    elementNode.name = value.trim();
                    final isLast = index == elementNodes.length - 1;
                    if (value.isNotEmpty && isLast) onAdd();
                  },
                ),
              ),

              // 追加ボタン
              const SizedBox(width: 10),

              // 対象選択ドロップダウン
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
                  onChanged: (value) => elementNode.target = value,
                ),
              ),

              // 色選択ボタン
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
                            onColorChanged: (color) => tempColor = color,
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              elementNode.color = tempColor;
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              // 削除ボタン
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onRemove(index),
              ),
            ],
          ),
        );
      },
    );
  }
}
