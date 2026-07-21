# Arise — Backend de vérification photo (FastAPI)

API qui vérifie qu'une photo de validation correspond à l'objet de référence
d'un rappel. L'app mobile Arise envoie les images ; le backend renvoie une
décision de correspondance.

> La vérification par défaut est **hybride** : **DINOv2** (forme/texture) +
> **histogramme couleur**. DINOv2 discrimine bien la structure mais est aveugle
> à la couleur ; l'histogramme couvre cet angle mort. Un objet est validé
> seulement si la structure ET la couleur correspondent. DINOv2 seul et CLIP
> restent disponibles en option. **Les seuils doivent être calibrés sur de
> vraies photos** (voir `scripts/calibrate.py`).

## Structure

```
backend/
├── app/
│   ├── main.py            # app FastAPI + CORS
│   ├── api/routes.py      # routes /health et /verify
│   ├── core/config.py     # configuration (.env)
│   └── services/
│       └── verification.py # ⬅️ LOGIQUE À REMPLACER PAR L'IA
├── requirements.txt
├── .env.example
└── README.md
```

## Démarrage

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env            # optionnel

# Lancer le serveur (accessible sur le réseau local)
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

- Documentation interactive : http://localhost:8000/docs
- Sonde : http://localhost:8000/health

## Contrat de l'API

### `POST /verify`  (multipart/form-data)

| Champ | Type | Requis | Description |
|-------|------|--------|-------------|
| `candidate` | fichier | oui | Photo de validation prise pendant l'alarme |
| `references` | fichier(s) | oui | 1 à `max_references` photos de référence |
| `threshold` | float (0..1) | non | Seuil cosinus surchargeant le défaut pour cette requête |

**Réponse `200`** :
```json
{
  "matched": true,
  "confidence": 0.93,
  "threshold": 0.80,
  "model": "clip-ViT-B-32",
  "reference_scores": [0.93, 0.88]
}
```

**Erreurs** :
| Code | Cas |
|------|-----|
| `400` | Aucune/trop de références, `threshold` hors [0,1], fichier vide, candidate non-image, aucune référence exploitable |
| `413` | Fichier plus grand que `max_file_size_mb` |
| `422` | Champ requis manquant |

### `GET /health`
```json
{ "status": "ok", "model_loaded": true }
```

## Configuration (`.env` ou variables d'env., préfixe `ARISE_`)

| Clé | Défaut | Rôle |
|-----|--------|------|
| `ARISE_VERIFIER` | `hybrid` | Moteur : `hybrid`, `dinov2` ou `clip` |
| `ARISE_DINOV2_MODEL` | `facebook/dinov2-base` | Modèle DINOv2 |
| `ARISE_CLIP_MODEL` | `clip-ViT-B-32` | Modèle CLIP (si `verifier=clip`) |
| `ARISE_MATCH_THRESHOLD` | `0.75` | Seuil structure (cosinus) — ~0.75 DINOv2, ~0.90 CLIP |
| `ARISE_COLOR_THRESHOLD` | `0.55` | Seuil histogramme couleur (mode hybride) |
| `ARISE_MAX_FILE_SIZE_MB` | `8` | Taille max par image |
| `ARISE_MAX_REFERENCES` | `5` | Nombre max de références |
| `ARISE_WARMUP_ON_STARTUP` | `true` | Charger le modèle au démarrage |

## Calibrer les seuils sur de vraies photos

Les seuils par défaut viennent de tests synthétiques (pessimistes). Sur de vraies
photos, mesurez et ajustez avec :

```bash
python scripts/calibrate.py \
  --references photos/reference \
  --same       photos/meme_objet \
  --different  photos/autres_objets
```

Le script affiche les distributions de similarité (structure + couleur) et
**suggère les seuils** `ARISE_MATCH_THRESHOLD` et `ARISE_COLOR_THRESHOLD`.

## Tests

```bash
pip install -r requirements-dev.txt
pytest            # rapide : utilise un faux verifier, ne charge pas les modèles
```

## Brancher votre modèle IA

Tout se passe dans [`app/services/verification.py`](app/services/verification.py),
fonction `verify_images(candidate: bytes, references: list[bytes]) -> (bool, float)`.

Étapes typiques :
1. Charger le modèle **une seule fois** au démarrage (embeddings CLIP, CNN de
   similarité, etc.).
2. Calculer un embedding pour la candidate et chaque référence.
3. Comparer (similarité cosinus) et décider la correspondance + la confiance.

L'API et l'app mobile n'ont pas besoin de changer.

## Connexion depuis l'app mobile

L'app lit l'URL du backend via `--dart-define` (défaut : `http://10.0.2.2:8000`,
soit la machine hôte vue depuis l'émulateur Android) :

```bash
# Émulateur (défaut, rien à faire)
flutter run

# Téléphone physique : mettre l'IP LAN de la machine qui héberge le backend
flutter run --dart-define=ARISE_BACKEND_URL=http://192.168.1.20:8000
```
