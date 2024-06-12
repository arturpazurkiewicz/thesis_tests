import 'package:biedronka_tests/algorithm_factory/apriori_with_time_factory.dart';
import 'package:biedronka_tests/data_helper.dart';
import 'package:biedronka_tests/excel_helper.dart';
import 'package:mysql_client/mysql_client.dart';

import 'reverse_trace.dart';
import 'constK.dart';

void main() async {
  final connection = MySQLConnectionPool(
    host: 'localhost',
    port: 3306,
    userName: 'root',
    password: 'ares',
    databaseName: 'instacart',
    maxConnections: 10,
  );

  var userIds = [
    // 85602,
    // 188093,
    // 116051,
    // 143118,
    148162,
    12942,
    178632,
    48897,
    108946,
    161809,
    80828,
    190212,
    78879,
    202623,
    // 186935,
    // 110479,
    181970,
  ];

  String filePath = 'results_apriori_with_time.xlsx';

  for (double minSupport = 2.0; minSupport >= 2.0; minSupport -= 1.0) {
    for (var user in userIds) {
      var userData = await DataHelper.loadOrdersOfSingleUser(connection, user);
      var toValidate = userData.recipeTrain[0];
      var algorithm = AprioriWithTimeFactory(minSupport);
      var preprocessed = algorithm.preprocess(userData.recipePrior);
      var validateResult =
      ReverseTrace.findReverseTraceWithAdd(preprocessed, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time, {}, {});
      var result = {'userId': user, 'method': 'AprioriWithTime', 'found': validateResult.found.length, 'added': validateResult.added.length, 'arguments': minSupport};
      ExcelHelper.appendValidationResultToExcel(result, filePath);
    }
  }

  await connection.close();
}
