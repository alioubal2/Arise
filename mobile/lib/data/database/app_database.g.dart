// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceTypeMeta = const VerificationMeta(
    'recurrenceType',
  );
  @override
  late final GeneratedColumn<int> recurrenceType = GeneratedColumn<int>(
    'recurrence_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _weekdaysMaskMeta = const VerificationMeta(
    'weekdaysMask',
  );
  @override
  late final GeneratedColumn<int> weekdaysMask = GeneratedColumn<int>(
    'weekdays_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  referencePhotos = GeneratedColumn<String>(
    'reference_photos',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($RemindersTable.$converterreferencePhotos);
  static const VerificationMeta _alarmSoundIdMeta = const VerificationMeta(
    'alarmSoundId',
  );
  @override
  late final GeneratedColumn<String> alarmSoundId = GeneratedColumn<String>(
    'alarm_sound_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _mathDifficultyMeta = const VerificationMeta(
    'mathDifficulty',
  );
  @override
  late final GeneratedColumn<int> mathDifficulty = GeneratedColumn<int>(
    'math_difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _prepNotificationMinutesMeta =
      const VerificationMeta('prepNotificationMinutes');
  @override
  late final GeneratedColumn<int> prepNotificationMinutes =
      GeneratedColumn<int>(
        'prep_notification_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    hour,
    minute,
    recurrenceType,
    weekdaysMask,
    referencePhotos,
    alarmSoundId,
    mathDifficulty,
    prepNotificationMinutes,
    enabled,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    } else if (isInserting) {
      context.missing(_minuteMeta);
    }
    if (data.containsKey('recurrence_type')) {
      context.handle(
        _recurrenceTypeMeta,
        recurrenceType.isAcceptableOrUnknown(
          data['recurrence_type']!,
          _recurrenceTypeMeta,
        ),
      );
    }
    if (data.containsKey('weekdays_mask')) {
      context.handle(
        _weekdaysMaskMeta,
        weekdaysMask.isAcceptableOrUnknown(
          data['weekdays_mask']!,
          _weekdaysMaskMeta,
        ),
      );
    }
    if (data.containsKey('alarm_sound_id')) {
      context.handle(
        _alarmSoundIdMeta,
        alarmSoundId.isAcceptableOrUnknown(
          data['alarm_sound_id']!,
          _alarmSoundIdMeta,
        ),
      );
    }
    if (data.containsKey('math_difficulty')) {
      context.handle(
        _mathDifficultyMeta,
        mathDifficulty.isAcceptableOrUnknown(
          data['math_difficulty']!,
          _mathDifficultyMeta,
        ),
      );
    }
    if (data.containsKey('prep_notification_minutes')) {
      context.handle(
        _prepNotificationMinutesMeta,
        prepNotificationMinutes.isAcceptableOrUnknown(
          data['prep_notification_minutes']!,
          _prepNotificationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
      recurrenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_type'],
      )!,
      weekdaysMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays_mask'],
      )!,
      referencePhotos: $RemindersTable.$converterreferencePhotos.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reference_photos'],
        )!,
      ),
      alarmSoundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alarm_sound_id'],
      )!,
      mathDifficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}math_difficulty'],
      )!,
      prepNotificationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prep_notification_minutes'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterreferencePhotos =
      const StringListConverter();
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final String title;

  /// Heure du rappel (0-23) et minutes (0-59).
  final int hour;
  final int minute;

  /// Index de [RecurrenceType].
  final int recurrenceType;

  /// Masque binaire des jours de la semaine (voir [Weekday]).
  final int weekdaysMask;

  /// Chemins locaux des photos de référence (calibration multi-photos).
  final List<String> referencePhotos;

  /// Identifiant du son d'alarme sélectionné.
  final String alarmSoundId;

  /// Index de [MathDifficulty] pour le calcul mental de déblocage.
  final int mathDifficulty;

  /// Minutes avant l'heure du rappel pour la notification de préparation.
  /// `null` = pas de notification de préparation.
  final int? prepNotificationMinutes;

  /// Rappel actif ou non.
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Reminder({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    required this.recurrenceType,
    required this.weekdaysMask,
    required this.referencePhotos,
    required this.alarmSoundId,
    required this.mathDifficulty,
    this.prepNotificationMinutes,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['hour'] = Variable<int>(hour);
    map['minute'] = Variable<int>(minute);
    map['recurrence_type'] = Variable<int>(recurrenceType);
    map['weekdays_mask'] = Variable<int>(weekdaysMask);
    {
      map['reference_photos'] = Variable<String>(
        $RemindersTable.$converterreferencePhotos.toSql(referencePhotos),
      );
    }
    map['alarm_sound_id'] = Variable<String>(alarmSoundId);
    map['math_difficulty'] = Variable<int>(mathDifficulty);
    if (!nullToAbsent || prepNotificationMinutes != null) {
      map['prep_notification_minutes'] = Variable<int>(prepNotificationMinutes);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      title: Value(title),
      hour: Value(hour),
      minute: Value(minute),
      recurrenceType: Value(recurrenceType),
      weekdaysMask: Value(weekdaysMask),
      referencePhotos: Value(referencePhotos),
      alarmSoundId: Value(alarmSoundId),
      mathDifficulty: Value(mathDifficulty),
      prepNotificationMinutes: prepNotificationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(prepNotificationMinutes),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      hour: serializer.fromJson<int>(json['hour']),
      minute: serializer.fromJson<int>(json['minute']),
      recurrenceType: serializer.fromJson<int>(json['recurrenceType']),
      weekdaysMask: serializer.fromJson<int>(json['weekdaysMask']),
      referencePhotos: serializer.fromJson<List<String>>(
        json['referencePhotos'],
      ),
      alarmSoundId: serializer.fromJson<String>(json['alarmSoundId']),
      mathDifficulty: serializer.fromJson<int>(json['mathDifficulty']),
      prepNotificationMinutes: serializer.fromJson<int?>(
        json['prepNotificationMinutes'],
      ),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'hour': serializer.toJson<int>(hour),
      'minute': serializer.toJson<int>(minute),
      'recurrenceType': serializer.toJson<int>(recurrenceType),
      'weekdaysMask': serializer.toJson<int>(weekdaysMask),
      'referencePhotos': serializer.toJson<List<String>>(referencePhotos),
      'alarmSoundId': serializer.toJson<String>(alarmSoundId),
      'mathDifficulty': serializer.toJson<int>(mathDifficulty),
      'prepNotificationMinutes': serializer.toJson<int?>(
        prepNotificationMinutes,
      ),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Reminder copyWith({
    int? id,
    String? title,
    int? hour,
    int? minute,
    int? recurrenceType,
    int? weekdaysMask,
    List<String>? referencePhotos,
    String? alarmSoundId,
    int? mathDifficulty,
    Value<int?> prepNotificationMinutes = const Value.absent(),
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Reminder(
    id: id ?? this.id,
    title: title ?? this.title,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    recurrenceType: recurrenceType ?? this.recurrenceType,
    weekdaysMask: weekdaysMask ?? this.weekdaysMask,
    referencePhotos: referencePhotos ?? this.referencePhotos,
    alarmSoundId: alarmSoundId ?? this.alarmSoundId,
    mathDifficulty: mathDifficulty ?? this.mathDifficulty,
    prepNotificationMinutes: prepNotificationMinutes.present
        ? prepNotificationMinutes.value
        : this.prepNotificationMinutes,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      hour: data.hour.present ? data.hour.value : this.hour,
      minute: data.minute.present ? data.minute.value : this.minute,
      recurrenceType: data.recurrenceType.present
          ? data.recurrenceType.value
          : this.recurrenceType,
      weekdaysMask: data.weekdaysMask.present
          ? data.weekdaysMask.value
          : this.weekdaysMask,
      referencePhotos: data.referencePhotos.present
          ? data.referencePhotos.value
          : this.referencePhotos,
      alarmSoundId: data.alarmSoundId.present
          ? data.alarmSoundId.value
          : this.alarmSoundId,
      mathDifficulty: data.mathDifficulty.present
          ? data.mathDifficulty.value
          : this.mathDifficulty,
      prepNotificationMinutes: data.prepNotificationMinutes.present
          ? data.prepNotificationMinutes.value
          : this.prepNotificationMinutes,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('weekdaysMask: $weekdaysMask, ')
          ..write('referencePhotos: $referencePhotos, ')
          ..write('alarmSoundId: $alarmSoundId, ')
          ..write('mathDifficulty: $mathDifficulty, ')
          ..write('prepNotificationMinutes: $prepNotificationMinutes, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    hour,
    minute,
    recurrenceType,
    weekdaysMask,
    referencePhotos,
    alarmSoundId,
    mathDifficulty,
    prepNotificationMinutes,
    enabled,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.title == this.title &&
          other.hour == this.hour &&
          other.minute == this.minute &&
          other.recurrenceType == this.recurrenceType &&
          other.weekdaysMask == this.weekdaysMask &&
          other.referencePhotos == this.referencePhotos &&
          other.alarmSoundId == this.alarmSoundId &&
          other.mathDifficulty == this.mathDifficulty &&
          other.prepNotificationMinutes == this.prepNotificationMinutes &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> hour;
  final Value<int> minute;
  final Value<int> recurrenceType;
  final Value<int> weekdaysMask;
  final Value<List<String>> referencePhotos;
  final Value<String> alarmSoundId;
  final Value<int> mathDifficulty;
  final Value<int?> prepNotificationMinutes;
  final Value<bool> enabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.weekdaysMask = const Value.absent(),
    this.referencePhotos = const Value.absent(),
    this.alarmSoundId = const Value.absent(),
    this.mathDifficulty = const Value.absent(),
    this.prepNotificationMinutes = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int hour,
    required int minute,
    this.recurrenceType = const Value.absent(),
    this.weekdaysMask = const Value.absent(),
    this.referencePhotos = const Value.absent(),
    this.alarmSoundId = const Value.absent(),
    this.mathDifficulty = const Value.absent(),
    this.prepNotificationMinutes = const Value.absent(),
    this.enabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : title = Value(title),
       hour = Value(hour),
       minute = Value(minute),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? hour,
    Expression<int>? minute,
    Expression<int>? recurrenceType,
    Expression<int>? weekdaysMask,
    Expression<String>? referencePhotos,
    Expression<String>? alarmSoundId,
    Expression<int>? mathDifficulty,
    Expression<int>? prepNotificationMinutes,
    Expression<bool>? enabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (recurrenceType != null) 'recurrence_type': recurrenceType,
      if (weekdaysMask != null) 'weekdays_mask': weekdaysMask,
      if (referencePhotos != null) 'reference_photos': referencePhotos,
      if (alarmSoundId != null) 'alarm_sound_id': alarmSoundId,
      if (mathDifficulty != null) 'math_difficulty': mathDifficulty,
      if (prepNotificationMinutes != null)
        'prep_notification_minutes': prepNotificationMinutes,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? hour,
    Value<int>? minute,
    Value<int>? recurrenceType,
    Value<int>? weekdaysMask,
    Value<List<String>>? referencePhotos,
    Value<String>? alarmSoundId,
    Value<int>? mathDifficulty,
    Value<int?>? prepNotificationMinutes,
    Value<bool>? enabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      weekdaysMask: weekdaysMask ?? this.weekdaysMask,
      referencePhotos: referencePhotos ?? this.referencePhotos,
      alarmSoundId: alarmSoundId ?? this.alarmSoundId,
      mathDifficulty: mathDifficulty ?? this.mathDifficulty,
      prepNotificationMinutes:
          prepNotificationMinutes ?? this.prepNotificationMinutes,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (recurrenceType.present) {
      map['recurrence_type'] = Variable<int>(recurrenceType.value);
    }
    if (weekdaysMask.present) {
      map['weekdays_mask'] = Variable<int>(weekdaysMask.value);
    }
    if (referencePhotos.present) {
      map['reference_photos'] = Variable<String>(
        $RemindersTable.$converterreferencePhotos.toSql(referencePhotos.value),
      );
    }
    if (alarmSoundId.present) {
      map['alarm_sound_id'] = Variable<String>(alarmSoundId.value);
    }
    if (mathDifficulty.present) {
      map['math_difficulty'] = Variable<int>(mathDifficulty.value);
    }
    if (prepNotificationMinutes.present) {
      map['prep_notification_minutes'] = Variable<int>(
        prepNotificationMinutes.value,
      );
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('weekdaysMask: $weekdaysMask, ')
          ..write('referencePhotos: $referencePhotos, ')
          ..write('alarmSoundId: $alarmSoundId, ')
          ..write('mathDifficulty: $mathDifficulty, ')
          ..write('prepNotificationMinutes: $prepNotificationMinutes, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [reminders];
}

typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      required String title,
      required int hour,
      required int minute,
      Value<int> recurrenceType,
      Value<int> weekdaysMask,
      Value<List<String>> referencePhotos,
      Value<String> alarmSoundId,
      Value<int> mathDifficulty,
      Value<int?> prepNotificationMinutes,
      Value<bool> enabled,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> hour,
      Value<int> minute,
      Value<int> recurrenceType,
      Value<int> weekdaysMask,
      Value<List<String>> referencePhotos,
      Value<String> alarmSoundId,
      Value<int> mathDifficulty,
      Value<int?> prepNotificationMinutes,
      Value<bool> enabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get referencePhotos => $composableBuilder(
    column: $table.referencePhotos,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get alarmSoundId => $composableBuilder(
    column: $table.alarmSoundId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mathDifficulty => $composableBuilder(
    column: $table.mathDifficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prepNotificationMinutes => $composableBuilder(
    column: $table.prepNotificationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referencePhotos => $composableBuilder(
    column: $table.referencePhotos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alarmSoundId => $composableBuilder(
    column: $table.alarmSoundId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mathDifficulty => $composableBuilder(
    column: $table.mathDifficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prepNotificationMinutes => $composableBuilder(
    column: $table.prepNotificationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<int> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get referencePhotos =>
      $composableBuilder(
        column: $table.referencePhotos,
        builder: (column) => column,
      );

  GeneratedColumn<String> get alarmSoundId => $composableBuilder(
    column: $table.alarmSoundId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mathDifficulty => $composableBuilder(
    column: $table.mathDifficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get prepNotificationMinutes => $composableBuilder(
    column: $table.prepNotificationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
          Reminder,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<int> recurrenceType = const Value.absent(),
                Value<int> weekdaysMask = const Value.absent(),
                Value<List<String>> referencePhotos = const Value.absent(),
                Value<String> alarmSoundId = const Value.absent(),
                Value<int> mathDifficulty = const Value.absent(),
                Value<int?> prepNotificationMinutes = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                title: title,
                hour: hour,
                minute: minute,
                recurrenceType: recurrenceType,
                weekdaysMask: weekdaysMask,
                referencePhotos: referencePhotos,
                alarmSoundId: alarmSoundId,
                mathDifficulty: mathDifficulty,
                prepNotificationMinutes: prepNotificationMinutes,
                enabled: enabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int hour,
                required int minute,
                Value<int> recurrenceType = const Value.absent(),
                Value<int> weekdaysMask = const Value.absent(),
                Value<List<String>> referencePhotos = const Value.absent(),
                Value<String> alarmSoundId = const Value.absent(),
                Value<int> mathDifficulty = const Value.absent(),
                Value<int?> prepNotificationMinutes = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => RemindersCompanion.insert(
                id: id,
                title: title,
                hour: hour,
                minute: minute,
                recurrenceType: recurrenceType,
                weekdaysMask: weekdaysMask,
                referencePhotos: referencePhotos,
                alarmSoundId: alarmSoundId,
                mathDifficulty: mathDifficulty,
                prepNotificationMinutes: prepNotificationMinutes,
                enabled: enabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
      Reminder,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
}
