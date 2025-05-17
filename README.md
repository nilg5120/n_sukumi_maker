# n_sukumi_maker
    「Nすくみ」構造（例：グー・チョキ・パーや 火・水・草など）を可視化・編集できる Flutter アプリです。
    矢印で相性関係を描画し、相互関係を図式化します。

## 目的
Flutterの学習用に作成したアプリです。

## 主な機能
- ノード（要素）の追加・削除・名前変更
- 相手ノード（target）の指定による矢印描画
- ノードの色変更
- ピンチイン・ピンチアウトによる拡大縮小
- グループに基づいたノードの自動レイアウト

## 開発環境

- Flutter SDK: 3.x.x
- Dart: 3.x.x
- VS Code

## 必要なパッケージ
```bash

flutter pub get
```
## ビルド方法（APK作成）

```bash

flutter build apk --release
```

## テストの実行

```bash

flutter test --coverage
```
