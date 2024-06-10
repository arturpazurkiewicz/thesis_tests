
import 'package:biedronka_tests/model/recipe.dart';
import 'package:biedronka_tests/model/recipe_entry_full.dart';

class RecipeFull{
  final Recipe recipe;
  final List<RecipeEntryFull> entries;

  RecipeFull(this.recipe, this.entries);

  @override
  String toString() {
    return entries.toString();
  }
}