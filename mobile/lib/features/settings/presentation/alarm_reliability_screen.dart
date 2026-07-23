import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';

/// Écran de diagnostic de la fiabilité des alarmes : liste les autorisations
/// nécessaires pour que les alarmes se déclenchent réellement (surtout sur les
/// appareils à gestion de batterie agressive comme Samsung), avec un bouton
/// pour corriger chacune.
class AlarmReliabilityScreen extends StatefulWidget {
  const AlarmReliabilityScreen({super.key});

  @override
  State<AlarmReliabilityScreen> createState() => _AlarmReliabilityScreenState();
}

class _ReliabilityCheck {
  const _ReliabilityCheck({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.permission,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Permission permission;
}

class _AlarmReliabilityScreenState extends State<AlarmReliabilityScreen>
    with WidgetsBindingObserver {
  static const _checks = [
    _ReliabilityCheck(
      icon: Icons.notifications_active_outlined,
      title: 'Notifications',
      subtitle: 'Sans elles, aucune alarme ne peut apparaître.',
      permission: Permission.notification,
    ),
    _ReliabilityCheck(
      icon: Icons.alarm,
      title: 'Alarmes exactes',
      subtitle: 'Pour sonner précisément à l\'heure prévue.',
      permission: Permission.scheduleExactAlarm,
    ),
    _ReliabilityCheck(
      icon: Icons.battery_saver_outlined,
      title: 'Optimisation batterie désactivée',
      subtitle:
          'La cause n°1 des alarmes ratées sur Samsung : l\'app doit pouvoir '
          'fonctionner en arrière-plan sans restriction.',
      permission: Permission.ignoreBatteryOptimizations,
    ),
    _ReliabilityCheck(
      icon: Icons.layers_outlined,
      title: 'Affichage au-dessus des autres apps',
      subtitle: 'Pour afficher l\'alarme par-dessus l\'écran verrouillé.',
      permission: Permission.systemAlertWindow,
    ),
  ];

  final Map<Permission, bool> _granted = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-vérifie au retour depuis les réglages Android.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    for (final check in _checks) {
      _granted[check.permission] = await check.permission.isGranted;
    }
    if (mounted) setState(() {});
  }

  Future<void> _fix(_ReliabilityCheck check) async {
    final status = await check.permission.request();
    if (mounted) setState(() => _granted[check.permission] = status.isGranted);
  }

  bool get _allGood => _checks.every((c) => _granted[c.permission] ?? false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fiabilité des alarmes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Banner(allGood: _allGood),
          const SizedBox(height: 16),
          for (final check in _checks)
            _CheckTile(
              check: check,
              granted: _granted[check.permission] ?? false,
              onFix: () => _fix(check),
            ),
          const SizedBox(height: 20),
          const _SamsungNote(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: openAppSettings,
            icon: const Icon(Icons.settings_applications_outlined, size: 18),
            label: const Text('Ouvrir les réglages Android de l\'app'),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.allGood});
  final bool allGood;

  @override
  Widget build(BuildContext context) {
    final color = allGood ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(allGood ? Icons.check_circle : Icons.warning_amber_rounded,
              color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              allGood
                  ? 'Tout est bon : tes alarmes devraient se déclencher de façon fiable.'
                  : 'Certaines autorisations manquent — tes alarmes risquent de ne pas sonner.',
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.check,
    required this.granted,
    required this.onFix,
  });
  final _ReliabilityCheck check;
  final bool granted;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(check.icon, color: granted ? AppColors.success : AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(check.title,
                    style: const TextStyle(
                        color: AppColors.onDark, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(check.subtitle,
                    style: const TextStyle(
                        color: AppColors.onDarkMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (granted)
            const Icon(Icons.check_circle, color: AppColors.success)
          else
            TextButton(onPressed: onFix, child: const Text('Corriger')),
        ],
      ),
    );
  }
}

class _SamsungNote extends StatelessWidget {
  const _SamsungNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('📌 Samsung / Xiaomi / Huawei',
              style: TextStyle(
                  color: AppColors.onDark, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text(
            'Ces marques « endorment » les apps et annulent leurs alarmes. En plus '
            'des réglages ci-dessus, va dans :\n'
            'Paramètres → Batterie → Limites d\'utilisation en arrière-plan → '
            'retire Arise des « Applications en veille (profonde) ».',
            style: TextStyle(color: AppColors.onDarkMuted, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}
