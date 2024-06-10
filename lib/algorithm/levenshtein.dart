abstract class Levenshtein {
  static int distance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<List<int>> d = List.generate(s.length + 1, (i) => List<int>.filled(t.length + 1, 0));

    for (int i = 0; i <= s.length; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= t.length; j++) {
      d[0][j] = j;
    }

    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        int cost = s[i - 1] == t[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1, // deletion
          d[i][j - 1] + 1, // insertion
          d[i - 1][j - 1] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return d[s.length][t.length];
  }
}
