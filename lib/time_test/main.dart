import 'package:biedronka_tests/algorithm/apriori_with_days.dart';
import 'package:biedronka_tests/algorithm/apriori_with_time.dart';
import 'package:biedronka_tests/algorithm_factory/apriori_factory.dart';
import 'package:biedronka_tests/algorithm_factory/apriori_with_days_factory.dart';
import 'package:biedronka_tests/algorithm_factory/apriori_with_time_factory.dart';
import 'package:biedronka_tests/algorithm_factory/cosine_similarity_factory.dart';
import 'package:biedronka_tests/algorithm_factory/knn_factory.dart';
import 'package:biedronka_tests/data_helper.dart';
import 'package:biedronka_tests/excel_helper.dart';
import 'package:biedronka_tests/time_test/time_helper.dart';
import 'package:mysql_client/mysql_client.dart';

import '../validation_test.dart';
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

  String filePath = 'results_time.xlsx';

  for (var user in userIds) {
    for (double minSupport = 21.0; minSupport >= 1.0; minSupport -= 1.0) {
      var userData = await DataHelper.loadOrdersOfSingleUser(connection, user);
      var toValidate = userData.recipeTrain[0];
      var algorithm = AprioriFactory(minSupport);
      var timeAndMemory =await timeAndMemoryComplexity(algorithm, userData.recipePrior, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time);
      ExcelHelper.appendValidationResultToTime(user,timeAndMemory, minSupport.toString(),"Apriori", filePath);
    }
    for (double minSupport = 21.0; minSupport >= 1.0; minSupport -= 1.0) {
      var userData = await DataHelper.loadOrdersOfSingleUser(connection, user);
      var toValidate = userData.recipeTrain[0];
      var algorithm = AprioriWithTimeFactory(minSupport);
      var timeAndMemory =await timeAndMemoryComplexity(algorithm, userData.recipePrior, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time);
      ExcelHelper.appendValidationResultToTime(user,timeAndMemory, minSupport.toString(),"AprioriWithTime", filePath);
    }
    for (int k = 21; k >= 1; k -= 1) {
      var userData = await DataHelper.loadOrdersOfSingleUser(connection, user);
      var toValidate = userData.recipeTrain[0];
      var algorithm = KNNFactory(k);
      var timeAndMemory =await timeAndMemoryComplexity(algorithm, userData.recipePrior, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time);
      ExcelHelper.appendValidationResultToTime(user,timeAndMemory, k.toString(),"KNN", filePath);
    }
    for (int k = 21; k >= 1; k -= 1) {
      var userData = await DataHelper.loadOrdersOfSingleUser(connection, user);
      var toValidate = userData.recipeTrain[0];
      var algorithm = CosineSimilarityFactory(k);
      var timeAndMemory =await timeAndMemoryComplexity(algorithm, userData.recipePrior, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time);
      ExcelHelper.appendValidationResultToTime(user,timeAndMemory, k.toString(),"CosineSimilarity", filePath);
    }
    for (double minSupport = 21.0; minSupport >= 1.0; minSupport -= 1.0) {
      var userData = await DataHelper.loadOrdersOfSingleUser(connection, user);
      var toValidate = userData.recipeTrain[0];
      var algorithm = AprioriWithDaysFactory(minSupport);
      var timeAndMemory =await timeAndMemoryComplexity(algorithm, userData.recipePrior, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time);
      ExcelHelper.appendValidationResultToTime(user,timeAndMemory, minSupport.toString(),"AprioriWithDays", filePath);
    }
  }

  await connection.close();
}