# Contraintes générales

- **Confidentialité** : les photos des objets de référence sont des données personnelles
  sensibles ; leur stockage local doit être sécurisé (espace privé de l'application, jamais
  transmis à l'extérieur).
- **Fiabilité** : une alarme qui ne se déclenche pas au moment prévu constitue un **échec
  critique** du produit ; ce point doit être testé de façon approfondie sur différentes
  versions d'Android.
- **Autonomie batterie** : le mécanisme d'alarme en arrière-plan ne doit pas dégrader
  significativement l'autonomie du téléphone.
- **Accès d'urgence** : le système Android garantit toujours l'accès à l'appel d'urgence
  par-dessus l'écran verrouillé de l'application ; ce comportement ne doit ni être contourné
  ni entrer en conflit avec le blocage d'écran d'Arise.
