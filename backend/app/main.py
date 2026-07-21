"""Point d'entrée de l'API de vérification photo d'Arise."""

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app import __version__
from app.api.routes import router
from app.core.config import settings
from app.dependencies import get_verifier

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
logger = logging.getLogger("arise")


@asynccontextmanager
async def lifespan(app: FastAPI):
    if settings.warmup_on_startup:
        logger.info("Warmup du moteur '%s'…", settings.verifier)
        try:
            get_verifier().warmup()
            logger.info("Modèle chargé, prêt à vérifier.")
        except Exception as exc:  # pragma: no cover - dépend de l'environnement
            logger.warning(
                "Warmup échoué (%s) — chargement différé au 1er /verify", exc
            )
    yield


app = FastAPI(title=settings.app_name, version=__version__, lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)


@app.get("/")
async def root() -> dict:
    return {"app": settings.app_name, "version": __version__, "docs": "/docs"}
