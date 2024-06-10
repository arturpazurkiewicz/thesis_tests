import 'dart:io';


import 'package:biedronka_tests/model/product.dart';
import 'package:biedronka_tests/model/recipe_entry_full.dart';

import '../model/recipe.dart';
import '../model/recipe_entry.dart';
import '../model/recipe_full.dart';


class InputReader {
  late File file;

  InputReader(String filename) {
    file = File(filename);
    if (!file.existsSync()) {
      print("Input file could not be opened");
      exit(0);
    }
  }

  List<RecipeFull> getTransactions() {
    List<RecipeFull> transactions = [];
    List<String> lines = file.readAsLinesSync();
    int id = 0;
    for (var line in lines) {
      if (line.isNotEmpty){
        List<int> ids = line.split(' ').map((id) => int.parse(id)).toList();
        int recipeId = id;
        List<RecipeEntryFull> entries = [];

        for (var entryId in ids.sublist(2)) {
          entries.add(RecipeEntryFull(RecipeEntry(ids[0], entryId, 1.0, recipeId),Product(null,"Placeholder")));
        }
        transactions.add(RecipeFull(Recipe(recipeId, DateTime.fromMillisecondsSinceEpoch(ids[1])), entries));
        id++;
      }
    }
    return transactions;
  }
}