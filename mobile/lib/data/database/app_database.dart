import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'dart:io';

part 'app_database.g.dart';

/// Convertit une liste de chemins de photos <-> une chaîne JSON stockée en base.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded.cast<String>();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// Table des rappels (offline-first, stockage 100% local).
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  /// Heure du rappel (0-23) et minutes (0-59).
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();

  /// Index de [RecurrenceType].
  IntColumn get recurrenceType => integer().withDefault(const Constant(0))();

  /// Masque binaire des jours de la semaine (voir [Weekday]).
  IntColumn get weekdaysMask => integer().withDefault(const Constant(0))();

  /// Chemins locaux des photos de référence (calibration multi-photos).
  TextColumn get referencePhotos =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();

  /// Identifiant du son d'alarme sélectionné.
  TextColumn get alarmSoundId =>
      text().withDefault(const Constant('default'))();

  /// Index de [MathDifficulty] pour le calcul mental de déblocage.
  IntColumn get mathDifficulty => integer().withDefault(const Constant(0))();

  /// Minutes avant l'heure du rappel pour la notification de préparation.
  /// `null` = pas de notification de préparation.
  IntColumn get prepNotificationMinutes => integer().nullable()();

  /// Rappel actif ou non.
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [Reminders])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructeur de test permettant d'injecter une base en mémoire.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // --- Requêtes CRUD --------------------------------------------------------

  /// Flux réactif de tous les rappels, triés par heure.
  Stream<List<Reminder>> watchReminders() {
    return (select(reminders)
          ..orderBy([
            (r) => OrderingTerm(expression: r.hour),
            (r) => OrderingTerm(expression: r.minute),
          ]))
        .watch();
  }

  Future<Reminder?> getReminder(int id) =>
      (select(reminders)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<int> insertReminder(RemindersCompanion entry) =>
      into(reminders).insert(entry);

  Future<bool> updateReminder(Reminder entry) =>
      update(reminders).replace(entry);

  Future<int> deleteReminder(int id) =>
      (delete(reminders)..where((r) => r.id.equals(id))).go();

  /// Active / désactive un rappel sans réécrire tout l'objet.
  Future<int> setEnabled(int id, bool enabled) {
    return (update(reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(
        enabled: Value(enabled),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

/// Ouvre la connexion sur un fichier SQLite dans le stockage privé de l'app.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'arise.sqlite'));

    // Contournement d'un vieux bug de verrouillage sur certains Android anciens.
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

    return NativeDatabase.createInBackground(file);
  });
}
