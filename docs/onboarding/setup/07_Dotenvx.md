# dotenvxとpre-commitのセットアップ
## 分からなければ先輩に聞いて下さい

mise経由でdotenvxとpre-commitをインストールする

```
task install-all
```

## .env.keysファイルのセットアップ

`.env.keys`ファイルは，暗号化された環境変数を復号化するために必要なキーファイルです

### 取得方法

既存のチームメンバーから`.env.keys`ファイルを共有してもらってください

### 配置場所

取得した`.env.keys`ファイルを以下の2箇所に配置してください：

1. **プロジェクトルート** (`.env.keys`)
2. **iOS Fastlaneディレクトリ** (`ios/fastlane/.env.keys`)

### 重要事項

- `.env.keys`ファイルは**絶対にバージョン管理にコミットしないでください**
- このファイルは既に`.gitignore`に含まれていますが、誤ってコミットしようとするとpre-commitフックでブロックされます

## 環境変数の操作

環境変数を追加したいときは以下を実行
既にあるKEYを指定すると更新可能
```
dotenvx set KEY "value" -f [環境変数ファイルパス]
```

平文を見たいときは以下を実行
```
dotenvx decrypt --stdout -f [環境変数ファイルパス] > .env.decrypted
```
