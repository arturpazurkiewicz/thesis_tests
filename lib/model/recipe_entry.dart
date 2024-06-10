class RecipeEntry {
  final int? id;
  int productId;
  final double amount;
  int recipeId;

  RecipeEntry(this.id, this.productId, this.amount, this.recipeId);

  @override
  String toString() {
    return "$productId   $amount   $recipeId";
  }
}
