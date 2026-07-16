"""Logique de vérification photo.

⚠️ IMPLÉMENTATION BASELINE (hash perceptuel) — À REMPLACER PAR VOTRE MODÈLE IA.

La fonction `verify_images` reçoit la photo candidate et les photos de référence
(en bytes) et renvoie (matched: bool, confidence: float in [0, 1]).

Pour brancher un modèle IA (ex. embeddings CLIP, un CNN de similarité, etc.) :
  1. Chargez le modèle une seule fois au démarrage (voir `get_model()`).
  2. Calculez un embedding pour la candidate et chaque référence.
  3. Comparez (similarité cosinus) et décidez la correspondance.
Seule cette fonction est à modifier ; l'API et l'app mobile restent inchangées.
"""

from __future__ import annotations

import io

import imagehash
from PIL import Image

from app.core.config import settings


def _phash(data: bytes) -> imagehash.ImageHash:
    image = Image.open(io.BytesIO(data)).convert("RGB")
    return imagehash.phash(image)


def verify_images(
    candidate: bytes,
    references: list[bytes],
) -> tuple[bool, float]:
    """Compare la photo candidate aux photos de référence.

    Baseline : hash perceptuel (pHash) + distance de Hamming. La correspondance
    est validée si au moins une référence est assez proche.
    """
    if not references:
        return False, 0.0

    candidate_hash = _phash(candidate)

    best_distance: int | None = None
    for ref in references:
        try:
            # La soustraction imagehash renvoie un entier numpy -> cast en int.
            distance = int(candidate_hash - _phash(ref))
        except Exception:
            continue
        if best_distance is None or distance < best_distance:
            best_distance = distance

    if best_distance is None:
        return False, 0.0

    matched = bool(best_distance <= settings.phash_threshold)
    confidence = float(max(0.0, 1.0 - best_distance / 64.0))
    return matched, round(confidence, 4)
