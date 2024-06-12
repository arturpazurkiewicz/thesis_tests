import 'package:biedronka_tests/algorithm/vector_prediction.dart';

import 'apriori.dart';

class AprioriWithDays extends Apriori {
  AprioriWithDays(minSupport, transactions) : super(minSupport, transactions);

  @override
  List<List<int>> prepareElements() {
    List<List<int>> result = [];
    for (var transaction in transactions) {
      var line = transaction.entries.map((e) => e.entry.productId).toList();
      line.add(generateWeekdayProduct(transaction.recipe.time.day));
      line.sort();
      result.add(line);
    }
    return result;
  }

  @override
  bool filterRule(AssociationRule rule) {
    return rule.add.firstWhere((element) => element < 0, orElse: () => -1) < 0;
  }

  Set<int> predictProductWithTime(Set<int> inputNames, DateTime day) {
    var data = inputNames.toSet();
    var cleanDay = day.getDateOnly();
    data.add(generateWeekdayProduct(cleanDay.weekday));
    return predictProduct(data);
  }

  @override
  AssociationRule? cleanRuleFromUnwantedData(Set<int> inputNames, AssociationRule rule) {
    var cleanedRule = super.cleanRuleFromUnwantedData(inputNames, rule);
    if (cleanedRule == null) {
      return null;
    }
    cleanedRule.add.removeWhere((element) => element < 0);
    if (cleanedRule.add.isNotEmpty) {
      return cleanedRule;
    }
    return null;
  }
}

int generateWeekdayProduct(int weekday) {
  return -12 - weekday;
}
