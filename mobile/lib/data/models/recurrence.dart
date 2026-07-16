/// Type de récurrence d'un rappel.
enum RecurrenceType {
  once(label: 'Une fois'),
  daily(label: 'Tous les jours'),
  weekdays(label: 'Jours choisis');

  const RecurrenceType({required this.label});

  final String label;

  static RecurrenceType fromIndex(int index) {
    if (index < 0 || index >= RecurrenceType.values.length) {
      return RecurrenceType.once;
    }
    return RecurrenceType.values[index];
  }
}

/// Jours de la semaine, avec un bit dédié pour le stockage en masque.
///
/// L'ensemble des jours sélectionnés est encodé dans un entier (bitmask) afin
/// d'être stocké simplement dans une colonne de la base locale.
enum Weekday {
  monday(bit: 1, shortLabel: 'L', label: 'Lundi'),
  tuesday(bit: 2, shortLabel: 'M', label: 'Mardi'),
  wednesday(bit: 4, shortLabel: 'M', label: 'Mercredi'),
  thursday(bit: 8, shortLabel: 'J', label: 'Jeudi'),
  friday(bit: 16, shortLabel: 'V', label: 'Vendredi'),
  saturday(bit: 32, shortLabel: 'S', label: 'Samedi'),
  sunday(bit: 64, shortLabel: 'D', label: 'Dimanche');

  const Weekday({
    required this.bit,
    required this.shortLabel,
    required this.label,
  });

  final int bit;
  final String shortLabel;
  final String label;

  /// Correspondance avec `DateTime.weekday` (1 = lundi ... 7 = dimanche).
  static Weekday fromDateTime(int dateTimeWeekday) =>
      Weekday.values[dateTimeWeekday - 1];
}

/// Utilitaires d'encodage/décodage du masque de jours de la semaine.
extension WeekdayMask on Set<Weekday> {
  int toMask() => fold(0, (mask, day) => mask | day.bit);
}

Set<Weekday> weekdaysFromMask(int mask) =>
    Weekday.values.where((day) => mask & day.bit != 0).toSet();
