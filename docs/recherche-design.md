# Recherche design & UX — synthèse pour Arise

> Recherche multi-sources vérifiée (28 sources, 122 affirmations extraites, 25 vérifiées
> par vote adversarial 3/3, 0 réfutée). Objectif : nourrir les maquettes et l'UI d'Arise à
> partir de l'analyse d'Alarmy et des bonnes pratiques Android/Material/WCAG.

## 1. Enseignements clés d'Alarmy (données réelles)

Étude évaluée par les pairs (Oh & Shin, *Applied Sciences* 2020) sur **42,9 M
d'enregistrements** de **211 273 utilisateurs** d'Alarmy :

| Type de mission | Part des alarmes | Temps moyen | Snooze/alarme |
|-----------------|------------------|-------------|---------------|
| Bouton simple | 71 % | 14,1 s | faible |
| **Maths** | 15 % | 40,8 s | moyen |
| Secouer | 10 % | 26,6 s | — |
| **Photo** | **4 %** | **40,1 s** | **le + élevé (0,332)** |

**Ce que ça implique pour Arise :**
- La mission **photo est la plus exigeante et la moins choisie** — c'est un choix
  *délibéré* d'utilisateurs motivés, pas un défaut. Notre flux **photo → calcul mental**
  cumule les deux missions les plus longues (~40 s chacune) : il faut **soutenir la
  motivation** pendant cette friction et **minimiser la tentation du snooze**.
- Les tâches **cognitives (maths) sont psychologiquement moins pénibles** que les tâches
  physiques à durée égale, et **meilleures pour la rétention**. → Garder le calcul mental
  comme **porte finale de déblocage** est un bon choix.
- ⚠️ **La difficulté doit être équilibrée** avec la nécessité de se réveiller à l'heure :
  trop de friction = abandon de l'app. Valide notre **mécanisme anti-blocage** (dégradation
  progressive) et l'**ajustement de tolérance selon l'heure**.

## 2. Architecture des écrans (confirmée par la concurrence)

Le pattern d'Alarmy confirme notre découpage ([parcours-utilisateur.md](parcours-utilisateur.md)) :
- **Liste/Accueil** : état actif clairement visible par alarme. *Erreur à éviter* : icônes
  redondantes sans fonction. Rester épuré.
- **Création** : flux simple et rapide ; la sélection de mission + capture de l'objet de
  référence se fait ici.
- **Onboarding** : une courte séquence de 3 écrans expliquant le fonctionnement avant usage
  (pattern Toonie/Alarmy) — utile vu la nature inhabituelle d'Arise.

### Erreur critique de l'écran d'alarme à éviter
Sur l'écran d'alarme, **ne jamais placer deux actions opposées au même endroit / avec le
même aspect** (ex. le bug iPhone snooze/stop). Sous stress et à moitié endormi, l'utilisateur
se trompe. → Chez Arise : **une seule action visible** (bouton unique vers l'appareil photo),
ce qui nous protège déjà de ce piège. À conserver strictement.

## 3. Contraintes techniques Android (à intégrer dès la fondation)

⚠️ Ces règles évoluent avec les versions d'Android — **à revérifier au moment de coder**
selon la version cible et la dernière politique Play.

| Besoin | Permission / mécanisme | Point d'attention |
|--------|------------------------|-------------------|
| Écran d'alarme **par-dessus le verrouillage** | **« Display over other apps »** (SYSTEM_ALERT_WINDOW) | Depuis Android 10, obligatoire pour afficher l'écran de mission au-dessus du lock screen (c'est pourquoi Alarmy la demande). |
| **Alarme exacte** | Déclarer **`USE_EXACT_ALARM`** (permission *normale*, accordée à l'install) | À préférer à `SCHEDULE_EXACT_ALARM` qui, sur Android 13+, est **refusée par défaut**. Une vraie app d'alarme comme Arise y a droit. |
| **Alarme plein écran** | **`USE_FULL_SCREEN_INTENT`** | Sur Android 14+, réservée aux apps alarme/appel. **À déclarer sur la Play Console (page « App content »)** pour un octroi automatique. Vérifier à l'exécution via `NotificationManager.canUseFullScreenIntent()`. Application effective depuis le 22 janv. 2025. |
| Notifications | `POST_NOTIFICATIONS` (Android 13+) | Demande runtime. |

**Onboarding des permissions** : expliquer *pourquoi* chaque permission sensible est
nécessaire **avant** de la demander (meilleur taux d'octroi + conformité Play).

## 4. UI nocturne : couleur, contraste, accessibilité

Le contexte est un usage **la nuit, à moitié réveillé** → confort visuel maximal.

- **Ne pas utiliser de noir pur (`#000000`) comme fond général** : préférer un gris/bleu très
  sombre type **`#121212`** (ou notre `#0B2024`) pour réduire la fatigue oculaire et gérer
  l'élévation (surfaces surélevées légèrement plus claires). → Réserver le noir pur à
  l'**écran d'alarme** uniquement.
- **Désaturer les couleurs vives en mode sombre** : une couleur très saturée « vibre » /
  bave sur fond sombre (halation). → Notre **turquoise `#53BFD1`** devra être **légèrement
  désaturé/assombri** quand il sert de grande surface ou de texte, pour éviter la vibration
  visuelle. Le garder vif seulement pour de petits accents.
- **Contraste WCAG AA** : **≥ 4,5:1** pour le texte normal, **≥ 3:1** pour le grand texte —
  s'applique aussi aux interfaces sombres. À valider pour turquoise/teal sur `#0B2024`.

> ✅ Impact concret sur notre thème : le turquoise convient très bien en **accent**, mais le
> **texte principal** doit rester en blanc cassé (`#F2F6F7`) — jamais en turquoise saturé sur
> fond sombre. Notre `app_colors.dart` suit déjà cette logique (`onDark` clair, accents
> turquoise).

## 5. Sons, haptique et micro-interactions

Bonnes pratiques officielles Android / Material (haptique) :

- **« Less is more »** : pas de vibration/son sur *chaque* interaction — ça engourdit et
  agace. Le silence stratégique met en valeur les moments clés.
- **Intensité proportionnelle à l'importance et inverse à la fréquence** : subtil pour les
  actions fréquentes, plus fort pour les moments importants (succès de mission, déblocage).
- **Co-concevoir visuel + audio + haptique** et les **synchroniser** : une haptique
  désynchronisée paraît « cassée ».
- ⚠️ **Contexte nocturne** : une **vibration longue et soudaine peut faire sursauter** dans
  un environnement calme → doser. (Rappel : notre flux passe en **vibreur continu** entre
  l'étape photo et le calcul mental — à calibrer pour rester « présent » sans agresser.)
- **Fragmentation** : Android **ne fournit pas de fallback** pour les primitives haptiques
  non supportées → tester le support (`areAllPrimitivesSupported`) et désactiver/prévoir un
  repli sur les appareils incompatibles.

## 6. Recommandations actionnables pour Arise

1. **Écran d'alarme** : fond **noir pur**, une **seule** action (appareil photo), horloge
   très lisible, aucune sortie possible sauf urgence. Zéro ambiguïté.
2. **Motivation anti-snooze** : afficher le *pourquoi* du rappel (titre/objectif) sur l'écran
   d'alarme et de mission pour soutenir la motivation pendant la friction photo+maths.
3. **Calcul mental = porte finale** (validé par les données) + **anti-blocage progressif**
   déjà prévu → conserver tel quel.
4. **Thème** : `#0B2024` en fond général (pas de noir pur hors alarme), **turquoise désaturé**
   pour surfaces/texte, turquoise vif réservé aux petits accents, texte blanc cassé, contraste
   AA vérifié.
5. **Permissions** : `USE_EXACT_ALARM` + `USE_FULL_SCREEN_INTENT` (déclaration Play Console) +
   « Display over other apps » + `POST_NOTIFICATIONS`, chacune précédée d'un écran
   d'explication.
6. **Onboarding** court (3 écrans) expliquant le concept inhabituel avant la première alarme.
7. **Haptique/son** sobres, synchronisés, calibrés pour la nuit ; tester le support matériel.

## Limites & questions ouvertes

- Les chiffres quantitatifs proviennent d'une **étude de 2020** sur un Alarmy à 4 missions
  seulement : le « 4 % / photo » vaut pour cette époque, pas forcément l'Alarmy actuel.
- Les règles de permissions Android sont **datées et versionnées** (Android 10/13/14 ;
  application FSI au 22 janv. 2025) → **revérifier à l'implémentation**.
- Aucune source ne couvre directement la validation photo **locale offline** (pHash vs ML
  embarqué) ni notre palette exacte : ces points restent des **extrapolations** à prototyper.

**Questions à trancher plus tard :**
- Approche de reconnaissance photo offline optimale (hash d'image vs modèle ML embarqué) et
  affordances anti-faux-rejet la nuit (re-capture, seuil de confiance, limite d'essais).
- Séquence/défauts optimaux du flux photo→maths et difficulté par défaut.
- Séquence d'onboarding et copy maximisant l'octroi des permissions sensibles.

## Sources principales

- **Primaire** : Oh & Shin, *Applied Sciences* 10(11):3993 (2020) — données Alarmy 42,9 M
- **Primaire (Android)** : developer.android.com — [exact alarms](https://developer.android.com/about/versions/14/changes/schedule-exact-alarms),
  [behavior changes 14](https://developer.android.com/about/versions/14/behavior-changes-14),
  [haptics principles](https://developer.android.com/develop/ui/views/haptics/haptics-principles),
  [custom haptics](https://developer.android.com/develop/ui/views/haptics/custom-haptic-effects)
- **Primaire (Play)** : [Full-screen intent policy](https://support.google.com/googleplay/android-developer/answer/13392821)
- **Primaire (Alarmy)** : [Display over apps permission](https://alarmy-android.zendesk.com/hc/en-us/articles/900000065586)
- Design/UX : Smashing Magazine (dark mode accessible), design.google (sound & haptic),
  critiques UX Alarmy (Medium), Tubik Studio (case study Toonie).
