
import 'package:biedronka_tests/algorithm_factory/preprocessed_algorithm.dart';

import '../algorithm/cosine_similarity.dart';
import '../model/recipe_full.dart';
import 'algorithm.dart';

class CosineSimilarityFactory extends Algorithm {
  final int k;
  CosineSimilarity? algorithm;

  CosineSimilarityFactory(this.k);

  @override
  Set<int> calculate(Set<int> input, DateTime day) {
    var neighbours = algorithm!.findKNearestNeighbors(k, input, day);
    return algorithm!.predictProduct(neighbours, input);
  }

  @override
  PreprocessedAlgorithm preprocess(List<RecipeFull> transactions) {
    algorithm = CosineSimilarity(transactions);
    return this;
  }
}
