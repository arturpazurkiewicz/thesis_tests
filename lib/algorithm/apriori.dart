import 'dart:math';

import '../../model/recipe_full.dart';

class Apriori {
  final double minSupport;
  final List<RecipeFull> transactions;
  List<List<int>> cleanTransactions = [];
  List<List<int>> C = [];
  List<List<int>> L = [];

  List<List<List<int>>> frequentSet = [];

  List<AssociationRule> associationRules = [];

  int nowStep = 0;

  Apriori(this.minSupport, this.transactions) {
    frequentSet.add([[]]);
  }

  List<List<int>> prepareElements() {
    List<List<int>> result = [];
    for (var transaction in transactions) {
      var line = transaction.entries.map((e) => e.entry.productId).toList();
      line.sort();
      result.add(line);
    }
    return result;
  }

  void process() {
    cleanTransactions = prepareElements();
    C = [];
    L = [];
    frequentSet = [];
    associationRules = [];
    while (true) {
      C = generateNextC();
      if (C.isEmpty) break;
      nowStep++;
      L = generateL();
      frequentSet.add(L);
    }

    for (var stepItemSet in frequentSet) {
      for (var items in stepItemSet) {
        generateAssociationRule(items, [], [], 0);
      }
    }
  }

  double round(double value, int pos) {
    double mod = pow(10.0, pos).toDouble();
    return (value * mod).round().toDouble() / mod;
  }

  List<List<int>> generateL() {
    List<List<int>> ret = [];
    for (var row in C) {
      var support = getSupport(row);
      if (round(support, 2) < minSupport) continue;
      ret.add(row);
    }
    return ret;
  }

  List<List<int>> generateNextC() {
    if (nowStep == 0) {
      List<int> elements = getElement(cleanTransactions);

      var ret = elements.map((element) => [element]).toList();
      return ret;
    } else {
      return pruning(joining());
    }
  }

  void generateAssociationRule(List<int> items, List<int> X, List<int> Y, int index) {
    if (index == items.length) {
      if (X.isEmpty || Y.isEmpty) return;

      double XYsupport = getSupport(items); // Zakładamy, że funkcja getSupport została zaimplementowana
      double Xsupport = getSupport(X);

      if (Xsupport == 0) return;

      double support = XYsupport; // W Darcie typ double obejmuje również wartości long double z C++
      double confidence = XYsupport / Xsupport * 100.0;
      associationRules.add(AssociationRule(X, Y, support, confidence));
      return;
    }

    // Dodawanie kolejnego elementu do X
    List<int> newX = List.from(X)..add(items[index]);
    generateAssociationRule(items, newX, Y, index + 1);

    // Dodawanie tego samego elementu do Y
    List<int> newY = List.from(Y)..add(items[index]);
    generateAssociationRule(items, X, newY, index + 1);
  }

  List<List<int>> pruning(List<List<int>> joined) {
    List<List<int>> ret = [];

    // Konwersja L do zestawu zestawów dla szybkiego sprawdzania obecności
    // Dart nie obsługuje bezpośrednio Set<List<int>>, więc używamy Set<String>
    var lSet = <String>{};
    for (var row in L) {
      lSet.add(row.join(',')); // Używamy ciągu znaków jako klucza
    }

    for (var row in joined) {
      bool allSubsetsFrequent = true;
      for (int i = 0; i < row.length; i++) {
        var tmp = List<int>.from(row); // Tworzenie kopii listy
        tmp.removeAt(i); // Usuwanie elementu i-tego
        if (!lSet.contains(tmp.join(','))) {
          // Sprawdzanie obecności w lSet
          allSubsetsFrequent = false;
          break;
        }
      }
      if (allSubsetsFrequent) {
        ret.add(row);
      }
    }

    return ret;
  }

  double getSupport(List<int> item) {
    int ret = 0;
    for (var row in cleanTransactions) {
      if (row.length < item.length) continue;
      int j = 0;
      for (var i = 0; i < row.length; i++) {
        if (j == item.length) break;
        if (row[i] == item[j]) j++;
      }
      if (j == item.length) {
        ret++;
      }
    }
    return ret / cleanTransactions.length * 100.00;
  }

  List<List<int>> joining() {
    List<List<int>> ret = [];
    for (int i = 0; i < L.length; i++) {
      for (int j = i + 1; j < L.length; j++) {
        int k;
        for (k = 0; k < nowStep - 1; k++) {
          if (L[i][k] != L[j][k]) break;
        }
        if (k == nowStep - 1) {
          List<int> tmp = [];
          for (int k = 0; k < nowStep - 1; k++) {
            tmp.add(L[i][k]);
          }
          int a = L[i][nowStep - 1];
          int b = L[j][nowStep - 1];
          if (a > b) {
            int temp = a;
            a = b;
            b = temp;
          }
          tmp.add(a);
          tmp.add(b);
          ret.add(tmp);
        }
      }
    }
    return ret;
  }

  List<int> getElement(List<List<int>> itemSet) {
    var res = itemSet.expand((element) => element).toSet().toList();
    res.sort();
    return res;
  }

  @override
  Set<int> predictProduct(Set<int> inputNames) {
    List<AssociationRule> cleanRules = showConnectedAssociationRules(inputNames);
    Set<int> result = {};
    if (cleanRules.isNotEmpty) {
      var calculatedConf = cleanRules.first.confidence;
      for (var rule in cleanRules) {
        if (rule.confidence == calculatedConf) {
          result.addAll(rule.add);
        } else {
          break;
        }
      }
    }
    return result;
  }

  List<AssociationRule> showConnectedAssociationRules(Set<int> inputNames) {
    List<AssociationRule> cleanRules = [];
    for (var rule in associationRules) {
      var cleaned = cleanRuleFromUnwantedData(inputNames, rule);
      if (cleaned != null && inputNames.containsAll(cleaned.base)) cleanRules.add(cleaned);
    }
    cleanRules.sort((a, b) => b.calculateWeight().compareTo(a.calculateWeight()));
    return cleanRules;
  }

  AssociationRule? cleanRuleFromUnwantedData(Set<int> inputNames, AssociationRule rule) {
    var clone = rule.clone();
    clone.add.removeWhere((element) => inputNames.contains(element));
    if (clone.add.isNotEmpty) {
      return clone;
    }
    return null;
  }
}

class AssociationRule {
  List<int> base;
  List<int> add;
  double support;
  double confidence;

  AssociationRule(this.base, this.add, this.support, this.confidence);

  double calculateWeight() {
    return confidence;
  }

  AssociationRule clone() {
    return AssociationRule(base.toList(), add.toList(), support, confidence);
  }
}
