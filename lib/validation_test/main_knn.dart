import 'package:biedronka_tests/algorithm_factory/knn_factory.dart';
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

  String filePath = 'results_knn.xlsx';

  for (int k = 21; k >= 1; k -= 1) {
    for (var user in userIds) {
      var userData = await DataHelper.loadOrdersOfSingleUser(connection, user);
      var toValidate = userData.recipeTrain[0];
      var algorithm = KNNFactory(k);
      var preprocessed = algorithm.preprocess(userData.recipePrior);
      var validateResult =
      ReverseTrace.findReverseTraceWithAdd(preprocessed, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time, {}, {});
      var result = {'userId': user, 'method': 'KNN', 'found': validateResult.found.length, 'added': validateResult.added.length, 'arguments': k};
      ExcelHelper.appendValidationResultToExcel(result, filePath);
    }
  }

  await connection.close();
}
