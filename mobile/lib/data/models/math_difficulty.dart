/// Niveau de difficulté du calcul mental de déblocage (étape 2).
///
/// Les paramètres (plage de nombres, bonnes réponses consécutives, temps limite)
/// reprennent le tableau du cahier des charges. La limite de temps est toujours
/// active (non désactivable).
enum MathDifficulty {
  easy(
    label: 'Facile',
    requiredStreak: 1,
    timeLimitSeconds: 10,
  ),
  medium(
    label: 'Moyen',
    requiredStreak: 2,
    timeLimitSeconds: 15,
  ),
  hard(
    label: 'Difficile',
    requiredStreak: 3,
    timeLimitSeconds: 20,
  ),
  veryHard(
    label: 'Très difficile',
    requiredStreak: 4,
    timeLimitSeconds: 30,
  );

  const MathDifficulty({
    required this.label,
    required this.requiredStreak,
    required this.timeLimitSeconds,
  });

  /// Libellé affiché à l'utilisateur.
  final String label;

  /// Nombre de bonnes réponses consécutives requises pour débloquer.
  final int requiredStreak;

  /// Temps limite par opération, en secondes (toujours actif).
  final int timeLimitSeconds;

  /// Conversion sûre depuis un index stocké en base.
  static MathDifficulty fromIndex(int index) {
    if (index < 0 || index >= MathDifficulty.values.length) {
      return MathDifficulty.easy;
    }
    return MathDifficulty.values[index];
  }
}
