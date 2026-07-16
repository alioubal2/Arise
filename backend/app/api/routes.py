"""Routes de l'API de vérification."""

from fastapi import APIRouter, File, UploadFile

from app.services.verification import verify_images

router = APIRouter()


@router.get("/health")
async def health() -> dict:
    """Sonde de disponibilité."""
    return {"status": "ok"}


@router.post("/verify")
async def verify(
    candidate: UploadFile = File(..., description="Photo de validation"),
    references: list[UploadFile] = File(
        ..., description="Photos de référence du rappel (1 ou plusieurs)"
    ),
) -> dict:
    """Vérifie que la photo candidate correspond à l'objet de référence.

    Réponse : {"matched": bool, "confidence": float in [0, 1]}
    """
    candidate_bytes = await candidate.read()
    reference_bytes = [await ref.read() for ref in references]

    matched, confidence = verify_images(candidate_bytes, reference_bytes)
    return {"matched": matched, "confidence": confidence}
