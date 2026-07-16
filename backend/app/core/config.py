"""Configuration de l'application, chargée depuis l'environnement / .env."""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_prefix="ARISE_")

    # Nom / métadonnées
    app_name: str = "Arise Verification API"

    # Modèle CLIP (sentence-transformers). Alternatives : "clip-ViT-B-16",
    # "clip-ViT-L-14" (plus précis, plus lourd).
    clip_model: str = "clip-ViT-B-32"

    # Seuil de correspondance : similarité cosinus minimale (0..1) entre
    # l'embedding de la photo candidate et la meilleure photo de référence.
    # Plus haut = plus strict. ~0.80 est un bon point de départ pour "même objet".
    match_threshold: float = 0.80

    # Origines autorisées pour le CORS (l'app mobile n'en a pas besoin, mais
    # utile pour tester depuis un navigateur / outil).
    cors_origins: list[str] = ["*"]


settings = Settings()
