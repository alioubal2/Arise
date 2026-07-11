# Documentation — Arise

**Arise** est une application mobile Android **offline-first** de rappels personnalisés
à validation par **preuve photo** puis **calcul mental**.

> Version cahier des charges : 1.0 — 8 juillet 2026 — Statut : cadrage fonctionnel finalisé.

## Index de la documentation

| Document | Contenu |
|----------|---------|
| [vision.md](vision.md) | Contexte, objectif, public cible, identité de marque |
| [specifications-fonctionnelles.md](specifications-fonctionnelles.md) | Fonctionnalités v1 (MVP), versions futures, cas particuliers |
| [parcours-utilisateur.md](parcours-utilisateur.md) | Écrans et parcours utilisateur |
| [architecture-technique.md](architecture-technique.md) | Choix technos, comparaison photo locale, structure du code |
| [contraintes.md](contraintes.md) | Confidentialité, fiabilité, batterie, accès d'urgence |
| [roadmap.md](roadmap.md) | Prochaines étapes et découpage en sprints |

## Source

Le document de référence est [`../arise-cahier-des-charges.pdf`](../arise-cahier-des-charges.pdf).
En cas de divergence, le PDF fait foi jusqu'à mise à jour de cette documentation.

## Structure du dépôt

```
Arise/
├── docs/      # cette documentation
├── mobile/    # application Flutter (Android v1)
└── arise-cahier-des-charges.pdf
```

## Branches Git

- `main` — branche stable / releases
- `develop` — branche d'intégration du développement courant
