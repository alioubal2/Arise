"""Logique de vérification photo — modèle IA CLIP (self-hosted, gratuit).

Le `Verifier` est une interface injectable : l'implémentation CLIP peut être
remplacée (autre modèle) ou substituée par un faux en test, sans toucher à l'API.
"""

from __future__ import annotations

import io
import threading
from dataclasses import dataclass
from typing import Protocol

import numpy as np
from PIL import Image, UnidentifiedImageError

from app.core.config import settings


class InvalidImageError(ValueError):
    """La photo candidate n'a pas pu être décodée comme une image."""


class NoValidReferenceError(ValueError):
    """Aucune photo de référence exploitable."""


@dataclass
class VerificationOutput:
    matched: bool
    confidence: float
    threshold: float
    model: str
    reference_scores: list[float]


class Verifier(Protocol):
    """Contrat d'un moteur de vérification photo."""

    def verify(
        self,
        candidate: bytes,
        references: list[bytes],
        threshold: float | None = None,
    ) -> VerificationOutput: ...

    def warmup(self) -> None: ...


def _load_image(data: bytes) -> Image.Image:
    try:
        return Image.open(io.BytesIO(data)).convert("RGB")
    except (UnidentifiedImageError, OSError, ValueError) as exc:
        raise InvalidImageError(str(exc)) from exc


class ClipVerifier:
    """Vérification par embeddings CLIP + similarité cosinus."""

    def __init__(self, model_name: str | None = None) -> None:
        self._model_name = model_name or settings.clip_model
        self._model = None
        self._lock = threading.Lock()

    @property
    def model_name(self) -> str:
        return self._model_name

    @property
    def is_ready(self) -> bool:
        return self._model is not None

    def _get_model(self):
        if self._model is None:
            with self._lock:
                if self._model is None:
                    from sentence_transformers import SentenceTransformer

                    self._model = SentenceTransformer(self._model_name)
        return self._model

    def warmup(self) -> None:
        """Charge le modèle en mémoire (téléchargement au 1er appel)."""
        self._get_model()

    def verify(
        self,
        candidate: bytes,
        references: list[bytes],
        threshold: float | None = None,
    ) -> VerificationOutput:
        thr = settings.match_threshold if threshold is None else threshold

        candidate_image = _load_image(candidate)  # peut lever InvalidImageError

        reference_images: list[Image.Image] = []
        for ref in references:
            try:
                reference_images.append(_load_image(ref))
            except InvalidImageError:
                continue  # on ignore une référence illisible
        if not reference_images:
            raise NoValidReferenceError("aucune référence exploitable")

        model = self._get_model()
        # Embeddings normalisés -> produit scalaire = similarité cosinus.
        embeddings = model.encode(
            [candidate_image] + reference_images,
            convert_to_numpy=True,
            normalize_embeddings=True,
        )
        candidate_embedding = embeddings[0]
        reference_embeddings = embeddings[1:]

        similarities = reference_embeddings @ candidate_embedding
        scores = [round(float(s), 4) for s in similarities]
        best = float(np.max(similarities))

        return VerificationOutput(
            matched=bool(best >= thr),
            confidence=round(float(max(0.0, min(1.0, best))), 4),
            threshold=round(float(thr), 4),
            model=self._model_name,
            reference_scores=scores,
        )
