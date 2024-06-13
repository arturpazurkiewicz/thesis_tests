import 'package:biedronka_tests/algorithm_factory/apriori_with_days_factory.dart';
import 'package:biedronka_tests/data_helper.dart';
import 'package:biedronka_tests/validation_test/reverse_trace.dart';
import 'package:mysql_client/mysql_client.dart';

import '../algorithm_factory/apriori_factory.dart';
import '../algorithm_factory/apriori_with_time_factory.dart';
import '../algorithm_factory/cosine_similarity_factory.dart';
import '../algorithm_factory/knn_factory.dart';
import '../excel_helper.dart';
import 'constK.dart';

void main() async {
  // Konfiguracja połączenia z bazą danych MySQL
  final connection = MySQLConnectionPool(
    host: 'localhost',
    port: 3306,
    userName: 'root',
    password: 'ares',
    databaseName: 'instacart',
    maxConnections: 10,
  );

  var filePath = 'results.xlsx';

  for (var user in userIds) {
    var userData = await DataHelper.loadOrdersOfSingleUser(connection, user);
    var toValidate = userData.recipeTrain[0];

    // Apriori
    for (double minSupport = 25.0; minSupport > 21.0; minSupport -= 1.0) {
      var algorithm = AprioriFactory(minSupport);
      var preprocessed = algorithm.preprocess(userData.recipePrior);
      var validateResult =
          ReverseTrace.findReverseTraceWithAdd(preprocessed, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time, {}, {});
      var result = ({'userId': user, 'method': 'Apriori', 'found': validateResult.found.length, 'added': validateResult.added.length, 'arguments': minSupport});
      ExcelHelper.appendValidationResultToExcel(result, filePath);
    }

    // AprioriWithTime
    for (double minSupport = 25.0; minSupport > 21.0; minSupport -= 1.0) {
      var algorithm = AprioriWithTimeFactory(minSupport);
      var preprocessed = algorithm.preprocess(userData.recipePrior);
      var validateResult =
          ReverseTrace.findReverseTraceWithAdd(preprocessed, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time, {}, {});
      var result =
          ({'userId': user, 'method': 'AprioriWithTime', 'found': validateResult.found.length, 'added': validateResult.added.length, 'arguments': minSupport});
      ExcelHelper.appendValidationResultToExcel(result, filePath);
    }

    // AprioriWithDays
    for (double minSupport = 25.0; minSupport > 21.0; minSupport -= 1.0) {
      var algorithm = AprioriWithDaysFactory(minSupport);
      var preprocessed = algorithm.preprocess(userData.recipePrior);
      var validateResult =
          ReverseTrace.findReverseTraceWithAdd(preprocessed, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time, {}, {});
      var result =
          ({'userId': user, 'method': 'AprioriWithDays', 'found': validateResult.found.length, 'added': validateResult.added.length, 'arguments': minSupport});
      ExcelHelper.appendValidationResultToExcel(result, filePath);
    }

    // KNN
    for (int k = 25; k > 21; k -= 1) {
      var algorithm = KNNFactory(k);
      var preprocessed = algorithm.preprocess(userData.recipePrior);
      var validateResult =
          ReverseTrace.findReverseTraceWithAdd(preprocessed, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time, {}, {});
      var result = ({'userId': user, 'method': 'KNN', 'found': validateResult.found.length, 'added': validateResult.added.length, 'arguments': k});
      ExcelHelper.appendValidationResultToExcel(result, filePath);
    }

    // CosineSimilarity
    for (int k = 25; k > 21; k -= 1) {
      var algorithm = CosineSimilarityFactory(k);
      var preprocessed = algorithm.preprocess(userData.recipePrior);
      var validateResult =
          ReverseTrace.findReverseTraceWithAdd(preprocessed, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time, {}, {});
      var result = ({'userId': user, 'method': 'CosineSimilarity', 'found': validateResult.found.length, 'added': validateResult.added.length, 'arguments': k});
      ExcelHelper.appendValidationResultToExcel(result, filePath);
    }
  }

  await connection.close();
}
