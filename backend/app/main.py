"""Point d'entrée de l'API de vérification photo d'Arise."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app import __version__
from app.api.routes import router
from app.core.config import settings

app = FastAPI(title=settings.app_name, version=__version__)

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
