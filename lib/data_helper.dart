import 'package:mysql_client/mysql_client.dart';
import '../model/recipe.dart';
import '../model/recipe_entry.dart';
import '../model/recipe_entry_full.dart';
import '../model/recipe_full.dart';
import '../model/product.dart';

class UserDataRecipe {
  List<RecipeFull> recipeTrain;
  List<RecipeFull> recipePrior;

  UserDataRecipe(this.recipePrior, this.recipeTrain);
}

class DataHelper {
  static Future<UserDataRecipe> loadOrdersOfSingleUser(MySQLConnectionPool conn, int userId) async {
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
}
