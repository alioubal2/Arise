"""Fixtures de test : client HTTP + faux verifier (sans charger CLIP)."""

import io

import pytest
from fastapi.testclient import TestClient
from PIL import Image

from app.core.config import settings
from app.dependencies import get_verifier
from app.main import app
from app.services.verification import (
    InvalidImageError,
    NoValidReferenceError,
    VerificationOutput,
    _load_image,
)


class FakeVerifier:
    """Verifier déterministe et rapide, sans modèle IA.

    Valide réellement le décodage des images (comme la vraie implémentation),
    mais décide la correspondance par simple égalité d'octets.
    """

    def warmup(self) -> None:
        pass

    @property
    def is_ready(self) -> bool:
        return True

    def verify(self, candidate, references, threshold=None):
        thr = settings.match_threshold if threshold is None else threshold
        _load_image(candidate)  # lève InvalidImageError si non-image

        valid = []
        for ref in references:
            try:
                _load_image(ref)
                valid.append(ref)
            except InvalidImageError:
                continue
        if not valid:
            raise NoValidReferenceError()

        scores = [1.0 if candidate == ref else 0.3 for ref in valid]
        best = max(scores)
        return VerificationOutput(
            matched=best >= thr,
            confidence=best,
            threshold=round(float(thr), 4),
            model="fake",
            reference_scores=scores,
        )


@pytest.fixture(autouse=True)
def _no_warmup():
    settings.warmup_on_startup = False


@pytest.fixture
def client():
    app.dependency_overrides[get_verifier] = lambda: FakeVerifier()
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


def _png(color=(120, 120, 120), size=(64, 64)) -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", size, color).save(buffer, format="PNG")
    return buffer.getvalue()


@pytest.fixture
def img_a() -> bytes:
    return _png((200, 30, 30))


@pytest.fixture
def img_b() -> bytes:
    return _png((30, 30, 200))
