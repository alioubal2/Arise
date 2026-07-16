"""Configuration de l'application, chargée depuis l'environnement / .env."""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_prefix="ARISE_")

    # Nom / métadonnées
    app_name: str = "Arise Verification API"

    # Seuil de correspondance (baseline pHash : distance de Hamming max sur 64 bits).
    # Plus la valeur est basse, plus la correspondance est stricte.
    phash_threshold: int = 10

    # Origines autorisées pour le CORS (l'app mobile n'en a pas besoin, mais
    # utile pour tester depuis un navigateur / outil).
    cors_origins: list[str] = ["*"]


settings = Settings()
