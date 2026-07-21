"""Routes de l'API de vérification."""

import logging
import time

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile

from app.core.config import settings
from app.dependencies import get_verifier
from app.schemas import HealthResponse, VerifyResponse
from app.services.verification import (
    InvalidImageError,
    NoValidReferenceError,
    Verifier,
)

logger = logging.getLogger("arise.api")
router = APIRouter()


async def _read_limited(upload: UploadFile) -> bytes:
    """Lit un fichier en refusant le vide et les tailles excessives."""
    data = await upload.read()
    if not data:
        raise HTTPException(400, f"Fichier vide : {upload.filename}")
    if len(data) > settings.max_file_size_bytes:
        raise HTTPException(
            413,
            f"Fichier trop volumineux : {upload.filename} "
            f"(max {settings.max_file_size_mb} Mo).",
        )
    return data


@router.get("/health", response_model=HealthResponse)
async def health(verifier: Verifier = Depends(get_verifier)) -> HealthResponse:
    """Sonde de disponibilité."""
    return HealthResponse(
        status="ok",
        model_loaded=bool(getattr(verifier, "is_ready", False)),
    )


@router.post(
    "/verify",
    response_model=VerifyResponse,
    responses={400: {"description": "Requête invalide"},
               413: {"description": "Fichier trop volumineux"}},
)
async def verify(
    candidate: UploadFile = File(..., description="Photo de validation"),
    references: list[UploadFile] = File(
        ..., description="Photos de référence (1 à N)"
    ),
    threshold: float | None = Form(
        None, description="Seuil cosinus (0..1) surchargeant le défaut"
    ),
    verifier: Verifier = Depends(get_verifier),
) -> VerifyResponse:
    """Vérifie que la photo candidate correspond à l'objet de référence."""
    if not references:
        raise HTTPException(400, "Au moins une photo de référence est requise.")
    if len(references) > settings.max_references:
        raise HTTPException(
            400, f"Trop de références (max {settings.max_references})."
        )
    if threshold is not None and not (0.0 <= threshold <= 1.0):
        raise HTTPException(400, "threshold doit être compris entre 0 et 1.")

    candidate_bytes = await _read_limited(candidate)
    reference_bytes = [await _read_limited(ref) for ref in references]

    started = time.perf_counter()
    try:
        result = verifier.verify(candidate_bytes, reference_bytes, threshold)
    except InvalidImageError:
        raise HTTPException(400, "La photo candidate n'est pas une image valide.")
    except NoValidReferenceError:
        raise HTTPException(400, "Aucune photo de référence exploitable.")
    elapsed_ms = (time.perf_counter() - started) * 1000

    logger.info(
        "verify matched=%s confidence=%.3f refs=%d %.0fms",
        result.matched,
        result.confidence,
        len(reference_bytes),
        elapsed_ms,
    )
    return VerifyResponse(
        matched=result.matched,
        confidence=result.confidence,
        threshold=result.threshold,
        model=result.model,
        reference_scores=result.reference_scores,
    )
