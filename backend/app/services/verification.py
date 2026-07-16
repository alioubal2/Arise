"""Logique de vérification photo — modèle IA CLIP (self-hosted, gratuit).

La fonction `verify_images` reçoit la photo candidate et les photos de référence
(en bytes) et renvoie (matched: bool, confidence: float in [0, 1]).

Approche : CLIP (via sentence-transformers) transforme chaque image en un vecteur
(embedding). On calcule la similarité cosinus entre la candidate et chaque
référence ; la correspondance est validée si la meilleure similarité dépasse le
seuil configuré. Le modèle est chargé une seule fois (paresseusement), et ses
poids sont téléchargés au premier usage puis mis en cache localement.
"""

from __future__ import annotations

import io
import threading

import numpy as np
from PIL import Image

from app.core.config import settings

_model = None
_model_lock = threading.Lock()


def get_model():
    """Charge le modèle CLIP une seule fois (thread-safe, chargement paresseux)."""
    global _model
    if _model is None:
        with _model_lock:
            if _model is None:
                from sentence_transformers import SentenceTransformer

                _model = SentenceTransformer(settings.clip_model)
    return _model


def _load_image(data: bytes) -> Image.Image:
    return Image.open(io.BytesIO(data)).convert("RGB")


def verify_images(
    candidate: bytes,
    references: list[bytes],
) -> tuple[bool, float]:
    """Compare la photo candidate aux photos de référence via CLIP."""
    if not references:
        return False, 0.0

    candidate_image = _load_image(candidate)
    reference_images: list[Image.Image] = []
    for ref in references:
        try:
            reference_images.append(_load_image(ref))
        except Exception:
            continue
    if not reference_images:
        return False, 0.0

    model = get_model()
    # Embeddings normalisés -> le produit scalaire vaut la similarité cosinus.
    embeddings = model.encode(
        [candidate_image] + reference_images,
        convert_to_numpy=True,
        normalize_embeddings=True,
    )
    candidate_embedding = embeddings[0]
    reference_embeddings = embeddings[1:]

    similarities = reference_embeddings @ candidate_embedding
    best = float(np.max(similarities))

    matched = bool(best >= settings.match_threshold)
    confidence = float(max(0.0, min(1.0, best)))
    return matched, round(confidence, 4)
