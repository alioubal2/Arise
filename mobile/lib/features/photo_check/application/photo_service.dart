import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/image_comparator.dart';
import '../domain/image_signature.dart';

/// Résultat d'une tentative de validation photo.
class PhotoValidationOutcome {
  const PhotoValidationOutcome({
    required this.captured,
    required this.result,
  });

  /// L'utilisateur a bien pris une photo (false s'il a annulé la caméra).
  final bool captured;

  /// Résultat de la comparaison (null si aucune photo prise).
  final ComparisonResult? result;

  bool get matched => result?.matched ?? false;
}

/// Capture et validation des photos, 100% local.
///
/// Les photos de référence sont conservées dans l'espace privé de l'app ; la
/// photo de validation est traitée en mémoire puis jamais conservée.
class PhotoService {
  final ImagePicker _picker = ImagePicker();

  Future<Directory> _referencesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'reference_photos'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Ouvre la caméra pour capturer une photo de référence et l'enregistre
  /// dans l'espace privé. Renvoie le chemin, ou null si annulé.
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

  /// Calcule les signatures des photos de référence (au moment de la validation).
  Future<List<ImageSignature>> loadReferenceSignatures(
      List<String> paths) async {
    final signatures = <ImageSignature>[];
    for (final path in paths) {
      final file = File(path);
      if (!await file.exists()) continue;
      final sig = computeSignature(await file.readAsBytes());
      if (sig != null) signatures.add(sig);
    }
    return signatures;
  }

  /// Capture une photo de validation et la compare aux références.
  /// La photo de validation n'est jamais conservée.
  Future<PhotoValidationOutcome> validateAgainst({
    required List<ImageSignature> referenceSignatures,
    required int hour,
  }) async {
    final shot = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (shot == null) {
      return const PhotoValidationOutcome(captured: false, result: null);
    }
    final bytes = await shot.readAsBytes();
    final candidate = computeSignature(bytes);
    if (candidate == null) {
      return const PhotoValidationOutcome(captured: true, result: null);
    }
    final result = compareAgainstReferences(
      referenceSignatures,
      candidate,
      MatchTolerance.forHour(hour),
    );
    return PhotoValidationOutcome(captured: true, result: result);
  }
}
