import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/math_difficulty.dart';
import '../../../data/models/recurrence.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../alarm/application/alarm_scheduler.dart';
import '../../photo_check/application/photo_service.dart';
import '../application/reminder_providers.dart';

/// Écran de création (reminderId == null) ou d'édition d'un rappel.
class ReminderEditScreen extends ConsumerStatefulWidget {
  const ReminderEditScreen({super.key, this.reminderId});

  final int? reminderId;

  bool get isEditing => reminderId != null;

  @override
  ConsumerState<ReminderEditScreen> createState() => _ReminderEditScreenState();
}

class _ReminderEditScreenState extends ConsumerState<ReminderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  final _photoService = PhotoService();

  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  RecurrenceType _recurrence = RecurrenceType.daily;
  final Set<Weekday> _weekdays = {};
  MathDifficulty _difficulty = MathDifficulty.easy;
  int? _prepMinutes = 10;
  final List<String> _referencePhotos = [];
  String _soundId = 'default';

  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// Pré-remplit le formulaire en mode édition.
  void _hydrate(Reminder r) {
    if (_initialized) return;
    _initialized = true;
    _titleController.text = r.title;
    _time = TimeOfDay(hour: r.hour, minute: r.minute);
    _recurrence = r.recurrence;
    _weekdays
      ..clear()
      ..addAll(r.selectedWeekdays);
    _difficulty = r.difficulty;
    _prepMinutes = r.prepNotificationMinutes;
    _referencePhotos
      ..clear()
      ..addAll(r.referencePhotos);
    _soundId = r.alarmSoundId;
  }

  @override
  Widget build(BuildContext context) {
    // En édition, on attend le chargement du rappel pour hydrater le formulaire.
    if (widget.isEditing && !_initialized) {
      final async = ref.watch(reminderProvider(widget.reminderId!));
      return async.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Erreur : $e')),
        ),
        data: (reminder) {
          if (reminder == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Rappel introuvable.')),
            );
          }
          _hydrate(reminder);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Modifier le rappel' : 'Nouveau rappel'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            _TimePickerTile(
              time: _time,
              onTap: _pickTime,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'Titre du rappel',
                hintText: 'Ex. Prière du matin, Médicament…',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Donnez un titre au rappel'
                  : null,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Récurrence'),
            const SizedBox(height: 8),
            _RecurrenceSelector(
              value: _recurrence,
              onChanged: (v) => setState(() => _recurrence = v),
            ),
            if (_recurrence == RecurrenceType.weekdays) ...[
              const SizedBox(height: 12),
              _WeekdayPicker(
                selected: _weekdays,
                onToggle: (day) => setState(() {
                  _weekdays.contains(day)
                      ? _weekdays.remove(day)
                      : _weekdays.add(day);
                }),
              ),
            ],
            const SizedBox(height: 24),
            _SectionLabel('Difficulté du calcul mental'),
            const SizedBox(height: 8),
            _DifficultySelector(
              value: _difficulty,
              onChanged: (v) => setState(() => _difficulty = v),
            ),
            const SizedBox(height: 24),
            _SectionLabel('Notification de préparation'),
            const SizedBox(height: 8),
            _PrepNotificationSelector(
              value: _prepMinutes,
              onChanged: (v) => setState(() => _prepMinutes = v),
            ),
            const SizedBox(height: 24),
            _SectionLabel('Photos de référence'),
            const SizedBox(height: 4),
            const Text(
              'Photographiez l\'objet à retrouver (2-3 angles conseillés).',
              style: TextStyle(color: AppColors.onDarkMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            _ReferencePhotos(
              paths: _referencePhotos,
              onAdd: _addReferencePhoto,
              onRemove: (path) => setState(() => _referencePhotos.remove(path)),
            ),
            const SizedBox(height: 24),
            _SectionLabel('Son d\'alarme'),
            const SizedBox(height: 8),
            _SoundSelector(
              soundId: _soundId,
              onDefault: () => setState(() => _soundId = 'default'),
              onImport: _importSound,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FilledButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.isEditing ? 'Enregistrer' : 'Créer le rappel'),
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _addReferencePhoto() async {
    final path =
        await _photoService.captureReferencePhoto(seq: _referencePhotos.length);
    if (path != null) setState(() => _referencePhotos.add(path));
  }

  void _importSound() {
    // Import d'un son personnel : différé (voir rapport). Le son par défaut
    // et les chemins de fichiers importés restent gérés par le lecteur.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import d\'un son personnel : bientôt disponible.'),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_recurrence == RecurrenceType.weekdays && _weekdays.isEmpty) {
      _showSnack('Sélectionnez au moins un jour.');
      return;
    }

    setState(() => _loading = true);
    final repo = ref.read(reminderRepositoryProvider);
    final scheduler = ref.read(alarmSchedulerProvider);

    try {
      int reminderId;
      if (widget.isEditing) {
        reminderId = widget.reminderId!;
        final existing = await repo.getReminder(reminderId);
        if (existing != null) {
          await repo.updateReminder(
            existing.copyWith(
              title: _titleController.text.trim(),
              hour: _time.hour,
              minute: _time.minute,
              recurrenceType: _recurrence.index,
              weekdaysMask: _weekdays.toMask(),
              mathDifficulty: _difficulty.index,
              prepNotificationMinutes: Value(_prepMinutes),
              referencePhotos: _referencePhotos,
              alarmSoundId: _soundId,
            ),
          );
        }
      } else {
        reminderId = await repo.createReminder(
          title: _titleController.text.trim(),
          hour: _time.hour,
          minute: _time.minute,
          recurrenceType: _recurrence,
          weekdays: _weekdays,
          mathDifficulty: _difficulty,
          prepNotificationMinutes: _prepMinutes,
          referencePhotos: _referencePhotos,
          alarmSoundId: _soundId,
        );
      }
      // (Re)programme l'alarme.
      final saved = await repo.getReminder(reminderId);
      if (saved != null) await scheduler.schedule(saved);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showSnack('Échec de l\'enregistrement : $e');
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

// --- Sous-widgets ----------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.onDark,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({required this.time, required this.onTap});
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _RecurrenceSelector extends StatelessWidget {
  const _RecurrenceSelector({required this.value, required this.onChanged});
  final RecurrenceType value;
  final ValueChanged<RecurrenceType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<RecurrenceType>(
      segments: RecurrenceType.values
          .map((r) => ButtonSegment(value: r, label: Text(r.label)))
          .toList(),
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _WeekdayPicker extends StatelessWidget {
  const _WeekdayPicker({required this.selected, required this.onToggle});
  final Set<Weekday> selected;
  final ValueChanged<Weekday> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: Weekday.values.map((day) {
        final isSelected = selected.contains(day);
        return ChoiceChip(
          label: Text(day.shortLabel),
          selected: isSelected,
          onSelected: (_) => onToggle(day),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.black : AppColors.onDark,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({required this.value, required this.onChanged});
  final MathDifficulty value;
  final ValueChanged<MathDifficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<MathDifficulty>(
      groupValue: value,
      onChanged: (v) => onChanged(v!),
      child: Column(
        children: MathDifficulty.values.map((level) {
          return RadioListTile<MathDifficulty>(
            value: level,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            title: Text(level.label),
            subtitle: Text(
              '${level.requiredStreak} bonne(s) réponse(s) · ${level.timeLimitSeconds}s / opération',
              style:
                  const TextStyle(color: AppColors.onDarkMuted, fontSize: 12),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PrepNotificationSelector extends StatelessWidget {
  const _PrepNotificationSelector({
    required this.value,
    required this.onChanged,
  });
  final int? value;
  final ValueChanged<int?> onChanged;

  static const _options = <int?>[null, 5, 10, 15, 30];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _options.map((minutes) {
        final isSelected = value == minutes;
        return ChoiceChip(
          label: Text(minutes == null ? 'Aucune' : '$minutes min avant'),
          selected: isSelected,
          onSelected: (_) => onChanged(minutes),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.black : AppColors.onDark,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }
}

class _ReferencePhotos extends StatelessWidget {
  const _ReferencePhotos({
    required this.paths,
    required this.onAdd,
    required this.onRemove,
  });
  final List<String> paths;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final path in paths)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(path),
                        width: 96, height: 96, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => onRemove(path),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary),
              ),
              child: const Icon(Icons.add_a_photo_outlined,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundSelector extends StatelessWidget {
  const _SoundSelector({
    required this.soundId,
    required this.onDefault,
    required this.onImport,
  });
  final String soundId;
  final VoidCallback onDefault;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final isDefault = soundId == 'default';
    final label = isDefault ? 'Son par défaut' : p.basename(soundId);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Par défaut'),
                selected: isDefault,
                onSelected: (_) => onDefault(),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isDefault ? AppColors.black : AppColors.onDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Importer'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Sélectionné : $label',
            style: const TextStyle(color: AppColors.onDarkMuted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
