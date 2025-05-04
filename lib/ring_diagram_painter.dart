import 'package:flutter/material.dart';
import 'dart:math';
import 'element_node.dart';

/// ElementNode のリストをもとに、
/// 各ノードを円環状に配置し、
/// それぞれの target（対象）に向かって矢印を描画するカスタムペインター。
class RingDiagramPainter extends CustomPainter {
  final List<ElementNode> elementNode;
  /// 描画する ElementNode のリストを受け取る。
  RingDiagramPainter(this.elementNode);

  /// キャンバスにノードと矢印を描画する。
  /// - 名前が入力されているノードのみ対象。
  /// - グループごとに円の半径を変えて描画。
  /// - ノード同士の接続（target）には矢印を描く。
  /// - [canvas]: 描画対象のキャンバス。
  /// - [size]: 描画領域のサイズ。
  @override
  void paint(Canvas canvas, Size size) {
    /// 名前が入力されているノードだけを抽出。
    final validElementNode = elementNode.where((p) => p.name.isNotEmpty).toList();

    if (validElementNode.isEmpty) return;

    /// ノードをグループ（つながっているノード群）に分類。
    final groupMap = groupElementNode(validElementNode);

    /// グループIDごとにノードをまとめる。
    final groups = <int, List<ElementNode>>{};
    for (var person in validElementNode) {
      final gid = groupMap[person.name]!;
      groups.putIfAbsent(gid, () => []).add(person);
    }

    /// 各グループごとに円周上にノードを配置し、
    /// 名前のテキストと色付きの円を描く。
    final center = size.center(Offset.zero);
    final baseRadius = 80.0;
    final radiusStep = 60.0;
    final positions = <String, Offset>{};

    // 各グループ（つながりのあるノードの集まり）ごとに配置と描画を行う。
    groups.forEach((groupId, groupMembers) {
      // このグループの円の半径（グループIDによって外側へずらす）
      final radius = baseRadius + groupId * radiusStep;

      // ノードを円周上に等間隔で配置するための角度ステップ
      final angleStep = 2 * pi / groupMembers.length;

      for (int i = 0; i < groupMembers.length; i++) {
        final person = groupMembers[i];

        // 円周上の配置角度（12時方向から時計回り）
        final angle = angleStep * i - pi / 2;

        // このノードのx座標とy座標（中心点からのオフセット）
        final dx = center.dx + radius * cos(angle);
        final dy = center.dy + radius * sin(angle);
        final offset = Offset(dx, dy);

        // ノード名と位置を記録（あとで矢印を描くため）
        positions[person.name] = offset;

        // ノード（円）を描画
        canvas.drawCircle(offset, 20, Paint()..color = person.color);

        // ノード名のテキストを描画（中央揃え）
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

    // 各ノードについて、target（対象）が設定されていれば線と矢印を描画
    for (final person in validElementNode) {
      // 出発点（from）の座標
      final from = positions[person.name];

      // 対象ノード名
      final toName = person.target;

      // 出発点または対象が未設定ならスキップ
      if (from == null || toName == null) continue;

      // 到達点（to）の座標
      final to = positions[toName];

      if (to == null) continue;

      // from → to へのベクトル（方向）
      final direction = (to - from);

      // ベクトルの長さ（距離）
      final distance = direction.distance;

      // ベクトルに直交する（90度横向き）単位ベクトル
      final normal = Offset(direction.dy, -direction.dx) / distance;

      // 線を少し横にずらす量（重なりを避けるため）
      const offsetAmount = 8.0;

      // ずらしベクトル
      final offsetVector = normal * offsetAmount;

      // 出発点と到達点をオフセット（ずらす）
      final fromOffset = from + offsetVector;
      final toOffset = to + offsetVector;

      // 線を描画
      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2;

      canvas.drawLine(fromOffset, toOffset, paint);

      // 矢印の先端（三角形）を描画
      drawArrowHead(canvas, fromOffset, toOffset);
    }
  }

  /// [from] から [to] に向かう矢印の先端（三角形）を描画する。
  ///
  /// - [canvas]: 描画対象のキャンバス。
  /// - [from]: 矢印の始点。
  /// - [to]: 矢印の終点（矢印ヘッドの位置）。
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


  /// [elementNode] リストが変更されていれば再描画する。
  ///
  /// - [oldDelegate]: 前回の描画時の状態
  /// - 戻り値: もし異なっていれば true（再描画）を返す。
  @override
  bool shouldRepaint(covariant RingDiagramPainter oldDelegate) {
    return oldDelegate.elementNode != elementNode;
  }


  /// ノード同士の接続（target）をたどり、
  /// つながっているノードを同じグループIDに分類する。
  ///
  /// - [elementNodes]: 分類対象のノードリスト。
  /// - 戻り値: ノード名（String）とそのグループID（int）のマップ。
  Map<String, int> groupElementNode(List<ElementNode> elementNodes) {
    /// グループIDを記録するマップ: 名前 → グループID
    Map<String, int> groupMap = {};

    /// 現在割り当てるグループID（0 から始まる）
    int groupId = 0;

    /// DFS（深さ優先探索）で target をたどる関数。
    /// まだグループが割り当てられていないノードに groupId を割り当てる。
    /// 
    /// - [name]: で指定されたノード
    void dfs(String name) {
      for (var elementNode in elementNodes) {

        // ① このノードから他のノードに向かうリンクをたどる
        if (elementNode.name == name) {
          final targetName = elementNode.target;
          if (targetName != null && !groupMap.containsKey(targetName)) {
            groupMap[targetName] = groupId;
            dfs(targetName);
          }
        }

        // ② 他のノードからこのノードに向かうリンクをたどる
        if (elementNode.target == name && !groupMap.containsKey(elementNode.name)) {
          groupMap[elementNode.name] = groupId;
          dfs(elementNode.name);
        }
      }
    }

    // すべてのノードをチェック
    for (var elementNode in elementNodes) {
      if (elementNode.name.isEmpty) continue; // 名前がないノードはスキップ

      // まだグループIDが付いていなければ、新しいグループIDを割り当てて探索開始
      if (!groupMap.containsKey(elementNode.name)) {
        groupMap[elementNode.name] = groupId;
        dfs(elementNode.name);
        groupId++; // 次のグループIDに進む
      }
    }
    return groupMap;
  }

}
