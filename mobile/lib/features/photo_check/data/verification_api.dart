import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';

/// Résultat d'une vérification photo par le backend IA.
class VerificationResult {
  const VerificationResult({
    required this.matched,
    required this.confidence,
    this.backendReachable = true,
  });

  /// La photo correspond à l'objet de référence.
  final bool matched;

  /// Niveau de confiance renvoyé par le modèle (0..1).
  final double confidence;

  /// False si le backend est injoignable / a répondu en erreur.
  final bool backendReachable;

  factory VerificationResult.unreachable() =>
      const VerificationResult(matched: false, confidence: 0, backendReachable: false);
}

/// Client du backend de vérification photo (FastAPI + modèle IA).
///
/// Contrat de l'API :
///   POST {baseUrl}/verify   (multipart/form-data)
///     - candidate  : fichier (photo de validation)
///     - references : 1..n fichiers (photos de référence du rappel)
///   Réponse 200 JSON : {"matched": bool, "confidence": number}
class PhotoVerificationApi {
  PhotoVerificationApi({String? baseUrl, http.Client? client})
      : _baseUrl = baseUrl ?? AppConfig.backendBaseUrl,
        _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  /// Teste la disponibilité du backend (GET /health). True si joignable.
  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<VerificationResult> verify({
    required List<String> referencePaths,
    required String candidatePath,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/verify');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
            await http.MultipartFile.fromPath('candidate', candidatePath));
      for (final path in referencePaths) {
        request.files
            .add(await http.MultipartFile.fromPath('references', path));
      }

      final streamed =
          await _client.send(request).timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200) {
        return VerificationResult.unreachable();
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return VerificationResult(
        matched: json['matched'] == true,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      );
    } catch (_) {
      // Réseau indisponible, timeout, hôte injoignable, JSON invalide…
      return VerificationResult.unreachable();
    }
  }
}
