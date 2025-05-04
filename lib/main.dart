import 'package:flutter/material.dart';
import 'dart:math'; // 三角関数などを使うため
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() =>
    runApp(MaterialApp(home: PeopleInputPage())); // エントリーポイント（main関数）

// メイン画面のStatefulWidget（状態を持つ画面）
class PeopleInputPage extends StatefulWidget {
  const PeopleInputPage({super.key});

  @override
  PeopleInputPageState createState() => PeopleInputPageState();
}

// Stateクラス（状態とUIロジックを保持）
class PeopleInputPageState extends State<PeopleInputPage> {
  final List<Color> defaultColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  List<Person> people = []; // 入力された人物のリスト

  // 新しい人を追加する関数
  void addPerson() {
    setState(() {
      final color = defaultColors[people.length % defaultColors.length];
      people.add(Person(name: '', color: color));
    });
  }

  void removePerson(int index) {
    setState(() {
      people.removeAt(index); // インデックス指定で削除
    });
  }

  @override
  void initState() {
    super.initState();
    // 最初から空の1人を追加しておく
    people.add(Person(name: '', color: Colors.blue));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Flutterでの画面構成の基本Widget
      appBar: AppBar(title: Text('メンバー入力')),
      body: Column(
        children: [
          // 入力欄一覧
          Expanded(
            child: ListView.builder(
              itemCount: people.length,
              itemBuilder: (context, index) {
                final person = people[index];

                // 自分以外の名前リスト（対象選択肢用）
                final otherNames =
                    people
                        .where((p) => p != person && p.name.isNotEmpty)
                        .map((p) => p.name)
                        .toList();

                return ListTile(
                  title: Row(
                    children: [
                      // 名前の入力欄
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(labelText: '名前'),
                          onChanged: (value) {
                            setState(() {
                              person.name = value;

                              // 名前が入力されたら、自動で新しい空欄を追加
                              bool isLast = index == people.length - 1;
                              if (value.isNotEmpty && isLast) {
                                people.add(
                                  Person(name: '', color: Colors.blue),
                                );
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      // 対象選択（プルダウン）
                      Expanded(
                        child: DropdownButton<String>(
                          value: person.target,
                          hint: Text('対象を選択'),
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
                            setState(() => person.target = value);
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.color_lens, color: person.color),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              Color tempColor = person.color;
                              return AlertDialog(
                                title: Text('色を選択'),
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
                                    child: Text('OK'),
                                    onPressed: () {
                                      setState(() {
                                        person.color = tempColor;
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
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          removePerson(index); // 対応するインデックスを削除
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ★ 代わりに、常に CustomPaint を表示！
          SizedBox(
            height: 300,
            child: CustomPaint(
              painter: RingDiagramPainter(people),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

// データモデルクラス（JavaでいうPOJO）
class Person {
  String name;
  Color color;
  String? target; // 対象となる他人の名前（null可）

  Person({required this.name, required this.color, this.target});
}

// CustomPainter を使って UI に直接描画
class RingDiagramPainter extends CustomPainter {
  final List<Person> people;
  RingDiagramPainter(this.people);

  @override
  void paint(Canvas canvas, Size size) {
    // ★ 有効な（名前が空でない）peopleだけ使う！
    final validPeople = people.where((p) => p.name.isNotEmpty).toList();

    if (validPeople.isEmpty) return; // 一人もいなければ描画しない

    final groupMap = groupPeople(validPeople); // ★ validPeopleに変更！

    // グループごとにまとめる
    final groups = <int, List<Person>>{};
    for (var person in validPeople) {
      final gid = groupMap[person.name]!;
      groups.putIfAbsent(gid, () => []).add(person);
    }

    final center = size.center(Offset.zero);
    final baseRadius = 80.0;
    final radiusStep = 60.0;
    final positions = <String, Offset>{};

    // グループごとに描画
    groups.forEach((groupId, groupMembers) {
      final radius = baseRadius + groupId * radiusStep;
      final angleStep = 2 * pi / groupMembers.length;

      for (int i = 0; i < groupMembers.length; i++) {
        final person = groupMembers[i];
        final angle = angleStep * i - pi / 2;
        final dx = center.dx + radius * cos(angle);
        final dy = center.dy + radius * sin(angle);
        final offset = Offset(dx, dy);

        positions[person.name] = offset;

        canvas.drawCircle(offset, 20, Paint()..color = person.color);

        final textSpan = TextSpan(
          text: person.name,
          style: TextStyle(color: Colors.white),
        );
        final tp = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
      }
    });

    // 矢印描画
    for (final person in validPeople) {
      final from = positions[person.name];
      final toName = person.target;
      if (from == null || toName == null) continue;
      final to = positions[toName];
      if (to == null) continue;

      final direction = (to - from);
      final distance = direction.distance;
      final normal = Offset(direction.dy, -direction.dx) / distance;
      const offsetAmount = 8.0;
      final offsetVector = normal * offsetAmount;
      final fromOffset = from + offsetVector;
      final toOffset = to + offsetVector;

      final paint =
          Paint()
            ..color = Colors.black
            ..strokeWidth = 2;

      canvas.drawLine(fromOffset, toOffset, paint);
      drawArrowHead(canvas, fromOffset, toOffset);
    }
  }

  void drawArrowHead(Canvas canvas, Offset from, Offset to) {
    const arrowSize = 10.0;
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);

    final path = Path();
    path.moveTo(to.dx, to.dy);
    path.lineTo(
      to.dx - arrowSize * cos(angle - pi / 6),
      to.dy - arrowSize * sin(angle - pi / 6),
    );
    path.lineTo(
      to.dx - arrowSize * cos(angle + pi / 6),
      to.dy - arrowSize * sin(angle + pi / 6),
    );
    path.close();

    final paint = Paint()..color = Colors.black;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Map<String, int> groupPeople(List<Person> people) {
    Map<String, int> groupMap = {}; // 名前 -> グループ番号
    int groupId = 0;

    void dfs(String name) {
      for (var person in people) {
        if (person.name == name) {
          final targetName = person.target;
          if (targetName != null && !groupMap.containsKey(targetName)) {
            groupMap[targetName] = groupId;
            dfs(targetName);
          }
        }
        if (person.target == name && !groupMap.containsKey(person.name)) {
          groupMap[person.name] = groupId;
          dfs(person.name);
        }
      }
    }

    for (var person in people) {
      if (person.name.isEmpty) continue; // 🆕 名前空は無視
      if (!groupMap.containsKey(person.name)) {
        groupMap[person.name] = groupId;
        dfs(person.name);
        groupId++;
      }
    }

    return groupMap;
  }
}
