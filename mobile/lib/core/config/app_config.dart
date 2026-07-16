/// Configuration de l'application.
class AppConfig {
  AppConfig._();

  /// URL de base du backend de vérification photo (modèle IA, FastAPI).
  ///
  /// Surchargeable au build sans toucher au code :
  ///   flutter run --dart-define=ARISE_BACKEND_URL=http://192.168.1.20:8000
  ///
  /// Valeur par défaut : `10.0.2.2` = la machine hôte vue depuis l'émulateur
  /// Android. Sur un téléphone physique, utilisez l'IP LAN de votre machine.
  static const backendBaseUrl = String.fromEnvironment(
    'ARISE_BACKEND_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
