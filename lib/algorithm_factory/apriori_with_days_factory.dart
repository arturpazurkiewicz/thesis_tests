
import 'package:biedronka_tests/algorithm_factory/preprocessed_algorithm.dart';

import '../algorithm/apriori_with_days.dart';
import '../model/recipe_full.dart';
import 'algorithm.dart';

class AprioriWithDaysFactory extends Algorithm {
  final double minSupport;
  AprioriWithDays? algorithm;

  AprioriWithDaysFactory(this.minSupport);

  @override
  Set<int> calculate(Set<int> input, DateTime day) {
    return algorithm!.predictProductWithTime(input, day);
  }

  @override
  PreprocessedAlgorithm preprocess(List<RecipeFull> transactions) {
    algorithm = AprioriWithDays(minSupport, transactions);
    algorithm!.process();
    return this;
  }

  @override
  int? productWillBeVisibleAfter(Set<int> input, int product, DateTime day) {
    var fullInput = input.toSet();
    fullInput.addAll({generateWeekdayProduct(day.weekday)});
    var associationRules = algorithm!.showConnectedAssociationRules(fullInput);
    if (associationRules.isEmpty) {
      return null;
    }
    int steps = 0;
    var calculatedConf = associationRules.first.confidence;
    for (var rule in associationRules) {
      if (rule.confidence != calculatedConf) {
        calculatedConf = rule.confidence;
        steps++;
      }
      if (rule.add.contains(product)) {
        return steps;
      }
    }
    return null;
  }
}
