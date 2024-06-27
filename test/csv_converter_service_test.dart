import 'dart:io';
import 'package:csv_converter/services/csv_converter_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MyNavi CSV is converted into TalentPalette CSV format', () {
    // Arrange
    var fixtureDirPath = '${Directory.current.path}/test/fixtures';
    final File fileInput = File('$fixtureDirPath/csv_mynavi_input.csv');
    // Use Synchronous version of readAsBytes, because readAsBytes never
    // returns somehow. Ref: https://stackoverflow.com/q/64031671/1646699
    var bytesInput = fileInput.readAsBytesSync();

    // Act
    var csvDataResultShiftJis = CsvConverterService.convertCsvFormatShiftJis(bytesInput);

    // Assert
    final File fileExpected = File('$fixtureDirPath/csv_mynavi_converted.csv');
    var bytesExpected = fileExpected.readAsBytesSync();
    expect(listEquals(csvDataResultShiftJis, bytesExpected), true);
  });
}