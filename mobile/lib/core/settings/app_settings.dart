import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Instance de SharedPreferences, injectée au démarrage (override dans main).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences non initialisé');
});

/// Réglages persistants de l'application.
class AppSettings {
  const AppSettings({required this.backendUrl, required this.onboardingDone});

  /// URL du backend de vérification photo.
  final String backendUrl;

  /// L'onboarding (permissions) a été complété.
  final bool onboardingDone;

  AppSettings copyWith({String? backendUrl, bool? onboardingDone}) => AppSettings(
        backendUrl: backendUrl ?? this.backendUrl,
        onboardingDone: onboardingDone ?? this.onboardingDone,
      );
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _kBackendUrl = 'backend_url';
  static const _kOnboarding = 'onboarding_done';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      backendUrl: prefs.getString(_kBackendUrl) ?? AppConfig.backendBaseUrl,
      onboardingDone: prefs.getBool(_kOnboarding) ?? false,
    );
  }

  Future<void> setBackendUrl(String url) async {
    final cleaned = url.trim();
    await _prefs.setString(_kBackendUrl, cleaned);
    state = state.copyWith(backendUrl: cleaned);
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_kOnboarding, true);
    state = state.copyWith(onboardingDone: true);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);
