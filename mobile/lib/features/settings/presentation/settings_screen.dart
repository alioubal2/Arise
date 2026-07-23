import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../photo_check/data/verification_api.dart';
import 'alarm_reliability_screen.dart';

/// Réglages de l'app : configuration du backend de vérification photo.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

enum _TestState { idle, testing, ok, failed }

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _urlController;
  _TestState _testState = _TestState.idle;

  @override
  void initState() {
    super.initState();
    _urlController =
        TextEditingController(text: ref.read(appSettingsProvider).backendUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(appSettingsProvider.notifier)
        .setBackendUrl(_urlController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL du backend enregistrée.')),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() => _testState = _TestState.testing);
    final api = PhotoVerificationApi(baseUrl: _urlController.text.trim());
    final ok = await api.checkHealth();
    if (mounted) {
      setState(() => _testState = ok ? _TestState.ok : _TestState.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Backend de vérification photo',
            style: TextStyle(
              color: AppColors.onDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Adresse du serveur qui vérifie les photos (IA). '
            'Émulateur : http://10.0.2.2:8000 · Téléphone : http://IP-du-PC:8000',
            style: TextStyle(color: AppColors.onDarkMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            onChanged: (_) => setState(() => _testState = _TestState.idle),
            decoration: const InputDecoration(
              labelText: 'URL du backend',
              hintText: 'http://10.0.2.2:8000',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _testState == _TestState.testing ? null : _testConnection,
                  icon: _testState == _TestState.testing
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering, size: 18),
                  label: const Text('Tester'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _statusBanner(),
          const Divider(height: 40),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.alarm_on_outlined,
                color: AppColors.primary),
            title: const Text('Fiabilité des alarmes',
                style: TextStyle(color: AppColors.onDark)),
            subtitle: const Text(
              'Vérifier les autorisations (batterie, alarmes exactes…)',
              style: TextStyle(color: AppColors.onDarkMuted, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.onDarkMuted),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AlarmReliabilityScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBanner() {
    switch (_testState) {
      case _TestState.ok:
        return const _Banner(
          color: AppColors.success,
          icon: Icons.check_circle,
          text: 'Backend joignable ✓',
        );
      case _TestState.failed:
        return const _Banner(
          color: AppColors.error,
          icon: Icons.error_outline,
          text: 'Backend injoignable. Vérifiez l\'URL et que le serveur tourne.',
        );
      case _TestState.idle:
      case _TestState.testing:
        return const SizedBox.shrink();
    }
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.color, required this.icon, required this.text});
  final Color color;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
