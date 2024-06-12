import 'dart:io';
import 'package:biedronka_tests/time_test/time_helper.dart';
import 'package:excel/excel.dart';

class ExcelHelper {
  static void appendValidationResultToExcel(Map<String, dynamic> result, String filePath) {
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

  static void appendValidationResultToTime(int user, TimeAndMemoryResult timeAndMemory, String arguments,String method, String filePath) {
    print({"userId" : user, "time" : timeAndMemory.time, "memory" : timeAndMemory.memory, "method": method,"arguments" : arguments});
    Excel excel;
    File file = File(filePath);
    if (file.existsSync()) {
      var bytes = file.readAsBytesSync();
      excel = Excel.decodeBytes(bytes);
    } else {
      excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      sheetObject.appendRow(['userId', 'time (ms)', 'memory', 'method', 'arguments']);
    }
    Sheet sheetObject = excel['Sheet1'];
    sheetObject.appendRow([user, timeAndMemory.time, timeAndMemory.memory, method, arguments]);

    var fileBytes = excel.encode();
    if (fileBytes != null) {
      file
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  }
}
