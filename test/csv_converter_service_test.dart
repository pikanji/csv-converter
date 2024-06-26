import 'dart:io';
import 'package:charset/charset.dart'; // for shiftJis

import 'package:csv_converter/services/csv_converter_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MyNavi CSV is converted into TalentPalette CSV format', () {
    // Arrange
    var fixtureDirPath = '${Directory.current.path}/test/fixtures';
    final File fileInput = File('$fixtureDirPath/csv_mynavi_input.csv');

    // Use Synchronous version of readAsBytes,
    // because readAsBytes never returns somehow.
    // Ref: https://stackoverflow.com/q/64031671/1646699
    var bytesInput = fileInput.readAsBytesSync();
    // Assuming input file is encoded as Shift-JIS
    var decodedCsv = shiftJis.decode(bytesInput);

    // Replace characters incompatible in shift-jis
    // FULL-WIDTH HYPHEN-MINUS '－' (U+FF0D) -> EM DASH '—' (U+2014)
    decodedCsv = decodedCsv.replaceAll('－', '—');
    // MINUS SIGN '−' (U+2212) -> EM DASH '—' (U+2014)
    decodedCsv = decodedCsv.replaceAll('−', '—');

    var csvDataInput = decodedCsv;


    // Act
    var csvDataResult = CsvConverterService.convertCsvFormat(csvDataInput);


    // Assert
    var csvDataResultShiftJis = Uint8List.fromList(shiftJis.encode(csvDataResult));

    final File fileExpected = File('$fixtureDirPath/csv_mynavi_converted.csv');
    var bytesExpected = fileExpected.readAsBytesSync();

    expect(listEquals(csvDataResultShiftJis, bytesExpected), true);
  });
}