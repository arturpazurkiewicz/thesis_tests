import 'dart:collection';

import '../algorithm_factory/preprocessed_algorithm.dart';

class ReverseTrace {
  Set<int> found = {};
  Set<int> added = {};
  ReverseTrace(this.found, this.added);

  static ReverseTrace findReverseTraceWithAdd(PreprocessedAlgorithm preprocessedAlgorithm, Set<int> toFind, DateTime day, Set<int> currentInput, Set<String> history) {
    if (toFind.isNotEmpty) {
      SplayTreeMap<int, ReverseTrace> founded = SplayTreeMap();
      for (var elem in toFind) {
        var currentInputC = currentInput.toSet();
        currentInputC.add(elem);
        var toFindC = toFind.toSet();
        toFindC.remove(elem);
        var res = _findReverseTraceContinue(preprocessedAlgorithm, toFindC, day, currentInputC, history);
        if (res.added.isEmpty) {
          var added = {elem};
          added.addAll(res.added);
          return ReverseTrace(res.found, added);
        }
        res.added.add(elem);
        founded[res.found.length] = res;
      }
      var z = founded[founded.lastKey()!]!;
      return z;
    }
    return ReverseTrace({}, toFind); // not found at all
  }

  static ReverseTrace _findReverseTraceContinue(PreprocessedAlgorithm preprocessedAlgorithm, Set<int> toFind, DateTime day, Set<int> currentInput, Set<String> history) {
    if (toFind.isNotEmpty && !history.contains(createHistory(currentInput))) {
      var suggested = preprocessedAlgorithm.calculate(currentInput, day);
      history.add(createHistory(currentInput));
      Set<int> validSuggestions = suggested.toSet();
      validSuggestions.removeWhere((element) => !toFind.contains(element));
      if (validSuggestions.isNotEmpty) {
        print("Found: $validSuggestions");
        var toFindC = toFind.toSet();
        toFindC.removeWhere((element) => validSuggestions.contains(element));
        if (toFindC.isEmpty) {
          return ReverseTrace(toFind, {});
        }
        var res = findReverseTraceWithAdd(preprocessedAlgorithm, toFindC, day, currentInput, history);
        var added = res.added.toSet();
        added.addAll(res.added);
        var found = validSuggestions.toSet();
        found.addAll(res.found);
        return ReverseTrace(found, added);
      }
      return findReverseTraceWithAdd(preprocessedAlgorithm, toFind, day, currentInput, history);
    }
    return ReverseTrace({}, toFind); // not found at all or calculation again
  }
}



String createHistory(Set<int> ids) {
  var l = ids.toList();
  l.sort();
  return l.join(',');
}