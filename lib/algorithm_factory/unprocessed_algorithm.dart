
import 'package:biedronka_tests/algorithm_factory/preprocessed_algorithm.dart';

import '../model/recipe_full.dart';

abstract class UnprocessedAlgorithm {
  PreprocessedAlgorithm preprocess(List<RecipeFull> transactions);
}
