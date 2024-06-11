import 'dart:io';
import 'package:excel/excel.dart';

class ExcelHelper {
  static void appendResultToExcel(Map<String, dynamic> result, String filePath) {
    print(result);
    Excel excel;
    File file = File(filePath);
    if (file.existsSync()) {
      var bytes = file.readAsBytesSync();
      excel = Excel.decodeBytes(bytes);
    } else {
      excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      sheetObject.appendRow(['userId', 'method', 'found', 'added', 'arguments']);
    }
    Sheet sheetObject = excel['Sheet1'];
    sheetObject.appendRow([result['userId'], result['method'], result['found'], result['added'], result['arguments']]);

    var fileBytes = excel.encode();
    if (fileBytes != null) {
      file
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  }
}
