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


def _color_histogram(image: Image.Image, bins: int = 4, size: int = 64):
    """Histogramme couleur RGB normalisé (bins^3 cases, somme = 1)."""
    small = image.resize((size, size))
    arr = np.asarray(small)  # (size, size, 3)
    idx = np.clip(arr // (256 // bins), 0, bins - 1).astype(np.int64)
    flat = idx[..., 0] * bins * bins + idx[..., 1] * bins + idx[..., 2]
    hist = np.bincount(flat.ravel(), minlength=bins**3).astype(np.float64)
    total = hist.sum()
    return hist / total if total else hist


def _histogram_similarity(a, b) -> float:
    """Intersection d'histogrammes (somme des minimums), dans [0, 1]."""
    return float(np.minimum(a, b).sum())


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


class HybridVerifier:
    """Vérification hybride : DINOv2 (forme/texture) + histogramme couleur.

    Une référence correspond si la similarité **structurelle** (DINOv2) ET la
    similarité **couleur** dépassent leurs seuils. Cela corrige l'angle mort des
    deux modèles seuls : un objet de même forme mais de couleur différente est
    désormais rejeté (couleur faible), et un objet de forme différente aussi
    (structure faible). Le score reporté est le maillon faible min(struct, couleur).
    """

    def __init__(
        self,
        dinov2: "Dinov2Verifier | None" = None,
        color_threshold: float | None = None,
    ) -> None:
        self._dino = dinov2 or Dinov2Verifier(settings.dinov2_model)
        self._color_threshold = (
            settings.color_threshold if color_threshold is None else color_threshold
        )

    @property
    def model_name(self) -> str:
        return f"hybrid({self._dino.model_name}+color)"

    @property
    def is_ready(self) -> bool:
        return self._dino.is_ready

    def warmup(self) -> None:
        self._dino.warmup()

    def verify(
        self,
        candidate: bytes,
        references: list[bytes],
        threshold: float | None = None,
    ) -> VerificationOutput:
        struct_thr = settings.match_threshold if threshold is None else threshold
        color_thr = self._color_threshold

        candidate_image = _load_image(candidate)
        reference_images: list[Image.Image] = []
        for ref in references:
            try:
                reference_images.append(_load_image(ref))
            except InvalidImageError:
                continue
        if not reference_images:
            raise NoValidReferenceError("aucune référence exploitable")

        embeddings = self._dino._embed([candidate_image] + reference_images)
        candidate_embedding = embeddings[0]
        reference_embeddings = embeddings[1:]
        struct_sims = reference_embeddings @ candidate_embedding

        candidate_hist = _color_histogram(candidate_image)

        matched = False
        combined_scores: list[float] = []
        best_confidence = 0.0
        for i, ref_image in enumerate(reference_images):
            struct = float(struct_sims[i])
            color = _histogram_similarity(
                candidate_hist, _color_histogram(ref_image)
            )
            combined = min(struct, color)
            combined_scores.append(round(combined, 4))
            if struct >= struct_thr and color >= color_thr:
                matched = True
            best_confidence = max(best_confidence, combined)

        return VerificationOutput(
            matched=matched,
            confidence=round(float(max(0.0, min(1.0, best_confidence))), 4),
            threshold=round(float(struct_thr), 4),
            model=self.model_name,
            reference_scores=combined_scores,
        )


class Dinov2Verifier:
    """Vérification par embeddings DINOv2 + similarité cosinus.

    DINOv2 (auto-supervisé, images seules) capture des features visuelles fines,
    généralement meilleures que CLIP pour distinguer le *même exemplaire* d'un
    objet similaire mais différent.
    """

    def __init__(self, model_name: str = "facebook/dinov2-base") -> None:
        self._model_name = model_name
        self._model = None
        self._processor = None
        self._lock = threading.Lock()

    @property
    def model_name(self) -> str:
        return self._model_name

    @property
    def is_ready(self) -> bool:
        return self._model is not None

    def _ensure_loaded(self) -> None:
        if self._model is None:
            with self._lock:
                if self._model is None:
                    from transformers import AutoImageProcessor, AutoModel

                    self._processor = AutoImageProcessor.from_pretrained(
                        self._model_name
                    )
                    self._model = AutoModel.from_pretrained(self._model_name)
                    self._model.eval()

    def warmup(self) -> None:
        self._ensure_loaded()

    def _embed(self, images: list[Image.Image]):
        import torch

        self._ensure_loaded()
        inputs = self._processor(images=images, return_tensors="pt")
        with torch.no_grad():
            outputs = self._model(**inputs)
        # Token de classe (CLS) comme embedding global, puis normalisation L2.
        embeddings = outputs.last_hidden_state[:, 0]
        embeddings = embeddings / embeddings.norm(dim=-1, keepdim=True)
        return embeddings.cpu().numpy()

    def verify(
        self,
        candidate: bytes,
        references: list[bytes],
        threshold: float | None = None,
    ) -> VerificationOutput:
        thr = settings.match_threshold if threshold is None else threshold

        candidate_image = _load_image(candidate)
        reference_images: list[Image.Image] = []
        for ref in references:
            try:
                reference_images.append(_load_image(ref))
            except InvalidImageError:
                continue
        if not reference_images:
            raise NoValidReferenceError("aucune référence exploitable")

        embeddings = self._embed([candidate_image] + reference_images)
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
