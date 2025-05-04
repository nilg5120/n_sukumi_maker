import 'package:flutter/material.dart';
import 'dart:math';
import 'person.dart';

class RingDiagramPainter extends CustomPainter {
  final List<Person> people;
  RingDiagramPainter(this.people);

  @override
  void paint(Canvas canvas, Size size) {
    final validPeople = people.where((p) => p.name.isNotEmpty).toList();

    if (validPeople.isEmpty) return;

    final groupMap = groupPeople(validPeople);

    final groups = <int, List<Person>>{};
    for (var person in validPeople) {
      final gid = groupMap[person.name]!;
      groups.putIfAbsent(gid, () => []).add(person);
    }

    final center = size.center(Offset.zero);
    final baseRadius = 80.0;
    final radiusStep = 60.0;
    final positions = <String, Offset>{};

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

      final paint = Paint()
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
    Map<String, int> groupMap = {};
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
      if (person.name.isEmpty) continue;
      if (!groupMap.containsKey(person.name)) {
        groupMap[person.name] = groupId;
        dfs(person.name);
        groupId++;
      }
    }

    return groupMap;
  }
}
