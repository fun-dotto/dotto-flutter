# Dotto Feature

Dotto アプリは、公立はこだて未来大学の情報をまとめたアプリです。以下の Feature で構成されています。

## Feature 一覧

### Home

![Architecture](https://img.shields.io/badge/Architecture-MVVM+UseCase-green.svg)

ホーム画面を提供する Feature です。

- 時間割の表示（2 週間表示対応）
- バス情報の表示
- Funch（学食）メニューの表示
- 学年暦・時間割 PDF の表示
- プッシュ通知からのお知らせ表示

### Announcement

![Architecture](https://img.shields.io/badge/Architecture-MVVM+UseCase-green.svg)
![DataSource](https://img.shields.io/badge/Data_Source-Dotto_API-green.svg)

お知らせ機能を提供する Feature です。

- Firebase からお知らせ情報を取得
- お知らせ一覧の表示
- プッシュ通知からのお知らせ URL の処理

### Assignment

![Architecture](https://img.shields.io/badge/Architecture-None-red.svg)
![DataSource](https://img.shields.io/badge/Data_Source-Firebase-red.svg)

課題管理機能を提供する Feature です。

- HOPE 連携による課題情報の取得
- 課題一覧の表示（科目ごとにグループ化）
- 課題の完了/未完了状態の管理
- 課題の非表示機能
- 締切 1 日前の通知機能
- 課題の通知 ON/OFF 機能

### Bus

![Architecture](https://img.shields.io/badge/Architecture-None-red.svg)
![DataSource](https://img.shields.io/badge/Data_Source-Firebase-red.svg)

バス時刻表機能を提供する Feature です。

- 未来大と最寄りバス停間のバス時刻表の表示
- 平日/土日の切り替え
- 出発地/目的地の切り替え
- 最寄りバス停の設定
- リアルタイムでのバス情報の更新（ポーリング）
- 到着予定時刻の表示

### Funch

![Architecture](https://img.shields.io/badge/Architecture-None-red.svg)
![DataSource](https://img.shields.io/badge/Data_Source-Transfering-yellow.svg)

学食メニュー機能を提供する Feature です。

- 日付ごとの学食メニューの表示
- カテゴリー別のメニュー表示（主食、主菜、副菜、汁物など）
- 日付選択機能
- 価格情報の表示

### GitHub Contributor

![Architecture](https://img.shields.io/badge/Architecture-MVVM+UseCase-green.svg)
![DataSource](https://img.shields.io/badge/Data_Source-GitHub_API-green.svg)

Dotto モバイルアプリの開発者一覧を表示する機能です。

### Map

![Architecture](https://img.shields.io/badge/Architecture-MVVM+UseCase-green.svg)
![DataSource](https://img.shields.io/badge/Data_Source-Firebase-red.svg)

キャンパスマップ機能を提供する Feature です。

- キャンパスマップの表示
- フロアの切り替え
- 教室・施設の検索
- 日付・時限に応じた使用中教室の表示
- マップの凡例表示

### Search Course

![Architecture](https://img.shields.io/badge/Architecture-MVVM+UseCase-green.svg)
![DataSource](https://img.shields.io/badge/Data_Source-Local-red.svg)

科目検索機能を提供する Feature です。

- 科目名での検索
- 条件による絞り込み（開講時期、曜日、時限など）
- 検索結果の表示
- 科目詳細画面への遷移

### Setting

![Architecture](https://img.shields.io/badge/Architecture-None-red.svg)

設定画面を提供する Feature です。

- Google アカウントでのログイン/ログアウト
- 学年・コースの設定
- HOPE 連携の設定
- お知らせ画面への遷移
- フィードバック送信
- アプリの使い方（チュートリアル）
- 利用規約・プライバシーポリシー
- ライセンス情報の表示

### Timetable

![Architecture](https://img.shields.io/badge/Architecture-MVVM+UseCase-green.svg)
![DataSource](https://img.shields.io/badge/Data_Source-Firebase-red.svg)

時間割機能を提供する Feature です。

- 時間割の編集（科目の追加・削除）
- 時間割の表示（表形式・リスト形式の切り替え）
- 前期・後期の切り替え
- 休講・補講情報の表示
- 時刻表示の ON/OFF

### Kamoku Detail

![Architecture](https://img.shields.io/badge/Architecture-None-red.svg)
![DataSource](https://img.shields.io/badge/Data_Source-Firebase-red.svg)

科目詳細画面を提供する Feature です。

- シラバス情報の表示
- 科目レビューの表示
- 過去問情報の表示
- タブによる情報の切り替え

## Feature の構造

各 Feature は以下のような構造になっています。

```
feature/
  {feature_name}/
    {feature_name}_screen.dart      # Screen (View)
    {feature_name}_viewmodel.dart   # ViewModel
    {feature_name}_usecase.dart     # UseCase
    widget/                         # Feature 固有の Widget
```

詳細なアーキテクチャについては、[アーキテクチャ](02_Architecture.md) を参照してください。

&copy; 2025 Dotto
