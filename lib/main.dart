import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:charset/charset.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleDragTarget(),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}



class ExampleDragTarget extends StatefulWidget {
  const ExampleDragTarget({Key? key}) : super(key: key);

  @override
  _ExampleDragTargetState createState() => _ExampleDragTargetState();
}

class _ExampleDragTargetState extends State<ExampleDragTarget> {
  final List<XFile> _list = [];

  bool _dragging = false;

  Offset? offset;

  /// Get value of CSV (given as List [row]) for the specified [key].
  /// The key-index map [keyIndex] is used to locate the data in the List.
  String getCsvValue(List<String> row, String key, Map<String, int> keyIndex) {
    var index = keyIndex[key];
    if (index == null) {
      // FIXME: Use specific exception
      throw Exception('Specified key "$key" does not exist.');
    }
    if (index >= row.length) {
      // FIXME: Use specific exception
      throw Exception('Row data has less column than keyIndex');
    }
    return row[index];
  }

  static const multiByteSpace = '　';

  // Columns of destination CSV format.
  static const outputColumns = [
    'アカウント','社員CD','社内名称','氏名（カナ）','性別','生年月日','入社日',
    '最新入社日','年齢','卒年','待遇学歴','待遇学歴年','役職','コース区分','エリア区分',
    '区分1','区分2','採用','非居住','雇用形態','障害区分［＊］','資格名称','勤務地略称',
    '所属名称','主務役割01','主務役割02','担当名称','部門区分','直間区分','等級［＊］',
    'キャリアステージ','勤続月数','予測残業時間','組織滞留年数','勤続期間','メールアドレス',
    'メールアドレス(緊急用)','住所','出勤状況','等級','責任階層','部門階層',
    '役割判定項目１','役割判定項目２','会社名称','アカウント','パスワード','エントリー日',
    '採用年度','卒業時期','氏名フリガナ','採用ステータス','採用ステータス更新日',
    '不合格メール配信日','採用拠点','クール','応募媒体','特別フラグ','対象校','郵便番号',
    '都道府県','休暇中住所_郵便番号','休暇中住所_都道府県','休暇中住所','携帯電話番号',
    '自宅電話番号','学校種別','学校名','学部名','学科名','文理区分','採用種別',
    '学歴・職歴','学科分類','専攻テーマ','所属ゼミ／研究室','所属ゼミ／研究室　研究内容',
    '資格・語学力','アルバイト','サークル','会社説明会','【ES】趣味・特技',
    '【ES】力を入れた学業','【ES】自己PR','【ES】学生時代の取り組み',
    '【ES】本人希望コース','【ES】興味のある職種','【ES】最寄駅',
    '【ES】オリエンタルモーターを知ったきっかけ','【ES】その他伝えたいこと',
    '【ES】ES提出日','【一次面接】合否判定','【一次面接】次回面接へ申送り事項',
    '【座談会】','【座談会】案内用','【二次面接】合否判定',
    '【二次面接】次回面接へ申送り事項','【人事面談】フラグ','【人事面談】メモ',
    '【Q-Dog】判定','【Q-Dog】ストレス自覚','【Q-Dog】ストレス耐性','【V-CAT】総合判定',
    '【V-CAT】持ち味','【V-CAT】メンタルヘルス','【最終面接】交通費支給フラグ',
    '【最終面接】交通費支払方法','【最終面接】交通費経路','【最終面接】交通費金額',
    '【最終面接】次回面接へ申送り事項','【最終面接】合否判定','個別対応-1','個別対応-2',
    '個別対応-3','個別対応-4','個別対応-5','合説・学内セミナー',
    '（GR営業）上野オフィス案内','（GR営業）拠点訪問案内-1','（GR営業）拠点訪問案内-2',
    '（GR営業）製造業WS','（GR営業）自己分析会','（GR営業）若手座談会',
    '（GR営業）営業体験','（GR営業）中堅座談会','（GR営業）選考前座談会',
    '（GR営業）内定者座談会','（GR営業）海外駐在員座談会','（GR営業）グローバル女子座談会',
    '（G技術）TGフラグ','（G技術）夏IS_モーター1day','（G技術）冬IS_仕事研究1day',
    '（G技術）マス向け_つくば見学','（G技術）内定者事業所見学未','（R）プレ活動（8〜11月）',
    '（R）プレ活動（12月〜2月）','（R）イベント（11月）','メモ','マイナビID',
    '人事からの申し送り','【内定者】内定通知日','【内定者】内定回答日','就活状況',
    '※未使用　希望職種','※未使用　希望勤務地','※未使用　最終学歴(短大・高校・専門・大学名)',
    '※未使用　長所','※未使用　短所','※未使用　一番の挑戦とその道のり','※未使用　志望動機',
    '※未使用　学生時代に学んだこと(研究/卒論テーマ)','※未使用　学生時代の努力と成果',
    '※未使用　失敗体験','※未使用　成功体験','※未使用　企業選びの軸',
    '※未使用　本人希望事項(勤務地・勤務形態・給与等)','※未使用　エージェント担当者名',
    '※未使用　興味のある業界','※未使用　エージェント名','※未使用　採用依頼',
    '※未使用　管理ID','※未使用　求人票','※未使用　追加時採用サイト','総合評価','志望動機',
    '態度・言葉づかい','身だしなみ・服装','マッチング度','協調性','積極性','自己表現能力',
    'コミュニケーション力'
  ];

  // indexToIndexMap: input index is List index, output index is the value
  List<dynamic> getIndexToIndexMap(int length) {
    var indexToIndexMap = List<dynamic>.generate(length, (index) => null);
    indexToIndexMap[0] = 138;
    // Returns [output col index, output value]
    indexToIndexMap[1] = (List<String> inputRow) => [2, '${inputRow[1]}$multiByteSpace${inputRow[2]}'];
    indexToIndexMap[3] = (List<String> inputRow) => [50, '${inputRow[3]}$multiByteSpace${inputRow[4]}'];
    // Returns [[output col index1, output col index2], output value]
    indexToIndexMap[5] = (List<String> inputRow) => [[35, 45], inputRow[5]];
    indexToIndexMap[7] = 4;
    indexToIndexMap[8] = 59;
    indexToIndexMap[9] = 60;
    indexToIndexMap[10] = 37;
    indexToIndexMap[15] = 65;
    indexToIndexMap[16] = 64;
    indexToIndexMap[17] = 61;
    indexToIndexMap[18] = 62;
    indexToIndexMap[19] = 63;
    indexToIndexMap[25] = 49;
    indexToIndexMap[26] = 66;
    indexToIndexMap[28] = 67;
    indexToIndexMap[30] = 68;
    indexToIndexMap[32] = 69;
    indexToIndexMap[35] = 70;
    indexToIndexMap[36] = 75;
    indexToIndexMap[37] = 74;
    indexToIndexMap[38] = 79;
    indexToIndexMap[52] = 54;
    indexToIndexMap[53] = 55;
    indexToIndexMap[54] = 56;
    indexToIndexMap[55] = 57;
    indexToIndexMap[56] = 58;
    indexToIndexMap[57] = 111;
    indexToIndexMap[58] = 112;
    indexToIndexMap[59] = 113;
    indexToIndexMap[60] = 114;
    indexToIndexMap[61] = 115;
    indexToIndexMap[62] = 116;
    indexToIndexMap[63] = 117;
    indexToIndexMap[64] = 118;
    indexToIndexMap[65] = 119;
    indexToIndexMap[66] = 120;
    indexToIndexMap[67] = 121;
    indexToIndexMap[68] = 122;
    indexToIndexMap[69] = 123;
    indexToIndexMap[70] = 124;
    indexToIndexMap[71] = 125;
    indexToIndexMap[72] = 126;
    indexToIndexMap[73] = 127;
    indexToIndexMap[74] = 128;
    indexToIndexMap[75] = 129;
    indexToIndexMap[77] = 130;
    indexToIndexMap[78] = 131;
    indexToIndexMap[79] = 132;
    indexToIndexMap[80] = 133;
    indexToIndexMap[81] = 134;
    indexToIndexMap[82] = 135;
    indexToIndexMap[83] = 136;
    indexToIndexMap[100] = 91;
    indexToIndexMap[107] = 95;
    indexToIndexMap[111] = 110;
    indexToIndexMap[112] = 140;
    indexToIndexMap[115] = 137;
    return indexToIndexMap;
  }

  void printOutputColumns() {
    var index = 0;
    for (final key in outputColumns) {
      debugPrint('$index: $key');
      index++;
    }
  }

  String convertCsvFormat(String inputCsv) {
    List<List<String>> inputRowsAsListOfValues =
      const CsvToListConverter().convert(inputCsv, shouldParseNumbers: false);

    // 118 is number of columns of MyNavi data
    var indexToIndexMap = getIndexToIndexMap(118);
    // Assert number of columns is the same with input data
    if (indexToIndexMap.length != inputRowsAsListOfValues.first.length) {
      throw Exception('Number of columns of input CSV and internal indexMap does not match!');
    }


    // // Generate mapping of column key and column number (0-indexed)
    List<String> header = inputRowsAsListOfValues.removeAt(0);
    // Map<String, int> keyIndex = {};
    // var index = 0;
    // for (final key in header) {
    //   debugPrint('$index: $key');
    //   keyIndex[key] = index++;
    // }

    List<List<String>> outputRowsAsListOfValues = [
      outputColumns, // Initially only header row
    ];

    // Read each entry
    for (final inputRow in inputRowsAsListOfValues) {
      // var str = getCsvValue(inputRow, "姓", keyIndex);

      List<String> outputRow = List.generate(
        outputColumns.length, (index) => '', growable: false,
      );

      var inputColIndex = 0;
      for (final inputValue in inputRow) {
        var outputColIndexInfo = indexToIndexMap[inputColIndex];
        if (outputColIndexInfo is int) {
          outputRow[outputColIndexInfo] = inputValue;
        } else if (outputColIndexInfo is Function) {
          List<dynamic> result = outputColIndexInfo(inputRow);
          if (result[0] is int) {
            outputRow[result[0]] = result[1];
          } else if (result[0] is List<int>) {
            for (final index in result[0]) {
              outputRow[index] = result[1];
            }
          } else {
            throw Exception('Function in indexToIndexMap returned invalid index');
          }

        }
        inputColIndex++;
      }
      outputRowsAsListOfValues.add(outputRow);
    }

    return const ListToCsvConverter().convert(outputRowsAsListOfValues);
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async {
        setState(() {
          _list.addAll(detail.files);
        });

        // printOutputColumns();

        debugPrint('onDragDone:');
        for (final file in detail.files) {

          debugPrint('  ${file.path} ${file.name}'
              '  ${await file.lastModified()}'
              '  ${await file.length()}'
              '  ${file.mimeType}');

          var bytes = await file.readAsBytes();
          // Assuming input file is encoded as Shift-JIS
          var decodedCsv = shiftJis.decode(bytes);
          debugPrint(shiftJis.decode(bytes));

          var resultCsv = convertCsvFormat(decodedCsv);
          debugPrint(resultCsv);

          var shiftJisData = Uint8List.fromList(shiftJis.encode(resultCsv));
          var outputFile = XFile.fromData(shiftJisData);
          var outputFilePath = '${p.dirname(file.path)}${p.separator}${p.basenameWithoutExtension(file.path)}_converted.csv';
          debugPrint('output file path: $outputFilePath');
          await outputFile.saveTo(outputFilePath);
        }
      },
      onDragUpdated: (details) {
        setState(() {
          offset = details.localPosition;
        });
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
          offset = detail.localPosition;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
          offset = null;
        });
      },
      child: Container(
        height: 200,
        width: 200,
        color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
        child: Stack(
          children: [
            if (_list.isEmpty)
              const Center(child: Text("Drop here"))
            else
              Text(_list.map((e) => e.path).join("\n")),
            if (offset != null)
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  '$offset',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
          ],
        ),
      ),
    );
  }
}
