import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:biedronka_tests/algorithm_factory/apriori_factory.dart';
import 'package:biedronka_tests/algorithm_factory/apriori_with_time_factory.dart';
import 'package:biedronka_tests/algorithm_factory/cosine_similarity_factory.dart';
import 'package:biedronka_tests/algorithm_factory/preprocessed_algorithm.dart';
import 'package:biedronka_tests/model/product.dart';
import 'package:biedronka_tests/model/recipe_entry_full.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:quiver/collection.dart';

import 'algorithm_factory/algorithm.dart';
import 'algorithm_factory/knn_factory.dart';
import 'model/recipe.dart';
import 'model/recipe_entry.dart';
import 'model/recipe_full.dart';

class UserDataRecipe {
  List<RecipeFull> recipeTrain;
  List<RecipeFull> recipePrior;

  UserDataRecipe(this.recipePrior, this.recipeTrain);
}

Future<UserDataRecipe> loadOrdersOfSingleUser(MySQLConnectionPool conn, int userId) async {
  final orders = await conn.execute('''
    select * from orders where user_id = :userId
    order by order_number
    ''', {"userId": userId});

  List<RecipeFull> recipeTrain = [];
  List<RecipeFull> recipePrior = [];
  var time = DateTime(2020);
  for (var order in orders.rows) {
    var orderId = order.typedColByName<int>("order_id")!;
    final orderProducts = await conn.execute('''
    select * from order_products where order_id = :orderId order by product_id
    ''', {"orderId": orderId});
    List<RecipeEntryFull> recipeEntries = [];
    for (var orderProduct in orderProducts.rows) {
      var productId = orderProduct.typedColByName<int>("product_id")!;
      var recipeEntry = RecipeEntry(productId, productId, 1.0, orderId);
      recipeEntries.add(RecipeEntryFull(recipeEntry, Product(productId, productId.toString())));
    }
    var daysSinceLastOrder = order.colByName("days_since_prior_order");
    if (daysSinceLastOrder != null) {
      time = time.add(Duration(days: int.parse(daysSinceLastOrder)));
    }
    if (order.colByName("eval_set") == "prior") {
      recipePrior.add(RecipeFull(Recipe(orderId, time), recipeEntries));
    } else {
      recipeTrain.add(RecipeFull(Recipe(orderId, time), recipeEntries));
    }
  }
  return UserDataRecipe(recipePrior, recipeTrain);
}

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

  final List<int> userIds = [
    19604,
  ];

  for (var user in userIds) {
    var userData = await loadOrdersOfSingleUser(connection, user);
    var toValidate = userData.recipePrior[0];
    var algorithm = CosineSimilarityFactory(17);
    var preprocessed = algorithm.preprocess(userData.recipePrior);
    var toFindIds = toValidate.entries.map((e) => e.product.id!).toSet();
    // var x = _findReverseTraceWithAdd(preprocessed, toValidate.entries.map((e) => e.product.id!).toSet(), toValidate.recipe.time, {}, {});
    var x = _findReverseTraceWithAdd(preprocessed, {5876, 17794, 19057,
      20574,
      24852,
      25872,
      31717, 34190, 44795, 45007, 46069, 47766
    }, toValidate.recipe.time, {}, {});
    print(x.found);
    // {5876, 17794, 19057, 20574, 24852, 25872, 31717, 34190, 44795, 45007, 46069, 47766}
  }

  await connection.close();
}

class ReverseTrace {
  Set<int> found = {};
  Set<int> added = {};
  List<int> route = [];
  ReverseTrace(this.found, this.added, this.route) {
    for (var x in found){
      if (added.contains(x)){
        print('object');
      }
    }
  }
}

ReverseTrace _findReverseTraceWithAdd(PreprocessedAlgorithm preprocessedAlgorithm,Set<int> toFind, DateTime day,Set<int> currentInput, Set<String> history) {
  if (toFind.isNotEmpty) {
    SplayTreeMap<int, ReverseTrace> founded = SplayTreeMap();
    for (var elem in toFind){
      var currentInputC = currentInput.toSet();
      currentInputC.add(elem);
      var toFindC = toFind.toSet();
      toFindC.remove(elem);
      var res = _findReverseTraceContinue(preprocessedAlgorithm, toFindC, day, currentInputC, history);
      // if (res.found.containsAll({24852, 20574, 34190})){
      //   print("object");
      // }
      if (res.added.isEmpty){
        var added = {elem};
        added.addAll(res.added);
        var route = [elem];
        route.addAll(res.route);
        return ReverseTrace(res.found, added, route);
      }
      res.added.add(elem);
      founded[res.found.length] = res;
    }
    // var c = founded.values.toList();
    // c.removeWhere((element) => !(element.found.contains(34190)));
    // if (c.isNotEmpty){
    //   print("object");
    // }
    // var b = founded.values.toList();
    var z = founded[founded.lastKey()!]!;
    // if (c.isNotEmpty && !z.found.contains(34190)){
    //   print("object");
    // }
    if (z.found.length + z.added.length < toFind.length){
      print("object");
    }

    return z;
  }
  return ReverseTrace({}, toFind, toFind.toList()); // not found at all
}

ReverseTrace _findReverseTraceContinue(PreprocessedAlgorithm preprocessedAlgorithm,Set<int> toFind, DateTime day,Set<int> currentInput, Set<String> history) {
  if (toFind.isNotEmpty && !history.contains(createHistory(currentInput))) {
    var suggested = preprocessedAlgorithm.calculate(currentInput, day);
    print("calc");
    history.add(createHistory(currentInput));
    Set<int> validSuggestions = suggested.toSet();
    validSuggestions.removeWhere((element) => !toFind.contains(element));
    if (validSuggestions.isNotEmpty){
      print("Found: $validSuggestions");
      var toFindC = toFind.toSet();
      toFindC.removeWhere((element) => validSuggestions.contains(element));
      if (toFindC.isEmpty){
        return ReverseTrace(toFind, {}, currentInput.toList());
      }
      var res = _findReverseTraceWithAdd(preprocessedAlgorithm, toFindC, day, currentInput, history);
      var added = res.added.toSet();
      added.addAll(res.added);
      var route = currentInput.toList();
      route.addAll(res.route);
      var found = validSuggestions.toSet();
      found.addAll(res.found);
      return ReverseTrace(found, added, route);
    }
    return _findReverseTraceWithAdd(preprocessedAlgorithm, toFind, day, currentInput, history);
  }
  return ReverseTrace({}, toFind, toFind.toList()); // not found at all or calculation again
}
String createHistory(Set<int> ids){
  var l = ids.toList();
  l.sort();
  return l.join(',');
}
