import 'dart:math';

import '../model/recipe_full.dart';
import 'vector_prediction.dart';

class CosineSimilarity extends VectorPrediction {
  CosineSimilarity(List<RecipeFull> transactions) : super(transactions, false);

  @override
  double calculateDistance(List<double> vec1, List<double> vec2) {
    double dotProduct = 0;
    double normVec1 = 0;
    double normVec2 = 0;
    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      normVec1 += vec1[i] * vec1[i];
      normVec2 += vec2[i] * vec2[i];
    }
    return dotProduct / (sqrt(normVec1) * sqrt(normVec2));
  }
}
