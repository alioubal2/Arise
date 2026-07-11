# Architecture technique

## 1. Plateforme et principe offline-first

**Android en priorité pour la version 1.**

Principe directeur : l'application est **entièrement autonome et fonctionne à 100% sans
connexion internet, sans exception**. Aucun serveur, aucune base de données distante, aucun
compte utilisateur. Toute la logique — rappels, alarme, comparaison photo, calcul mental,
notifications — s'exécute directement sur l'appareil.

- Aucune création de compte ni connexion requise, dès le premier lancement
- Création, modification et déclenchement des rappels : 100% local
- Comparaison photo : entièrement locale, aucun appel réseau
- Calcul mental : entièrement local
- Notifications : générées localement sur l'appareil
- Aucune donnée personnelle (photos, habitudes de rappel) ne quitte jamais le téléphone

## 2. Choix technologiques retenus

| Composant | Choix retenu |
|-----------|--------------|
| Framework mobile | **Flutter** |
| Stockage local des rappels et réglages | Base de données embarquée (ex. **Hive** ou **Drift**) |
| Stockage des photos | Système de fichiers local de l'application |
| Comparaison photo | **Hash perceptuel (pHash)** combiné à une **comparaison d'histogramme de couleurs** |
| Notifications | Notifications locales (**flutter_local_notifications**), sans dépendance réseau |

> Le projet Flutter est initialisé dans [`../mobile/`](../mobile/)
> (org `com.arise`, application `arise`, plateforme Android).

## 3. Méthode de comparaison photo locale

La comparaison repose sur deux techniques complémentaires, exécutées **entièrement sur
l'appareil** :

1. **Hash perceptuel (pHash)** : transforme chaque image en une empreinte compacte basée
   sur ses formes et contrastes globaux, peu sensible aux petites variations (légère
   compression, recadrage mineur).
2. **Histogramme de couleurs** : compare la répartition des couleurs dominantes entre les
   deux photos, en complément du hash, pour réduire les faux positifs entre deux objets de
   forme proche.

**Limites connues** (sans IA) : sensibilité plus élevée à un changement d'angle important
ou à un fort écart de luminosité (ex. photo de jour comparée à une prise dans le noir).
Ces limites sont compensées par :

- la **calibration multi-photos** à la création du rappel,
- l'**ajustement de tolérance selon l'heure**,
- le **mécanisme anti-blocage** qui bascule vers le calcul mental après plusieurs échecs.

> Le réglage fin de la tolérance (pHash + histogramme) est un **point critique** à
> prototyper et calibrer soigneusement avant le développement complet, puisqu'il devient la
> seule méthode de validation photo.

## 4. Points d'attention techniques

- **iOS** : la prise en charge est fortement limitée par les restrictions d'Apple sur le
  blocage d'écran et les alarmes en arrière-plan ; une expérience équivalente à Android n'y
  est pas garantie. Ce point conditionne le choix de ne développer qu'Android pour la v1.
- Le sans-IA (pHash + histogramme) est le filet de sécurité de validation : à tester
  soigneusement avant mise en production.
- Les **notifications locales ne remplacent pas** le mécanisme d'alarme lui-même : celui-ci
  doit continuer à fonctionner de façon autonome ; les notifications ne sont qu'un
  complément informatif.

## 5. Organisation du code (proposition)

Structure Flutter suggérée pour `mobile/lib/` au fil du développement :

```
lib/
├── main.dart
├── core/            # thème, constantes, utilitaires transverses
├── data/            # modèles, base locale (Hive/Drift), stockage photos
├── features/
│   ├── reminders/   # création, liste, réglages des rappels
│   ├── alarm/       # écran d'alarme plein écran, verrouillage
│   ├── photo_check/ # capture + comparaison pHash/histogramme
│   └── math_lock/   # calcul mental, niveaux, anti-blocage
└── services/        # notifications locales, planification des alarmes
```

> À affiner lors du découpage en sprints (voir [roadmap.md](roadmap.md)).
