# Arise

**Application mobile Android de rappels personnalisés à validation par preuve photo.**

Les alarmes classiques se désactivent d'un simple geste. Arise part d'un autre principe :
pour qu'un rappel soit réellement suivi d'effet, il doit exiger une **action physique réelle
et vérifiable**. Au moment du rappel, l'alarme sonne en plein écran et ne s'arrête que
lorsque l'utilisateur **photographie un objet de référence** de son choix (vérification
automatique), puis résout un **calcul mental** pour débloquer le téléphone.

> Prière, sport, prise de médicament, routine du matin — Arise ancre les habitudes qui
> comptent vraiment.

## Principes clés

- **100% offline** — aucun compte, aucun serveur, aucune connexion internet. Toute la
  logique s'exécute sur l'appareil.
- **Confidentialité totale** — les photos ne quittent jamais le téléphone ; la photo de
  validation est traitée en mémoire puis supprimée.
- **Validation en deux étapes** — preuve photo (coupe la sonnerie) puis calcul mental
  (débloque le téléphone), avec mécanismes anti-blocage pour ne jamais rester coincé.

## Structure du dépôt

```
Arise/
├── docs/      # documentation de cadrage (fonctionnel + technique)
├── mobile/    # application Flutter (Android v1)
└── README.md
```

Le cahier des charges (`arise-cahier-des-charges.pdf`) est un document de référence externe,
non versionné (voir `.gitignore`).

## Documentation

Toute la documentation se trouve dans [`docs/`](docs/) :

- [Vision du projet](docs/vision.md)
- [Spécifications fonctionnelles](docs/specifications-fonctionnelles.md)
- [Parcours utilisateur et écrans](docs/parcours-utilisateur.md)
- [Architecture technique](docs/architecture-technique.md)
- [Contraintes générales](docs/contraintes.md)
- [Roadmap et sprints](docs/roadmap.md)

## Stack technique

| Composant | Choix |
|-----------|-------|
| Framework mobile | Flutter (Android v1) |
| Stockage local | Base embarquée (Hive / Drift) |
| Photos | Système de fichiers privé de l'app |
| Comparaison photo | pHash + histogramme de couleurs (local) |
| Notifications | `flutter_local_notifications` (local) |

## Démarrage (développement)

Prérequis : [Flutter](https://docs.flutter.dev/get-started/install) (canal stable) et un
environnement Android configuré.

```bash
cd mobile
flutter pub get
flutter run
```

## Branches Git

- `main` — branche stable / releases
- `develop` — branche d'intégration du développement courant
