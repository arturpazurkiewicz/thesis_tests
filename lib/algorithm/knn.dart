import 'dart:math';

import '../../model/recipe_full.dart';
import 'vector_prediction.dart';

class KNN extends VectorPrediction {
  KNN(List<RecipeFull> transactions) : super(transactions, false);

  @override
  double calculateDistance(List<double> vec1, List<double> vec2) {
    double distance = 0;
    for (var i = 0; i < vec1.length; i++) {
      distance += pow(vec1[i] - vec2[i], 2);
    }
    return sqrt(distance);
  }
}
