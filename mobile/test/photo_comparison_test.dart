// Tests du moteur de comparaison photo (pHash + histogramme), local.

import 'dart:math' as math;

import 'package:arise/features/photo_check/domain/image_comparator.dart';
import 'package:arise/features/photo_check/domain/image_signature.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Image partagée verticalement : gauche sombre, droite claire.
img.Image _leftRightSplit({int shift = 0}) {
  final image = img.Image(width: 64, height: 64);
  for (var y = 0; y < 64; y++) {
    for (var x = 0; x < 64; x++) {
      final base = x < 32 ? 40 : 210;
      final v = (base + shift).clamp(0, 255);
      image.setPixelRgb(x, y, v, v, v);
    }
  }
  return image;
}

/// Image partagée horizontalement : haut sombre, bas clair (structure ≠).
img.Image _topBottomSplit() {
  final image = img.Image(width: 64, height: 64);
  for (var y = 0; y < 64; y++) {
    for (var x = 0; x < 64; x++) {
      final v = y < 32 ? 40 : 210;
      image.setPixelRgb(x, y, v, v, v);
    }
  }
  return image;
}

/// Image texturée (fréquences bien réparties, comme une vraie photo) : les
/// coefficients DCT sont éloignés de la médiane, donc le pHash est stable face
/// à un décalage de luminosité. Pas de saturation après le décalage utilisé.
img.Image _textured({int shift = 0}) {
  final image = img.Image(width: 64, height: 64);
  for (var y = 0; y < 64; y++) {
    for (var x = 0; x < 64; x++) {
      final base = 110 +
          40 * math.sin(x * 0.6) +
          35 * math.sin(y * 0.9) +
          15 * math.sin((x + y) * 0.3);
      final v = (base.round() + shift).clamp(0, 255);
      image.setPixelRgb(x, y, v, v, v);
    }
  }
  return image;
}

void main() {
  group('Signature & comparaison', () {
    test('deux images identiques correspondent parfaitement', () {
      final a = signatureFromImage(_leftRightSplit());
      final b = signatureFromImage(_leftRightSplit());

      final result = compareSignatures(a, b, MatchTolerance.standard);
      expect(result.phashSimilarity, 1.0);
      expect(result.histogramSimilarity, greaterThan(0.99));
      expect(result.matched, isTrue);
    });

    test('deux structures différentes ne correspondent pas', () {
      final a = signatureFromImage(_leftRightSplit());
      final b = signatureFromImage(_topBottomSplit());

      final result = compareSignatures(a, b, MatchTolerance.standard);
      expect(result.matched, isFalse,
          reason: 'pHash=${result.phashSimilarity}');
    });

    test('robustesse à un léger changement de luminosité (pHash stable)', () {
      final a = signatureFromImage(_textured());
      final brighter = signatureFromImage(_textured(shift: 20));

      expect(phashSimilarity(a.phash, brighter.phash),
          greaterThanOrEqualTo(0.9));
    });

    test('comparaison multi-références : une seule correspondance suffit', () {
      final refs = [
        signatureFromImage(_topBottomSplit()),
        signatureFromImage(_leftRightSplit()),
      ];
      final candidate = signatureFromImage(_leftRightSplit());

      final result = compareAgainstReferences(
          refs, candidate, MatchTolerance.standard);
      expect(result.matched, isTrue);
    });
  });

  group('Tolérance selon l\'heure', () {
    test('la nuit est plus tolérante que le jour', () {
      final night = MatchTolerance.forHour(3);
      final day = MatchTolerance.forHour(12);
      expect(night.minPhash, lessThan(day.minPhash));
      expect(night.minHistogram, lessThan(day.minHistogram));
    });
  });
}
