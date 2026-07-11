# Parcours utilisateur et écrans

| Écran | Contenu / rôle |
|-------|----------------|
| **Accueil** | Liste des rappels actifs, accès à la création d'un nouveau rappel |
| **Création de rappel** | Titre, heure, récurrence, capture de la/des photo(s) de référence |
| **Écran d'alarme** | Plein écran, verrouillé, sonnerie active, bouton unique vers l'appareil photo |
| **Vérification photo** | Prise de la photo, retour visuel du résultat (validé / à refaire) ; en cas de succès, coupe le son et enchaîne sur le calcul mental |
| **Calcul mental** | Opération affichée selon le niveau de difficulté choisi ; le téléphone reste bloqué tant que la réponse est incorrecte |
| **Réglages du rappel** | Choix du niveau de difficulté du calcul mental, mise à jour de la photo de référence |
| **Historique (v2)** | Statistiques de suivi et de régularité |

## Enchaînement de l'alarme (flux critique)

```
Heure du rappel
      │
      ▼
┌─────────────────────┐
│  Écran d'alarme      │  sonnerie plein écran, interface bloquée
│  (téléphone verrou.) │  seule action : appareil photo
└─────────┬───────────┘
          ▼
┌─────────────────────┐   échec x5
│  Vérification photo  │ ──────────────┐  (anti-blocage : saute l'étape,
│  (étape 1)           │               │   calcul mental démarre plus haut)
└─────────┬───────────┘               │
   photo OK → son coupé               │
          ▼                           ▼
┌─────────────────────────────────────────┐
│  Calcul mental (étape 2)                 │  vibreur continu, téléphone
│  N bonnes réponses consécutives requises │  toujours verrouillé
│  dégradation progressive si échecs       │
└─────────┬───────────────────────────────┘
          ▼
   Téléphone débloqué + notification de confirmation
```

> Note : l'accès à l'appel d'urgence reste garanti par Android par-dessus l'écran de
> blocage, à toutes les étapes.
