import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

/// Gère le son d'alarme (boucle) et la vibration pendant le flux d'alarme.
///
/// - Phase sonnerie : son en boucle + vibration rythmée.
/// - Phase calcul mental (après validation photo) : vibreur continu, sans son.
class AlarmSoundPlayer {
  final AudioPlayer _player = AudioPlayer();
  bool _hasVibrator = false;

  static const _defaultSoundId = 'default';

  /// Démarre la sonnerie plein écran (son + vibration rythmée).
  Future<void> startRinging(String soundId) async {
    _hasVibrator = await Vibration.hasVibrator();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(1.0);
    await _player.play(_sourceFor(soundId));
    if (_hasVibrator) {
      // Motif : pause / vibre / pause, en boucle.
      Vibration.vibrate(pattern: [0, 700, 500], repeat: 0);
    }
  }

  /// Coupe le son et passe en vibreur continu (étape calcul mental).
  Future<void> switchToVibrateOnly() async {
    await _player.stop();
    if (_hasVibrator) {
      Vibration.cancel();
      Vibration.vibrate(pattern: [0, 1000, 300], repeat: 0);
    }
  }

  /// Arrête tout (fin du flux ou annulation).
  Future<void> stopAll() async {
    await _player.stop();
    if (_hasVibrator) Vibration.cancel();
  }

  Future<void> dispose() async {
    await stopAll();
    await _player.dispose();
  }

  Source _sourceFor(String soundId) {
    if (soundId == _defaultSoundId || soundId.isEmpty) {
      return AssetSource('sounds/alarm_default.wav');
    }
    // Sinon, chemin d'un fichier audio importé par l'utilisateur.
    return DeviceFileSource(soundId);
  }
}
