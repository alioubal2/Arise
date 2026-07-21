"""Fournisseurs de dépendances FastAPI (injection + substitution en test)."""

from functools import lru_cache

from app.core.config import settings
from app.services.verification import (
    ClipVerifier,
    Dinov2Verifier,
    HybridVerifier,
    Verifier,
)


@lru_cache
def get_verifier() -> Verifier:
    """Instance unique du moteur de vérification, selon la config."""
    if settings.verifier == "clip":
        return ClipVerifier(settings.clip_model)
    if settings.verifier == "dinov2":
        return Dinov2Verifier(settings.dinov2_model)
    return HybridVerifier()  # défaut : hybride DINOv2 + couleur
