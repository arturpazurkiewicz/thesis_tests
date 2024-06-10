import 'package:biedronka_tests/algorithm_factory/preprocessed_algorithm.dart';

import '../algorithm/apriori.dart';
import '../model/recipe_full.dart';
import 'algorithm.dart';

class AprioriFactory extends Algorithm {
  final double minSupport;
  Apriori? algorithm;

  AprioriFactory(this.minSupport);

  @override
  Set<int> calculate(Set<int> input, DateTime day) {
    return algorithm!.predictProduct(input);
  }

  @override
  PreprocessedAlgorithm preprocess(List<RecipeFull> transactions) {
    algorithm = Apriori(minSupport, transactions);
    algorithm!.process();
    return this;
  }
}
