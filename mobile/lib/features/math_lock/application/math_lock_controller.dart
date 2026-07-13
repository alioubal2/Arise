import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/math_difficulty.dart';
import '../domain/math_operation.dart';

/// État immuable d'une session de calcul mental (étape 2 du déblocage).
class MathLockState {
  const MathLockState({
    required this.configured,
    required this.effectiveIndex,
    required this.floor,
    required this.current,
    required this.streak,
    required this.consecutiveFailures,
    required this.solved,
  });

  /// Niveau choisi par l'utilisateur pour ce rappel.
  final MathDifficulty configured;

  /// Index du niveau effectif courant (peut être dégradé, jamais remonté).
  final int effectiveIndex;

  /// Palier plancher de sécurité actif (opérations à un chiffre).
  final bool floor;

  /// Opération affichée à résoudre.
  final MathOperation current;

  /// Nombre de bonnes réponses consécutives accumulées.
  final int streak;

  /// Nombre d'échecs consécutifs (réinitialisé à chaque réussite).
  final int consecutiveFailures;

  /// Vrai lorsque l'utilisateur a débloqué le téléphone.
  final bool solved;

  MathDifficulty get effectiveDifficulty =>
      MathDifficulty.values[effectiveIndex];

  /// Bonnes réponses consécutives requises au niveau effectif courant.
  /// Le palier plancher ne demande qu'une seule réponse.
  int get requiredStreak =>
      floor ? 1 : effectiveDifficulty.requiredStreak;

  /// Temps limite par opération, en secondes (toujours actif).
  int get timeLimitSeconds => effectiveDifficulty.timeLimitSeconds;

  MathLockState copyWith({
    int? effectiveIndex,
    bool? floor,
    MathOperation? current,
    int? streak,
    int? consecutiveFailures,
    bool? solved,
  }) {
    return MathLockState(
      configured: configured,
      effectiveIndex: effectiveIndex ?? this.effectiveIndex,
      floor: floor ?? this.floor,
      current: current ?? this.current,
      streak: streak ?? this.streak,
      consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
      solved: solved ?? this.solved,
    );
  }
}

/// Pilote la session de calcul mental et applique l'anti-blocage progressif.
///
/// Règles (cahier des charges) :
/// - une réponse correcte incrémente la série ; l'atteinte du seuil débloque ;
/// - une réponse fausse ou un dépassement de temps casse la série et compte un
///   échec consécutif ;
/// - après 3 / 6 / 9 / 12 échecs consécutifs, la difficulté baisse d'un palier,
///   puis encore, puis passe en Facile, puis au plancher (un chiffre) ;
/// - le niveau ne remonte jamais pendant la même session.
class MathLockController extends StateNotifier<MathLockState> {
  MathLockController(MathDifficulty configured, {Random? random})
      : _gen = MathOperationGenerator(random),
        super(_initial(configured, random));

  final MathOperationGenerator _gen;

  static MathLockState _initial(MathDifficulty configured, Random? random) {
    final gen = MathOperationGenerator(random);
    return MathLockState(
      configured: configured,
      effectiveIndex: configured.index,
      floor: false,
      current: gen.generate(configured),
      streak: 0,
      consecutiveFailures: 0,
      solved: false,
    );
  }

  /// Soumet une réponse. Renvoie `true` si elle était correcte.
  bool submit(int answer) {
    if (state.solved) return true;
    if (answer == state.current.answer) {
      final newStreak = state.streak + 1;
      if (newStreak >= state.requiredStreak) {
        state = state.copyWith(streak: newStreak, solved: true);
        return true;
      }
      state = state.copyWith(
        streak: newStreak,
        consecutiveFailures: 0,
        current: _nextOperation(),
      );
      return true;
    }
    _registerFailure();
    return false;
  }

  /// À appeler lorsque le temps imparti est écoulé : compte comme un échec.
  void timeout() {
    if (state.solved) return;
    _registerFailure();
  }

  void _registerFailure() {
    final failures = state.consecutiveFailures + 1;
    var index = state.effectiveIndex;
    var floor = state.floor;

    // Dégradation par paliers, sans jamais remonter le niveau.
    if (failures >= 12) {
      floor = true;
      index = MathDifficulty.easy.index;
    } else if (failures >= 9) {
      index = MathDifficulty.easy.index;
    } else if (failures == 6) {
      index = (index - 1).clamp(0, MathDifficulty.values.length - 1);
    } else if (failures == 3) {
      index = (index - 1).clamp(0, MathDifficulty.values.length - 1);
    }

    state = state.copyWith(
      streak: 0,
      consecutiveFailures: failures,
      effectiveIndex: index,
      floor: floor,
      current: _gen.generate(
        MathDifficulty.values[index],
        singleDigitFloor: floor,
      ),
    );
  }

  MathOperation _nextOperation() => _gen.generate(
        state.effectiveDifficulty,
        singleDigitFloor: state.floor,
      );
}

/// Fournit un contrôleur par niveau configuré (famille de providers).
final mathLockControllerProvider = StateNotifierProvider.autoDispose
    .family<MathLockController, MathLockState, MathDifficulty>(
  (ref, difficulty) => MathLockController(difficulty),
);
