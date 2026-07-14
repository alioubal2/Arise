import 'image_signature.dart';

/// Seuils de tolérance d'une comparaison photo.
///
/// La tolérance s'élargit aux heures de faible luminosité (tôt le matin / tard
/// le soir), conformément au cahier des charges.
class MatchTolerance {
  const MatchTolerance({required this.minPhash, required this.minHistogram});

  /// Similarité pHash minimale (0..1) pour considérer les formes identiques.
  final double minPhash;

  /// Similarité d'histogramme minimale (0..1).
  final double minHistogram;

  /// Tolérance ajustée selon l'heure du rappel (0..23).
  factory MatchTolerance.forHour(int hour) {
    final lowLight = hour < 7 || hour >= 21;
    return lowLight
        ? const MatchTolerance(minPhash: 0.72, minHistogram: 0.45)
        : const MatchTolerance(minPhash: 0.80, minHistogram: 0.55);
  }

  static const standard =
      MatchTolerance(minPhash: 0.80, minHistogram: 0.55);
}

/// Résultat détaillé d'une comparaison.
class ComparisonResult {
  const ComparisonResult({
    required this.phashSimilarity,
    required this.histogramSimilarity,
    required this.matched,
  });

  final double phashSimilarity;
  final double histogramSimilarity;
  final bool matched;
}

/// Similarité pHash : 1 - (distance de Hamming / 64).
double phashSimilarity(int a, int b) {
  final distance = _popcount(a ^ b);
  return 1 - distance / 64;
}

/// Similarité d'histogramme par intersection (somme des minimums).
double histogramSimilarity(List<double> a, List<double> b) {
  final n = a.length < b.length ? a.length : b.length;
  double sum = 0;
  for (var i = 0; i < n; i++) {
    sum += a[i] < b[i] ? a[i] : b[i];
  }
  return sum.clamp(0.0, 1.0);
}

/// Compare deux signatures selon une tolérance.
ComparisonResult compareSignatures(
  ImageSignature reference,
  ImageSignature candidate,
  MatchTolerance tolerance,
) {
  final ph = phashSimilarity(reference.phash, candidate.phash);
  final hist = histogramSimilarity(reference.histogram, candidate.histogram);
  return ComparisonResult(
    phashSimilarity: ph,
    histogramSimilarity: hist,
    matched: ph >= tolerance.minPhash && hist >= tolerance.minHistogram,
  );
}

/// Compare une photo candidate à plusieurs références (calibration multi-photos)
/// et renvoie le meilleur résultat. La correspondance est validée si au moins
/// une référence correspond.
ComparisonResult compareAgainstReferences(
  List<ImageSignature> references,
  ImageSignature candidate,
  MatchTolerance tolerance,
) {
  ComparisonResult? best;
  for (final ref in references) {
    final result = compareSignatures(ref, candidate, tolerance);
    if (result.matched) return result;
    if (best == null ||
        result.phashSimilarity > best.phashSimilarity) {
      best = result;
    }
  }
  return best ??
      const ComparisonResult(
        phashSimilarity: 0,
        histogramSimilarity: 0,
        matched: false,
      );
}

/// Nombre de bits à 1 dans un entier 64 bits.
int _popcount(int x) {
  var count = 0;
  for (var i = 0; i < 64; i++) {
    count += (x >> i) & 1;
  }
  return count;
}
