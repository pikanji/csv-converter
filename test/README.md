# Unit Test
## Running Unit Tests
### Add Run Configuration in Android Studio
* Open "Run/Debug Configuration" from "Run" menu -> "Edit Configurations..."
* Click "+" on the top left of the dialog and select "Flutter test"
* Select "All in directory" for "Test Scope".
* Select `/test` directory in "Test directory" and save.
* Select this run configuration just created and run. 

## Sample Test
```dart: widget_test.dart
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:csv_converter/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
```

## Measure Test Coverage
参考: https://zenn.dev/o_ku/articles/68a34c428c5b65

```shell
flutter test --branch-coverage
```
`--branch-coverage`オプションをつけてテストを実行すると `coverage/lcov.info` というファイルがlocalに生成される。
これを`lcov`を使ってHTMLに変換する。

`lcov`はMacの場合、Homebrew経由でインストールできます。
```shell
brew install lcov
```

HTMLに変換する
```shell
genhtml coverage/lcov.info -o coverage/html --branch-coverage
```
コマンドを実行したディレクトリに`coverage/html/index.html`が生成される。

TODO: 条件網羅のカバレッジも出したい
TODO: カバーされていない分岐や、条件を簡単に確認するにはどうしたら良いのか？
