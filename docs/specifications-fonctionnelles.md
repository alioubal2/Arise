# Spécifications fonctionnelles

## 1. Fonctionnalités — version 1 (MVP)

### Gestion des rappels

- Création d'un rappel : **titre, heure, récurrence** (une fois / quotidien / jours
  spécifiques de la semaine)
- Association d'un ou plusieurs **objets de référence** : photo(s) prise(s) et
  enregistrée(s) par l'utilisateur au moment de la création (voir calibration ci-dessous)
- Plusieurs rappels **actifs simultanément et indépendants** (ex. prière + sport + médicament)
- Modification et suppression d'un rappel existant

### Déclenchement de l'alarme

- Sonnerie en **plein écran** au moment prévu, y compris téléphone verrouillé
- **Blocage de l'interface** : aucune autre action possible tant que le rappel n'est pas validé
- Seule action disponible : accès à l'appareil photo pour la validation
- Une fois la photo validée (étape 1), la sonnerie s'arrête et le téléphone passe en mode
  **vibreur continu** jusqu'à la réussite du calcul mental (étape 2)

### Validation par photo (étape 1 — coupe la sonnerie)

- Prise de la photo de l'objet demandé directement depuis l'écran d'alarme
- **Comparaison automatique, entièrement locale** sur l'appareil, avec la/les photo(s) de
  référence (voir [architecture-technique.md](architecture-technique.md))
- **Calibration renforcée** à la création : 2 à 3 photos de l'objet sous des angles /
  luminosités légèrement différents, pour une référence plus robuste et moins de faux rejets
- **Tolérance ajustée automatiquement selon l'heure** : plus large pour les rappels
  programmés tôt le matin ou tard le soir (faible luminosité anticipée)
- Si la photo correspond : sonnerie coupée, passage à l'étape 2. Sinon : la sonnerie
  continue et l'utilisateur doit réessayer.
- **Mécanisme anti-blocage** : après **5 échecs consécutifs** de validation photo (objet
  introuvable, cassé, perdu), l'étape photo est automatiquement sautée et l'app passe
  directement à l'étape 2 ; en compensation, le calcul mental démarre **au-dessus** du
  niveau configuré par défaut.

### Validation par calcul mental (étape 2 — débloque le téléphone)

- Déclenchée uniquement après réussite de l'étape photo : le son est coupé mais le
  téléphone reste verrouillé / inaccessible
- Une opération mathématique est affichée ; il faut fournir la bonne réponse pour
  retrouver l'accès normal au téléphone
- **Niveau de difficulté réglable** par l'utilisateur, par rappel (voir tableau)
- **Limite de temps par opération toujours active** (non désactivable) : au-delà du délai,
  l'opération est considérée comme échouée et une nouvelle est proposée
- Réponse incorrecte ou temps dépassé → nouvelle opération ; le téléphone reste bloqué
  jusqu'à l'obtention du nombre de bonnes réponses **consécutives** requis

#### Niveaux de difficulté

| Niveau | Type d'opération | Plage de nombres | Bonnes réponses consécutives | Temps limite / opération |
|--------|------------------|------------------|------------------------------|--------------------------|
| Facile | Addition / soustraction simple | 1 à 20 | 1 | 10 s |
| Moyen | Addition / soustraction, tables de multiplication | 1 à 100 (add/sous), 1 à 10 (mult) | 2 | 15 s |
| Difficile | Multiplication / division à deux chiffres | 10 à 99 | 3 | 20 s |
| Très difficile | Opérations combinées (2 étapes) | Valeurs mixtes | 4 | 30 s |

Le temps augmente avec la difficulté mais reste volontairement resserré : l'objectif n'est
pas de laisser le temps de se rendormir entre deux tentatives, mais d'empêcher une réponse
tapée au hasard sans réflexion.

#### Anti-blocage : dégradation progressive de la difficulté

Pour garantir qu'aucun utilisateur ne reste bloqué indéfiniment, la difficulté diminue
automatiquement après plusieurs échecs consécutifs, **sans jamais donner un accès gratuit** :

| Échecs consécutifs | Comportement |
|--------------------|--------------|
| 1 à 2 | Nouvelle opération, même niveau de difficulté |
| 3 | Le niveau descend d'un palier |
| 6 | Nouvelle descente d'un palier supplémentaire |
| 9 | Passage au niveau Facile |
| 12 | Palier plancher de sécurité : opération à un chiffre (ex. 2 + 1) |

- Le niveau **ne remonte jamais** automatiquement pendant la même session de blocage ; il
  redevient normal uniquement au prochain rappel.
- Contrainte système (non développable, propre à Android) : l'accès à **l'appel d'urgence**
  reste toujours disponible par-dessus l'écran verrouillé de l'application.

### Sons d'alarme

- Une **bibliothèque de sons par défaut** est fournie (du plus doux au plus insistant),
  sélectionnable à la création d'un rappel
- L'utilisateur peut **importer son propre fichier audio** depuis sa bibliothèque musicale
- L'enregistrement d'un message vocal directement dans l'app **n'est pas retenu pour la v1** ;
  l'import d'un fichier audio existant couvre ce besoin sans complexité micro additionnelle

### Notifications locales

- Notification de préparation avant l'heure du rappel (ex. 10 min avant)
- Confirmation après la réussite complète des deux étapes de validation
- Alerte en cas d'échecs répétés sur un rappel
- **Entièrement locales** (aucune dépendance serveur ou internet) ; complément à l'alarme,
  pas un remplacement

## 2. Fonctionnalités — versions futures (hors périmètre v1)

- Reconnaissance d'image plus avancée (IA) pour une tolérance supérieure aux variations
  d'angle et de luminosité — nécessiterait un service en ligne (rupture avec le 100% offline v1)
- Statistiques de suivi (série de réussites, taux de complétion, temps moyen de résolution)
- Rappels partagés à but de motivation collective (famille, amis) — nécessiterait un serveur
- Enregistrement d'un message vocal personnel directement dans l'app
- Mode d'escalade progressive du volume
- Support iOS (sous réserve des limitations Apple, voir contraintes)

### Stockage des photos

- Toutes les photos restent **exclusivement sur l'appareil**, dans l'espace de stockage
  privé de l'app (inaccessible aux autres apps, supprimé à la désinstallation)
- Photo(s) de référence : conservée(s) tant que le rappel associé existe ; modifiables à
  tout moment depuis les réglages du rappel
- Photo de validation prise à chaque alarme : traitée en mémoire pour la comparaison puis
  **supprimée immédiatement**, jamais conservée

## 3. Cas particuliers à traiter

- **Changement volontaire de l'objet de référence hors alarme** : couvert par l'écran
  « Réglages du rappel », accessible à tout moment en dehors d'une alarme active
- **Objet introuvable pendant une alarme active** : couvert par l'anti-blocage (bascule
  automatique vers le calcul mental après 5 échecs photo)
- **Conditions de luminosité variables (jour/nuit)** : la tolérance de comparaison en tient
  compte via l'ajustement automatique selon l'heure
