import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';

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
        var outputFilePaths = await CsvConverterService.convertCsvFiles(detail.files);
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
}
