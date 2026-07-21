"""Fournisseurs de dépendances FastAPI (injection + substitution en test)."""

from functools import lru_cache

from app.services.verification import ClipVerifier, Verifier


@lru_cache
def get_verifier() -> Verifier:
    """Instance unique du moteur de vérification (CLIP)."""
    return ClipVerifier()
