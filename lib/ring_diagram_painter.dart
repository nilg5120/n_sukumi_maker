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
    final validElementNodes = elementNode.where((p) => p.name.isNotEmpty).toList();

    if (validElementNodes.isEmpty) return;

    /// ノードをグループ（つながっているノード群）に分類。
    final groupMap = groupElementNode(validElementNodes);

    /// グループIDごとにノードをまとめる。
    final groups = <int, List<ElementNode>>{};
    for (var elementNode in validElementNodes) {
      final gid = groupMap[elementNode.name]!;
      groups.putIfAbsent(gid, () => []).add(elementNode);
    }

    /// 各グループごとに円周上にノードを配置し、
    /// 名前のテキストと色付きの円を描く。
    final center = size.center(Offset.zero);
    final positions = <String, Offset>{};


    // 横・縦の間隔
    final horizontalStep = 200.0; // グループごとの横の間隔

    // 各グループ（つながりのあるノードの集まり）ごとに配置と描画を行う。
    final totalGroups = groups.length;

    groups.forEach((groupId, groupMembers) {
      // グループごとの中心x座標（中央揃え）
      final groupCenterX =
          center.dx + (groupId - (totalGroups - 1) / 2) * horizontalStep;

      // グループごとの中心y座標（画面中央）
      final groupCenterY = center.dy;

      // グループ内の円の半径（ノード数によって自動調整 or 固定）
      final radius = 40.0 + groupMembers.length * 15.0;

      // ノードを円周上に等間隔で配置するための角度ステップ
      final angleStep = 2 * pi / groupMembers.length;

      for (int i = 0; i < groupMembers.length; i++) {
        final elementNode = groupMembers[i];

        // ノードの角度
        final angle = angleStep * i - pi / 2;

        // ノードのx,y座標（グループ中心からのオフセット）
        final dx = groupCenterX + radius * cos(angle);
        final dy = groupCenterY + radius * sin(angle);

        final offset = Offset(dx, dy);

        // ノード名と位置を記録（あとで矢印を描くため）
        positions[elementNode.name] = offset;

        // ノード（円）を描画
        canvas.drawCircle(offset, 20, Paint()..color = elementNode.color);

        // ノード名のテキストを描画（中央揃え）
        final textSpan = TextSpan(
          text: elementNode.name,
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
    for (final person in validElementNodes) {
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


  /// [from] から [to] に向かう矢印ヘッド（三角形）の頂点座標を計算。
  /// - [arrowSize]: 矢印ヘッドのサイズ。
  /// - [from]: 矢印の始点。
  /// - [to]: 矢印の終点（矢印ヘッドの位置）。
  /// - 戻り値: 矢印ヘッドの頂点座標リスト。
  List<Offset> calculateArrowHeadPoints(Offset from, Offset to, double arrowSize) {
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);
    return [
      to,
      Offset(
        to.dx - arrowSize * cos(angle - pi / 6),
        to.dy - arrowSize * sin(angle - pi / 6),
      ),
      Offset(
        to.dx - arrowSize * cos(angle + pi / 6),
        to.dy - arrowSize * sin(angle + pi / 6),
      ),
    ];
  }

  /// [from] から [to] に向かう矢印の先端（三角形）を描画する。
  ///
  /// - [canvas]: 描画対象のキャンバス。
  /// - [from]: 矢印の始点。
  /// - [to]: 矢印の終点（矢印ヘッドの位置）。
  void drawArrowHead(Canvas canvas, Offset from, Offset to) {
    const arrowSize = 10.0;
    final points = calculateArrowHeadPoints(from, to, arrowSize);

    final path = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..lineTo(points[1].dx, points[1].dy)
      ..lineTo(points[2].dx, points[2].dy)
      ..close();

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
