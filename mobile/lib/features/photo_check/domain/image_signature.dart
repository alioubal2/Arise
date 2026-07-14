import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Empreinte locale d'une image : hash perceptuel (pHash) + histogramme couleur.
///
/// Calculée entièrement sur l'appareil, sans réseau. Sert de base à la
/// comparaison entre la photo de référence et la photo de validation.
class ImageSignature {
  const ImageSignature({required this.phash, required this.histogram});

  /// Hash perceptuel 64 bits (basé DCT).
  final int phash;

  /// Histogramme couleur normalisé (64 bins RGB, somme = 1).
  final List<double> histogram;

  Map<String, dynamic> toJson() => {
        'phash': phash.toString(),
        'histogram': histogram,
      };

  factory ImageSignature.fromJson(Map<String, dynamic> json) {
    return ImageSignature(
      phash: int.parse(json['phash'] as String),
      histogram:
          (json['histogram'] as List).map((e) => (e as num).toDouble()).toList(),
    );
  }
}

/// Calcule la signature d'une image encodée (JPEG/PNG).
///
/// Renvoie `null` si l'image ne peut pas être décodée.
ImageSignature? computeSignature(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  return signatureFromImage(decoded);
}

/// Calcule la signature à partir d'une image déjà décodée (utile en test).
ImageSignature signatureFromImage(img.Image image) {
  return ImageSignature(
    phash: _perceptualHash(image),
    histogram: _colorHistogram(image),
  );
}

// --- pHash (DCT) -----------------------------------------------------------

const int _phashSize = 32; // image redimensionnée 32x32
const int _phashLow = 8; // bloc basses fréquences 8x8 -> 64 bits

int _perceptualHash(img.Image source) {
  final resized = img.copyResize(source, width: _phashSize, height: _phashSize);
  final gray = img.grayscale(resized);

  // Matrice de luminance 32x32.
  final matrix = List.generate(
    _phashSize,
    (y) => List<double>.generate(_phashSize, (x) {
      final p = gray.getPixel(x, y);
      return p.r.toDouble(); // en niveaux de gris, r == g == b
    }),
  );

  // DCT-II 2D limitée aux 8x8 premières fréquences.
  final coeffs = List.generate(
    _phashLow,
    (u) => List<double>.filled(_phashLow, 0),
  );
  for (var u = 0; u < _phashLow; u++) {
    for (var v = 0; v < _phashLow; v++) {
      double sum = 0;
      for (var x = 0; x < _phashSize; x++) {
        final cosX =
            math.cos((2 * x + 1) * u * math.pi / (2 * _phashSize));
        for (var y = 0; y < _phashSize; y++) {
          final cosY =
              math.cos((2 * y + 1) * v * math.pi / (2 * _phashSize));
          sum += matrix[x][y] * cosX * cosY;
        }
      }
      coeffs[u][v] = sum;
    }
  }

  // Médiane des coefficients (hors composante continue DC en [0][0]).
  final flat = <double>[];
  for (var u = 0; u < _phashLow; u++) {
    for (var v = 0; v < _phashLow; v++) {
      if (u == 0 && v == 0) continue;
      flat.add(coeffs[u][v]);
    }
  }
  flat.sort();
  final median = flat[flat.length ~/ 2];

  // 64 bits : bit = coefficient > médiane.
  int hash = 0;
  for (var u = 0; u < _phashLow; u++) {
    for (var v = 0; v < _phashLow; v++) {
      hash <<= 1;
      if (coeffs[u][v] > median) hash |= 1;
    }
  }
  return hash;
}

// --- Histogramme couleur ---------------------------------------------------

const int _histSize = 64; // image réduite pour l'histogramme
const int _binsPerChannel = 4; // 4x4x4 = 64 bins

List<double> _colorHistogram(img.Image source) {
  final resized = img.copyResize(source, width: _histSize, height: _histSize);
  final bins = List<double>.filled(
    _binsPerChannel * _binsPerChannel * _binsPerChannel,
    0,
  );
  const div = 256 ~/ _binsPerChannel;
  for (var y = 0; y < _histSize; y++) {
    for (var x = 0; x < _histSize; x++) {
      final p = resized.getPixel(x, y);
      final r = (p.r ~/ div).clamp(0, _binsPerChannel - 1);
      final g = (p.g ~/ div).clamp(0, _binsPerChannel - 1);
      final b = (p.b ~/ div).clamp(0, _binsPerChannel - 1);
      final index = r * _binsPerChannel * _binsPerChannel + g * _binsPerChannel + b;
      bins[index] += 1;
    }
  }
  // Normalisation (somme = 1).
  final total = _histSize * _histSize;
  for (var i = 0; i < bins.length; i++) {
    bins[i] /= total;
  }
  return bins;
}
