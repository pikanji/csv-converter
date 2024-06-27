import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;

import '../services/csv_converter_service.dart';

class CsvConverterDragTarget extends StatefulWidget {
  const CsvConverterDragTarget({super.key});

  @override
  _CsvConverterDragTargetState createState() => _CsvConverterDragTargetState();
}

class _CsvConverterDragTargetState extends State<CsvConverterDragTarget> {
  String _message = '';
  bool _dragging = false;
  Offset? offset;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async {
        setState(() {
          _message = '${detail.files.map((e) => e.path).join('\n')}\nを変換しています・・・\n\n';
        });
        var outputFilePaths = await _convertCsvFiles(detail.files);
        setState(() {
          _message += '以下に出力しました\n${outputFilePaths.join('\n')}';
        });
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
        color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.white70,
        child: Stack(
          children: [
            _message.isEmpty
                ? const Center(child: Text("CSVファイルをここへドロップ"))
                : Text(_message, style: Theme.of(context).textTheme.bodyMedium),
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

  /// Returns a list of filepath of output files.
  static Future<List<String>> _convertCsvFiles(List<XFile> files) async {
    List<String> outputFilePaths = [];
    for (final file in files) {
      var bytes = await file.readAsBytes();

      var shiftJisData = CsvConverterService.convertCsvFormatShiftJis(bytes);

      var outputFile = XFile.fromData(shiftJisData);
      var outputFilePath = '${p.dirname(file.path)}${p.separator}${p.basenameWithoutExtension(file.path)}_converted.csv';
      debugPrint('output file path: $outputFilePath');
      await outputFile.saveTo(outputFilePath);
      outputFilePaths.add(outputFilePath);
    }
    return outputFilePaths;
  }
}
