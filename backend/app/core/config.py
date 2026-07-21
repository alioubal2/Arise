"""Configuration de l'application, chargée depuis l'environnement / .env."""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_prefix="ARISE_")

    # Nom / métadonnées
    app_name: str = "Arise Verification API"

    # Moteur de vérification :
    #   "hybrid" (recommandé) = DINOv2 (forme/texture) + histogramme couleur
    #   "dinov2" = DINOv2 seul
    #   "clip"   = CLIP seul
    verifier: str = "hybrid"

    # Seuil de similarité couleur (histogramme, 0..1) pour le mode hybride.
    color_threshold: float = 0.55

    # Modèle DINOv2 (transformers). Alternatives : "facebook/dinov2-small"
    # (plus léger), "facebook/dinov2-large" (plus précis, plus lourd).
    dinov2_model: str = "facebook/dinov2-base"

    # Modèle CLIP (sentence-transformers), si verifier == "clip".
    clip_model: str = "clip-ViT-B-32"

    # Seuil de correspondance : similarité cosinus minimale (0..1) entre
    # l'embedding de la photo candidate et la meilleure photo de référence.
    # Plus haut = plus strict. ~0.75 convient à DINOv2 (large marge same/diff).
    match_threshold: float = 0.75

    # Taille maximale acceptée par image (Mo).
    max_file_size_mb: float = 8.0

    # Nombre maximal de photos de référence par requête.
    max_references: int = 5

    # Charger le modèle au démarrage (évite la lenteur du 1er /verify).
    warmup_on_startup: bool = True

    # Origines autorisées pour le CORS (l'app mobile n'en a pas besoin, mais
    # utile pour tester depuis un navigateur / outil).
    cors_origins: list[str] = ["*"]

    @property
    def max_file_size_bytes(self) -> int:
        return int(self.max_file_size_mb * 1024 * 1024)


settings = Settings()
