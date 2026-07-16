import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/verification_api.dart';

/// Résultat d'une tentative de validation photo.
class PhotoValidationOutcome {
  const PhotoValidationOutcome({
    required this.captured,
    required this.matched,
    this.backendReachable = true,
  });

  /// L'utilisateur a bien pris une photo (false s'il a annulé la caméra).
  final bool captured;

  /// La photo correspond (selon le backend IA).
  final bool matched;

  /// False si le backend de vérification est injoignable.
  final bool backendReachable;
}

/// Capture des photos et validation via le backend IA.
///
/// La comparaison n'est plus locale : la photo de validation est envoyée à un
/// backend FastAPI (modèle IA) avec les photos de référence. Les photos de
/// référence restent stockées dans l'espace privé de l'app.
class PhotoService {
  PhotoService({PhotoVerificationApi? api})
      : _api = api ?? PhotoVerificationApi();

  final ImagePicker _picker = ImagePicker();
  final PhotoVerificationApi _api;

  Future<Directory> _referencesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'reference_photos'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Capture une photo de référence et l'enregistre dans l'espace privé.
  /// Renvoie le chemin, ou null si annulé.
  Future<String?> captureReferencePhoto({int? seq}) async {
    final shot = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (shot == null) return null;
    final dir = await _referencesDir();
    final name = 'ref_${seq ?? 0}_${shot.name}';
    final dest = p.join(dir.path, name);
    await File(shot.path).copy(dest);
    return dest;
  }

  /// Supprime les fichiers de photos de référence donnés (rappel supprimé).
  Future<void> deleteReferencePhotos(List<String> paths) async {
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }

  /// Capture une photo de validation et la fait vérifier par le backend IA.
  /// La photo de validation n'est pas conservée.
  Future<PhotoValidationOutcome> validateAgainst({
    required List<String> referencePaths,
  }) async {
    final shot = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (shot == null) {
      return const PhotoValidationOutcome(captured: false, matched: false);
    }
    final result = await _api.verify(
      referencePaths: referencePaths,
      candidatePath: shot.path,
    );
    // Suppression immédiate de la photo de validation.
    try {
      await File(shot.path).delete();
    } catch (_) {}

    return PhotoValidationOutcome(
      captured: true,
      matched: result.matched,
      backendReachable: result.backendReachable,
    );
  }
}
