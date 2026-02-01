# Dotto

リポジトリをクローンします。

```zsh
git clone git@github.com:fun-dotto/dotto.git
cd dotto
```

## ツールをインストール

```zsh
mise install
```

## Flutter をセットアップ

```zsh
flutter doctor --android-licenses
```

## Firebase のセットアップ

[Windows] デフォルトの設定で「スクリプトの実行」が禁止されているため、以下のコマンドで設定を変更します。

```pwsh
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

Firebase CLI をインストールします。

```zsh
npm install -g firebase-tools
```

Firebase CLI にログインします。

```zsh
firebase login
```

以下が出力された場合、どちらもEnterキーを押下して承諾します。

```
? Enable Gemini in Firebase features? (Y/n)
? Allow Firebase to collect CLI and Emulator Suite usage and error reporting information? (Y/n)
```

自動的にブラウザが起動したら、Dotto の Firebase プロジェクトに参加しているGoogleアカウントを選択してください。

Firebase のアプリ情報をセットアップします。

```zsh
dart pub global activate flutterfire_cli
```

```zsh
flutterfire configure
```

`.env.keys`ファイルをもらってください．詳細は[dotenvxとpre-commitのセットアップ](07_Dotenvx.md#envkeysファイルのセットアップ)を参照してください．

## プロジェクトをセットアップ

プロジェクトの依存関係のインストールをします。

```zsh
task install-all
```

必要なコードを生成します。

```zsh
task build-all
```

## [macOS] iOS Simulator で起動する

`Simulator.app`を起動します。

以下のコマンドを実行します。

```zsh
task run
```

## [macOS] iOS 端末で起動する

Mac と iPhone を接続します。

`.env.keys`ファイルも`ios/fastlane/`に配置する必要があります．詳細は[dotenvxとpre-commitのセットアップ](07_Dotenvx.md#envkeysファイルのセットアップ)を参照してください．

以下のコマンドを実行します。

```zsh
task match_development
```

```zsh
task run
```

## [macOS] Android Emulator で起動する

Visual Studio Code から Android エミュレータを起動します。

以下のコマンドを実行します。

```zsh
task run
```

q キーを押して、一度終了します。

以下のコマンドを実行して、証明書のフィンガープリントを取得します。

```zsh
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android
```

[Firebase](https://console.firebase.google.com/u/0/project/swift2023groupc/settings/general/android:jp.ac.fun.dotto?hl=ja)にアクセスして、表示された SHA-1 のフィンガープリントを登録する。

## [Windows] Android Emulator で起動する

Android Studio で使用されている Java があるフォルダのパスをコピーする。

Ex. `C:\Program Files\Android\Android Studio\jbr\bin`

```pwsh
set PATH=<コピーしたパスをペースト>;%PATH%
```

以下のコマンドを実行します。

```pwsh
task run
```

q キーを押して、一度終了します。

以下のコマンドを実行して、証明書のフィンガープリントを取得します。

```pwsh
keytool -list -v -alias androiddebugkey -keystore $env:USERPROFILE\.android\debug.keystore -storepass android
```

[Firebase](https://console.firebase.google.com/u/0/project/swift2023groupc/settings/general/android:jp.ac.fun.dotto?hl=ja)にアクセスして、表示された SHA-1 のフィンガープリントを登録する。

## Google アカウントでログイン

Dotto アプリに Google アカウントでログインします。

正常にログインできれば、オンボーディング完了です。

おつかれさまでした。
