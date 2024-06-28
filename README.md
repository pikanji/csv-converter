# csv_converter

Generate a CSV file in one format from a CSV in another format.
Currently this project is only for Windows desktop app.
Desktop version processes CSV files on the local machine and does not upload to anywhere.

## Setting Up Local Development Environment
Get source code.
```shell
git clone https://github.com/pikanji/csv-converter.git
```

Open in Android Studio.
Open SDK manager. (You can use search feature of Android Studio to open it.)
In SDK manager, select "Flutter" from side menu and specify "Flutter SDK path".

## Coding Standard
### Style Guide
Follow [Style guide for Flutter repo](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo).

## Windowsプロジェクト
### Windowsターゲット有効化
Windows用にビルド可能にするには、下記を一度だけプロジェクトディレクトリ内で実行する。
```
flutter config --enable-windows-desktop
```
これでAndroid StudioのビルドターゲットデバイスにWindowsが表示されるはず。

### リリース
#### リリース用のビルド作成
Windowsのターミナルで `flutter build windows` を実行すると、
`/build/windows/x64/runner/Release`に下記が生成される。
* dataディレクトリ
* アプリ本体のexeファイル
* desktop_drop_plugin.dll
* flutter_windows.dll

#### 配布用Zip作成
上記の`/build/windows/x64/runner/Release`内の全てに
`C:\Windows\System32`にある以下3つのファイルをコピーして追加する。
* msvcp140.dll
* vcruntime140.dll
* vcruntime140_1.dll

これをzip化して配布する。
利用者は、このzipを展開して、exeファイルを実行するだけ。
