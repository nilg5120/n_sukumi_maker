import 'package:flutter/material.dart';
import 'person.dart';
import 'ring_diagram_painter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PeopleInputPage extends StatefulWidget {
  const PeopleInputPage({super.key});

  @override
  PeopleInputPageState createState() => PeopleInputPageState();
}

class PeopleInputPageState extends State<PeopleInputPage> {
  final List<Color> defaultColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  List<Person> people = [];

  void addPerson() {
    setState(() {
      final color = defaultColors[people.length % defaultColors.length];
      people.add(Person(name: '', color: color));
    });
  }

  void removePerson(int index) {
    setState(() {
      people.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    people.add(Person(name: '', color: Colors.blue));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('メンバー入力')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: people.length,
              itemBuilder: (context, index) {
                final person = people[index];
                final otherNames = people
                    .where((p) => p != person && p.name.isNotEmpty)
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
                              person.name = value;
                              bool isLast = index == people.length - 1;
                              if (value.isNotEmpty && isLast) {
                                addPerson();
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: person.target,
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
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          removePerson(index);
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
              painter: RingDiagramPainter(people),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}
