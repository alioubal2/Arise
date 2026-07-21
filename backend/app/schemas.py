"""Schémas d'entrée/sortie de l'API (pydantic)."""

from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: str = "ok"
    model_loaded: bool = False


class VerifyResponse(BaseModel):
    matched: bool = Field(description="La candidate correspond à une référence")
    confidence: float = Field(ge=0, le=1, description="Meilleure similarité (0..1)")
    threshold: float = Field(description="Seuil appliqué pour cette requête")
    model: str = Field(description="Modèle de vérification utilisé")
    reference_scores: list[float] = Field(
        description="Similarité cosinus avec chaque référence exploitable"
    )


class ErrorResponse(BaseModel):
    detail: str
