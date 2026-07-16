import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/math_difficulty.dart';
import '../application/math_lock_controller.dart';

/// Écran de l'étape 2 : calcul mental pour débloquer le téléphone.
///
/// Pour l'instant accessible en aperçu depuis l'accueil ; il sera branché à la
/// fin du flux d'alarme (après validation photo).
class MathChallengeScreen extends ConsumerStatefulWidget {
  const MathChallengeScreen({super.key, required this.difficulty});

  final MathDifficulty difficulty;

  @override
  ConsumerState<MathChallengeScreen> createState() =>
      _MathChallengeScreenState();
}

class _MathChallengeScreenState extends ConsumerState<MathChallengeScreen> {
  String _input = '';
  bool _wrong = false;
  int _elapsedMs = 0;
  Timer? _timer;
  String? _lastPrompt;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), _tick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick(Timer _) {
    if (!mounted) return;
    final state = ref.read(mathLockControllerProvider(widget.difficulty));
    if (state.solved) return;
    final limitMs = state.timeLimitSeconds * 1000;
    if (_elapsedMs >= limitMs) {
      // Temps écoulé : échec, nouvelle opération.
      ref.read(mathLockControllerProvider(widget.difficulty).notifier).timeout();
      HapticFeedback.mediumImpact();
      setState(() {
        _elapsedMs = 0;
        _input = '';
      });
    } else {
      setState(() => _elapsedMs += 100);
    }
  }

  void _onKey(String key) {
    final controller =
        ref.read(mathLockControllerProvider(widget.difficulty).notifier);
    setState(() {
      switch (key) {
        case '⌫':
          if (_input.isNotEmpty) {
            _input = _input.substring(0, _input.length - 1);
          }
        case '✓':
          if (_input.isEmpty) return;
          final value = int.tryParse(_input);
          if (value == null) return;
          final correct = controller.submit(value);
          _input = '';
          _elapsedMs = 0;
          if (!correct) {
            _wrong = true;
            HapticFeedback.heavyImpact();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) setState(() => _wrong = false);
            });
          } else {
            HapticFeedback.selectionClick();
          }
        default:
          if (_input.length < 5) _input += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mathLockControllerProvider(widget.difficulty));

    // Réinitialise le chrono quand l'opération change (hors setState de build).
    if (_lastPrompt != null && _lastPrompt != state.current.prompt) {
      _elapsedMs = 0;
    }
    _lastPrompt = state.current.prompt;

    if (state.solved) {
      return _SolvedView(onClose: () => Navigator.of(context).pop(true));
    }

    final limitMs = state.timeLimitSeconds * 1000;
    final progress = (1 - _elapsedMs / limitMs).clamp(0.0, 1.0);
    final secondsLeft = ((limitMs - _elapsedMs) / 1000).ceil();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _Header(state: state),
              const SizedBox(height: 8),
              // Chrono
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceDark,
                  color: progress < 0.25 ? AppColors.error : AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text('$secondsLeft s',
                    style: const TextStyle(
                        color: AppColors.onDarkMuted, fontSize: 12)),
              ),
              const Spacer(),
              // Énoncé
              Text(
                state.current.prompt,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onDark,
                ),
              ),
              const SizedBox(height: 24),
              // Zone de saisie
              Container(
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _wrong ? AppColors.error : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  _input.isEmpty ? '?' : _input,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    color: _input.isEmpty
                        ? AppColors.onDarkMuted
                        : AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              _Keypad(onKey: _onKey),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});
  final MathLockState state;

  @override
  Widget build(BuildContext context) {
    final degraded = state.effectiveIndex < state.configured.index || state.floor;
    return Column(
      children: [
        Text(
          'Calcul mental',
          style: TextStyle(
            color: AppColors.onDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state.floor
              ? 'Niveau : plancher de sécurité'
              : 'Niveau : ${state.effectiveDifficulty.label}'
                  '${degraded ? ' (ajusté)' : ''}',
          style: const TextStyle(color: AppColors.onDarkMuted, fontSize: 12),
        ),
        const SizedBox(height: 10),
        // Série de bonnes réponses consécutives requises.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(state.requiredStreak, (i) {
            final done = i < state.streak;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.primary : AppColors.surfaceDark,
                border: Border.all(color: AppColors.secondary),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});
  final void Function(String) onKey;

  static const _keys = [
    '1', '2', '3', //
    '4', '5', '6', //
    '7', '8', '9', //
    '⌫', '0', '✓', //
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: _keys.map((k) {
        final isValidate = k == '✓';
        final isDelete = k == '⌫';
        return Material(
          color: isValidate ? AppColors.primary : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onKey(k),
            child: Center(
              child: Text(
                k,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: isValidate
                      ? AppColors.black
                      : isDelete
                          ? AppColors.onDarkMuted
                          : AppColors.onDark,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SolvedView extends StatelessWidget {
  const _SolvedView({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                color: AppColors.success, size: 88),
            const SizedBox(height: 20),
            const Text(
              'Téléphone débloqué',
              style: TextStyle(
                color: AppColors.onDark,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bravo, vous êtes bien réveillé !',
              style: TextStyle(color: AppColors.onDarkMuted),
            ),
            const SizedBox(height: 32),
            FilledButton(onPressed: onClose, child: const Text('Terminer')),
          ],
        ),
      ),
    );
  }
}
