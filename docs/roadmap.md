# Roadmap et prochaines étapes

## Prochaines étapes (cahier des charges, section 6)

1. Réaliser les **maquettes détaillées** des écrans listés dans
   [parcours-utilisateur.md](parcours-utilisateur.md).
2. Choisir la **direction finale de l'identité visuelle** (logo, couleurs, typographie).
3. **Prototyper et calibrer** la méthode de comparaison photo locale (pHash + histogramme)
   avant le développement complet.
4. Découper le développement en **sprints**.

## Découpage en sprints (proposition)

| Sprint | Objectif | Livrable |
|--------|----------|----------|
| **S0 — Cadrage** | Init projet Flutter, structure du dépôt, docs | ✅ En cours |
| **S1 — Structure & données** | Modèles de rappels, base locale (Hive/Drift), écran Accueil + Création | CRUD des rappels fonctionnel |
| **S2 — Alarme** | Planification, écran d'alarme plein écran, verrouillage, sons | Alarme déclenchée et bloquante |
| **S3 — Comparaison photo** | Capture, calibration multi-photos, pHash + histogramme, tolérance/heure | Validation photo (étape 1) |
| **S4 — Calcul mental** | Niveaux de difficulté, limite de temps, anti-blocage progressif | Déblocage (étape 2) |
| **S5 — Notifications & finitions** | Notifications locales, cas particuliers, tests multi-versions Android | MVP v1 testable |

## Statut actuel

- [x] Dépôt Git initialisé (branches `main` / `develop`)
- [x] Projet Flutter créé dans [`../mobile/`](../mobile/) (Android)
- [x] Documentation de cadrage rédigée dans `docs/`
- [ ] Maquettes des écrans
- [ ] Prototype de comparaison photo
- [ ] Développement des sprints S1 → S5
