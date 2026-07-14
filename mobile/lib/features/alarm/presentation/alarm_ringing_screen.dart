import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/math_difficulty.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../math_lock/presentation/math_challenge_screen.dart';
import '../../photo_check/application/photo_service.dart';
import '../../photo_check/domain/image_signature.dart';
import '../application/alarm_sound_player.dart';
import '../application/notification_service.dart';

/// Nombre d'échecs photo consécutifs avant de sauter à l'étape calcul mental.
const int kMaxPhotoFailures = 5;

/// Écran d'alarme plein écran : sonnerie bloquante, action unique vers la photo,
/// puis calcul mental. Reproduit le flux du cahier des charges.
class AlarmRingingScreen extends StatefulWidget {
  const AlarmRingingScreen({super.key, required this.reminder});

  final Reminder reminder;

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

enum _Phase { ringing, validating, retry }

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  final _player = AlarmSoundPlayer();
  final _photoService = PhotoService();

  List<ImageSignature> _refSignatures = [];
  int _photoFailures = 0;
  _Phase _phase = _Phase.ringing;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _player.startRinging(widget.reminder.alarmSoundId);
    _loadReferences();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  Future<void> _loadReferences() async {
    final sigs = await _photoService
        .loadReferenceSignatures(widget.reminder.referencePhotos);
    if (mounted) setState(() => _refSignatures = sigs);
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    // Sans photo de référence, on passe directement au calcul mental.
    if (_refSignatures.isEmpty) {
      _goToMath(elevated: false);
      return;
    }
    setState(() => _phase = _Phase.validating);
    final outcome = await _photoService.validateAgainst(
      referenceSignatures: _refSignatures,
      hour: widget.reminder.hour,
    );
    if (!mounted) return;

    if (!outcome.captured) {
      setState(() => _phase = _Phase.ringing);
      return;
    }
    if (outcome.matched) {
      _goToMath(elevated: false);
      return;
    }
    // Échec de correspondance.
    _photoFailures++;
    if (_photoFailures >= kMaxPhotoFailures) {
      // Anti-blocage : on saute la photo, calcul mental à un niveau plus élevé.
      _goToMath(elevated: true);
    } else {
      setState(() => _phase = _Phase.retry);
    }
  }

  Future<void> _goToMath({required bool elevated}) async {
    // Coupe le son, passe en vibreur continu.
    await _player.switchToVibrateOnly();
    if (!mounted) return;

    final base = widget.reminder.difficulty;
    final difficulty = elevated
        ? MathDifficulty.values[
            (base.index + 1).clamp(0, MathDifficulty.values.length - 1)]
        : base;

    final solved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MathChallengeScreen(difficulty: difficulty),
      ),
    );

    if (solved == true) {
      await _player.stopAll();
      await NotificationService.instance.showConfirmation(widget.reminder.title);
      if (mounted) Navigator.of(context).pop(); // ferme l'alarme
    } else {
      // L'utilisateur ne devrait pas pouvoir revenir sans résoudre ; par
      // sécurité, on relance le calcul mental.
      if (mounted) _goToMath(elevated: elevated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final time =
        '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';

    // Écran d'alarme : fond noir pur (identité + focus maximal).
    return PopScope(
      canPop: false, // interface bloquée tant que non validée
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  time,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.reminder.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Image.asset('assets/logo/logo-01-transparent.png', height: 120),
                const SizedBox(height: 24),
                _statusText(),
                const Spacer(),
                FilledButton.icon(
                  onPressed:
                      _phase == _Phase.validating ? null : _takePhoto,
                  icon: const Icon(Icons.photo_camera),
                  label: Text(
                    _refSignatures.isEmpty
                        ? 'Continuer'
                        : 'Prendre la photo',
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusText() {
    switch (_phase) {
      case _Phase.validating:
        return const Text(
          'Vérification de la photo…',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.onDarkMuted),
        );
      case _Phase.retry:
        final remaining = kMaxPhotoFailures - _photoFailures;
        return Text(
          'Photo non reconnue. Réessayez.\n'
          '($remaining tentative(s) avant le calcul mental)',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.warning),
        );
      case _Phase.ringing:
        return Text(
          _refSignatures.isEmpty
              ? 'Aucune photo de référence : appuyez pour continuer.'
              : "Photographiez l'objet associé pour arrêter l'alarme.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.onDarkMuted),
        );
    }
  }
}
