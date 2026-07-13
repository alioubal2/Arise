// Tests du moteur de calcul mental et de l'anti-blocage progressif.

import 'dart:math';

import 'package:arise/data/models/math_difficulty.dart';
import 'package:arise/features/math_lock/application/math_lock_controller.dart';
import 'package:arise/features/math_lock/domain/math_operation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Soumet une mauvaise réponse (réponse attendue + 1).
void _submitWrong(MathLockController c) => c.submit(c.state.current.answer + 1);

/// Soumet la bonne réponse.
bool _submitRight(MathLockController c) => c.submit(c.state.current.answer);

void main() {
  group('MathOperationGenerator', () {
    test('produit des réponses positives à tous les niveaux', () {
      final gen = MathOperationGenerator(Random(1));
      for (final level in MathDifficulty.values) {
        for (var i = 0; i < 200; i++) {
          final op = gen.generate(level);
          expect(op.answer, greaterThanOrEqualTo(0),
              reason: 'niveau $level : ${op.prompt}');
        }
      }
    });

    test('le plancher génère une addition à un chiffre', () {
      final gen = MathOperationGenerator(Random(2));
      for (var i = 0; i < 50; i++) {
        final op = gen.generate(MathDifficulty.easy, singleDigitFloor: true);
        expect(op.prompt, matches(r'^\d \+ \d$'));
        expect(op.answer, inInclusiveRange(2, 18));
      }
    });
  });

  group('MathLockController — réussite', () {
    test('Facile : une bonne réponse débloque', () {
      final c = MathLockController(MathDifficulty.easy, random: Random(3));
      expect(_submitRight(c), isTrue);
      expect(c.state.solved, isTrue);
    });

    test('Moyen : deux bonnes réponses consécutives requises', () {
      final c = MathLockController(MathDifficulty.medium, random: Random(4));
      _submitRight(c);
      expect(c.state.solved, isFalse);
      expect(c.state.streak, 1);
      _submitRight(c);
      expect(c.state.solved, isTrue);
    });

    test('une mauvaise réponse casse la série', () {
      final c = MathLockController(MathDifficulty.medium, random: Random(5));
      _submitRight(c);
      expect(c.state.streak, 1);
      _submitWrong(c);
      expect(c.state.streak, 0);
      expect(c.state.solved, isFalse);
    });
  });

  group('MathLockController — anti-blocage progressif', () {
    test('3 échecs consécutifs baissent la difficulté d\'un palier', () {
      final c = MathLockController(MathDifficulty.veryHard, random: Random(6));
      expect(c.state.effectiveDifficulty, MathDifficulty.veryHard);
      _submitWrong(c);
      _submitWrong(c);
      _submitWrong(c);
      expect(c.state.effectiveDifficulty, MathDifficulty.hard);
    });

    test('la difficulté continue de descendre (6, 9 échecs)', () {
      final c = MathLockController(MathDifficulty.veryHard, random: Random(7));
      for (var i = 0; i < 6; i++) {
        _submitWrong(c);
      }
      expect(c.state.effectiveDifficulty, MathDifficulty.medium);
      for (var i = 0; i < 3; i++) {
        _submitWrong(c);
      }
      expect(c.state.effectiveDifficulty, MathDifficulty.easy);
    });

    test('12 échecs activent le palier plancher (un chiffre, série de 1)', () {
      final c = MathLockController(MathDifficulty.veryHard, random: Random(8));
      for (var i = 0; i < 12; i++) {
        _submitWrong(c);
      }
      expect(c.state.floor, isTrue);
      expect(c.state.requiredStreak, 1);
      expect(_submitRight(c), isTrue);
      expect(c.state.solved, isTrue);
    });

    test('le niveau ne remonte jamais après une bonne réponse', () {
      final c = MathLockController(MathDifficulty.veryHard, random: Random(9));
      _submitWrong(c);
      _submitWrong(c);
      _submitWrong(c);
      expect(c.state.effectiveDifficulty, MathDifficulty.hard);
      _submitRight(c); // bonne réponse : ne doit pas remonter le niveau
      expect(c.state.effectiveDifficulty, MathDifficulty.hard);
      expect(c.state.consecutiveFailures, 0);
    });

    test('le dépassement de temps compte comme un échec', () {
      final c = MathLockController(MathDifficulty.veryHard, random: Random(10));
      c.timeout();
      c.timeout();
      c.timeout();
      expect(c.state.effectiveDifficulty, MathDifficulty.hard);
    });
  });
}
