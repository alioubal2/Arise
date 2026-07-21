import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_settings.dart';
import '../data/verification_api.dart';
import 'photo_service.dart';

/// Client du backend de vérification, construit avec l'URL des réglages.
final photoVerificationApiProvider = Provider<PhotoVerificationApi>((ref) {
  final backendUrl = ref.watch(appSettingsProvider).backendUrl;
  return PhotoVerificationApi(baseUrl: backendUrl);
});

/// Service photo (capture + validation) utilisant l'API configurée.
final photoServiceProvider = Provider<PhotoService>((ref) {
  return PhotoService(api: ref.watch(photoVerificationApiProvider));
});
