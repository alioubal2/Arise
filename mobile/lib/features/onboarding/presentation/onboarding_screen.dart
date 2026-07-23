import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_colors.dart';

/// Onboarding au premier lancement : présente le concept puis demande les
/// permissions sensibles en les expliquant (meilleur taux d'octroi).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      ref.read(appSettingsProvider.notifier).completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [_IntroPage(), _PermissionsPage()],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.primary : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_page < 1 ? 'Suivant' : 'Commencer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo/logo-02-transparent.png', width: 200),
          const SizedBox(height: 32),
          const Text(
            'Des rappels qu\'on ne peut pas ignorer',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.onDark,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Au moment du rappel, l\'alarme sonne en plein écran. Pour l\'arrêter, '
            'vous photographiez un objet de référence, puis vous résolvez un '
            'calcul mental. Impossible de se rendormir sans agir.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onDarkMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _PermissionItem {
  const _PermissionItem({
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

class _PermissionsPage extends StatefulWidget {
  const _PermissionsPage();

  @override
  State<_PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<_PermissionsPage> {
  static const _items = [
    _PermissionItem(
      icon: Icons.notifications_active_outlined,
      title: 'Notifications',
      subtitle: 'Pour vous prévenir et déclencher les rappels.',
      permission: Permission.notification,
    ),
    _PermissionItem(
      icon: Icons.alarm,
      title: 'Alarmes exactes',
      subtitle: 'Pour sonner précisément à l\'heure prévue.',
      permission: Permission.scheduleExactAlarm,
    ),
    _PermissionItem(
      icon: Icons.battery_saver_outlined,
      title: 'Fonctionnement en arrière-plan',
      subtitle: 'Indispensable pour que les alarmes se déclenchent (batterie).',
      permission: Permission.ignoreBatteryOptimizations,
    ),
    _PermissionItem(
      icon: Icons.photo_camera_outlined,
      title: 'Caméra',
      subtitle: 'Pour photographier l\'objet de validation.',
      permission: Permission.camera,
    ),
    _PermissionItem(
      icon: Icons.layers_outlined,
      title: 'Affichage au-dessus des autres apps',
      subtitle: 'Pour afficher l\'alarme par-dessus l\'écran verrouillé.',
      permission: Permission.systemAlertWindow,
    ),
  ];

  final Map<Permission, PermissionStatus> _statuses = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    for (final item in _items) {
      _statuses[item.permission] = await item.permission.status;
    }
    if (mounted) setState(() {});
  }

  Future<void> _request(_PermissionItem item) async {
    final status = await item.permission.request();
    if (mounted) setState(() => _statuses[item.permission] = status);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 8),
        const Text(
          'Quelques autorisations',
          style: TextStyle(
            color: AppColors.onDark,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Arise en a besoin pour fonctionner de façon fiable. Vous pourrez les '
          'gérer plus tard dans les réglages Android.',
          style: TextStyle(color: AppColors.onDarkMuted, height: 1.4),
        ),
        const SizedBox(height: 20),
        for (final item in _items)
          _PermissionTile(
            item: item,
            granted: _statuses[item.permission]?.isGranted ?? false,
            onRequest: () => _request(item),
          ),
      ],
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.item,
    required this.granted,
    required this.onRequest,
  });
  final _PermissionItem item;
  final bool granted;
  final VoidCallback onRequest;

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
          Icon(item.icon, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        color: AppColors.onDark, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.subtitle,
                    style: const TextStyle(
                        color: AppColors.onDarkMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (granted)
            const Icon(Icons.check_circle, color: AppColors.success)
          else
            TextButton(onPressed: onRequest, child: const Text('Autoriser')),
        ],
      ),
    );
  }
}
