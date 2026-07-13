import 'dart:math';

import '../../../data/models/math_difficulty.dart';

/// Une opération de calcul mental : l'énoncé affiché et sa réponse.
class MathOperation {
  const MathOperation(this.prompt, this.answer);

  /// Énoncé lisible, ex. « 7 × 8 + 3 ».
  final String prompt;

  /// Réponse attendue.
  final int answer;

  @override
  String toString() => '$prompt = $answer';
}

/// Génère des opérations selon le niveau de difficulté du cahier des charges.
///
/// Le [Random] est injectable pour rendre la génération déterministe en test.
class MathOperationGenerator {
  MathOperationGenerator([Random? random]) : _rng = random ?? Random();

  final Random _rng;

  /// Entier aléatoire dans [min, max] inclus.
  int _between(int min, int max) => min + _rng.nextInt(max - min + 1);

  /// Génère une opération pour le niveau donné.
  ///
  /// [singleDigitFloor] force le palier plancher de sécurité (opération à un
  /// chiffre), utilisé par l'anti-blocage après de nombreux échecs.
  MathOperation generate(
    MathDifficulty level, {
    bool singleDigitFloor = false,
  }) {
    if (singleDigitFloor) {
      final a = _between(1, 9);
      final b = _between(1, 9);
      return MathOperation('$a + $b', a + b);
    }

    switch (level) {
      case MathDifficulty.easy:
        return _addOrSub(1, 20);
      case MathDifficulty.medium:
        // Addition / soustraction 1–100, ou tables de multiplication 1–10.
        if (_rng.nextBool()) {
          final a = _between(1, 10);
          final b = _between(1, 10);
          return MathOperation('$a × $b', a * b);
        }
        return _addOrSub(1, 100);
      case MathDifficulty.hard:
        // Multiplication (2 chiffres × 1 chiffre) ou division exacte.
        if (_rng.nextBool()) {
          final a = _between(10, 99);
          final b = _between(2, 9);
          return MathOperation('$a × $b', a * b);
        }
        final divisor = _between(2, 9);
        final quotient = _between(2, 12);
        return MathOperation('${divisor * quotient} ÷ $divisor', quotient);
      case MathDifficulty.veryHard:
        return _combined();
    }
  }

  MathOperation _addOrSub(int min, int max) {
    final a = _between(min, max);
    final b = _between(min, max);
    if (_rng.nextBool()) {
      return MathOperation('$a + $b', a + b);
    }
    // Soustraction toujours à résultat positif.
    final hi = a >= b ? a : b;
    final lo = a >= b ? b : a;
    return MathOperation('$hi − $lo', hi - lo);
  }

  /// Opération combinée en deux étapes (niveau très difficile).
  MathOperation _combined() {
    final a = _between(2, 9);
    final b = _between(2, 9);
    final c = _between(2, 20);
    switch (_rng.nextInt(3)) {
      case 0:
        return MathOperation('$a × $b + $c', a * b + c);
      case 1:
        final product = a * b;
        // Garantir un résultat positif pour la soustraction.
        if (product >= c) {
          return MathOperation('$a × $b − $c', product - c);
        }
        return MathOperation('$a × $b + $c', product + c);
      default:
        return MathOperation('$c + $a × $b', c + a * b);
    }
  }
}
