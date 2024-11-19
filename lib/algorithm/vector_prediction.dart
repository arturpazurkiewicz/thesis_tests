import 'dart:collection';
import 'dart:math';

import '../../model/recipe_full.dart';

class DataPoint {
  List<int> features; // Reprezentacja transakcji jako wektor cech
  String label; // Możesz użyć etykiet do klasyfikacji, jeśli masz dane z etykietami

  DataPoint(this.features, this.label);
}

extension MyDateExtension on DateTime {
  DateTime getDateOnly() {
    return DateTime(year, month, day);
  }
}

class Neighbor {
  final List<double> data;
  final Set<int> names;
  final double distance;

  Neighbor(this.data, this.names, this.distance);

  @override
  String toString() => 'Distance: $distance, Neighbour: $data';
}

abstract class VectorPrediction {
  final List<RecipeFull> transactions;
  final bool sortAsc;
  late final Map<int, int> nameToPositionMap; // nazwa, pozycja
  late final Map<int, int> positionToNameMap;
  late final SplayTreeMap<DateTime, Set<int>> purchasedInDate;
  late final Map<int, List<int>> productPurchaseInterval;
  late final Map<int, SplayTreeSet<DateTime>> productPurchaseDate;
  static const int _maxValue = -1 >>> 1;
  late final List<List<double>> vectorData;

  VectorPrediction(this.transactions, this.sortAsc) {
    _generateMatrixColumns();
    _generatePurchaseIntervals();
    vectorData = _generateVectorData();
  }

  void _generateMatrixColumns() {
    nameToPositionMap = {};
    positionToNameMap = {};
    purchasedInDate = SplayTreeMap();
    Set<int> names = {};
    for (var transaction in transactions) {
      var date = transaction.recipe.time.getDateOnly();
      if (purchasedInDate[date] == null) purchasedInDate[date] = {};
      for (var recipeEntry in transaction.entries) {
        names.add(recipeEntry.entry.productId);
        purchasedInDate[date]!.add(recipeEntry.entry.productId);
      }
    }
    var nameList = names.toList();
    nameList.sort();
    int i = 0;
    for (var name in nameList) {
      if (nameToPositionMap[name] == null) {
        nameToPositionMap[name] = i++;
      }
    }
    nameToPositionMap.forEach((key, value) {
      positionToNameMap[value] = key;
    });
  }

  List<List<double>> _generateVectorData() {
    List<List<double>> result = [];
    List<DateTime> sortedDates = purchasedInDate.keys.toList();
    for (var y = 0; y < purchasedInDate.length; y++) {
      List<double> column = [];
      var date = sortedDates[y];
      for (var position = 0; position < positionToNameMap.length; position++) {
        double positionValueInDate;
        int name = positionToNameMap[position]!;
        var productPurchase = productPurchaseDate[name]!;
        DateTime? before;
        DateTime? after;
        for (DateTime purchaseDate in productPurchase) {
          if (date.isAfter(purchaseDate)) {
            before = purchaseDate;
          }
          if (purchaseDate.isAfter(date)) {
            after = purchaseDate;
            break;
          }
        }

        if (productPurchase.contains(date)) {
          positionValueInDate = 1;
        } else if (before != null && after != null) {
          positionValueInDate = date.difference(before).inDays / after.difference(before).inDays;
        } else if (before == null) {
          positionValueInDate = 0;
        } else {
          var intervals = productPurchaseInterval[name];
          positionValueInDate = predictPositionValueInDate(intervals, date.difference(before).inDays);
        }
        column.add(positionValueInDate);
      }
      result.add(column);
    }
    return result;
  }

  double predictPositionValueInDate(List<int>? intervals, int? dayInterval) {
    if (intervals == null || intervals.isEmpty || dayInterval == null) {
      return 0;
    }
    if (dayInterval == 0) {
      return 1.0;
    }
    var averageInterval = intervals.reduce((value, element) => value + element) / intervals.length;
    if (averageInterval != 0) {
      return max(averageInterval - dayInterval, 0) / averageInterval;
    } else {
      return 0;
    }
  }

  Set<int> predictProduct(List<Neighbor> neighbours, Set<int> inputNames) {
    Map<int, int> foundData = {};
    for (var neighbour in neighbours) {
      for (int name in neighbour.names) {
        var value = foundData[name];
        if (value == null) {
          foundData[name] = 1;
        } else {
          foundData[name] = value + 1;
        }
      }
    }
    foundData.removeWhere((key, value) => inputNames.contains(key));
    int maxKey = 0;
    Map<int, Set<int>> mapOfOccurrences = {};
    mapOfOccurrences[0] = {};
    for (var entry in foundData.entries) {
      maxKey = max(maxKey, entry.value);
      var occurrenceList = mapOfOccurrences[entry.value];
      if (occurrenceList == null) {
        mapOfOccurrences[entry.value] = occurrenceList = {};
      }
      occurrenceList.add(entry.key);
    }
    return mapOfOccurrences[maxKey]!;
  }

  bool resultShouldBeShown(Set<int> input, Set<int> resultNames) {
    if (input.any((element) => resultNames.contains(element))) {
      return !input.containsAll(resultNames);
    } else {
      return false;
    }
  }

  Set<int> getNamesFromDataVector(List<double> data) {
    Set<int> result = {};
    for (var position = 0; position < data.length; position++) {
      if (data[position] == 1) {
        result.add(positionToNameMap[position]!);
      }
    }
    return result;
  }

  void _generatePurchaseIntervals() {
    productPurchaseDate = {}; // produkt i interwał
    nameToPositionMap.forEach((key, value) {
      productPurchaseDate[key] = SplayTreeSet();
    });

    for (var transaction in transactions) {
      var transactionDay = transaction.recipe.time.getDateOnly();
      for (var recipeEntry in transaction.entries) {
        productPurchaseDate[recipeEntry.entry.productId]!.add(transactionDay);
      }
    }

    Map<int, List<int>> productPurchaseIntervals = {};
    productPurchaseDate.forEach((key, value) {
      var dates = value.toList();
      dates.sort();
      List<int> intervals = [];
      for (var i = 1; i < dates.length; i++) {
        var interval = dates[i].difference(dates[i - 1]).inDays;
        intervals.add(interval);
      }
      productPurchaseIntervals[key] = intervals;
    });
    productPurchaseInterval = productPurchaseIntervals;
  }

  int? periodBetweenDateAndLastProductPurchase(DateTime date, SplayTreeSet<DateTime>? dateInterval) {
    var lastDate = dateInterval?.lastWhere((dateOfPurchase) => date.isAfter(dateOfPurchase), orElse: () => DateTime(_maxValue));
    if (lastDate != null && date.isAfter(lastDate)) {
      return date.difference(lastDate).inDays;
    } else {
      return null;
    }
  }

  List<Neighbor> findKNearestNeighbors(int k, Set<int> inputNames, DateTime day) {
    final List<Neighbor> neighbours = [];
    List<double> inputVector = [];
    for (var position = 0; position < positionToNameMap.length; position++) {
      var name = positionToNameMap[position];
      if (inputNames.contains(name)) {
        inputVector.add(1);
      } else {
        var interval = productPurchaseInterval[name];
        var periodBetween = periodBetweenDateAndLastProductPurchase(day.getDateOnly(), productPurchaseDate[name]);
        var calculated = predictPositionValueInDate(interval, periodBetween);
        inputVector.add(calculated);
      }
    }

    for (var i = 0; i < vectorData.length; i++) {
      var names = getNamesFromDataVector(vectorData[i]);
      if (!inputNames.containsAll(names)) {
        var distance = calculateDistance(inputVector, vectorData[i]);
        neighbours.add(Neighbor(vectorData[i], names, distance));
      }
    }

    if (sortAsc) {
      neighbours.sort((a, b) => a.distance.compareTo(b.distance));
    } else {
      neighbours.sort((a, b) => b.distance.compareTo(a.distance));
    }

    List<Neighbor> selectedNeighbours = [];
    List<Neighbor> tempNeighbours = [];
    for (var neighbour in neighbours) {
      if (resultShouldBeShown(inputNames, neighbour.names)) {
        selectedNeighbours.add(neighbour);
      } else {
        tempNeighbours.add(neighbour);
      }
      if (selectedNeighbours.length == k) {
        break;
      }
    }
    int toAdd = min(tempNeighbours.length, k - selectedNeighbours.length);
    if (toAdd > 0) {
      selectedNeighbours.addAll(tempNeighbours.getRange(0, toAdd));
    }

    return selectedNeighbours;
  }

  double calculateDistance(List<double> vec1, List<double> vec2);
}
