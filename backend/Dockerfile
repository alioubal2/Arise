# Image de déploiement du backend de vérification Arise.
# Compatible Hugging Face Spaces (Docker) : écoute sur le port 7860, tourne en
# utilisateur non-root, et pré-télécharge le modèle DINOv2 dans l'image (pas de
# téléchargement au démarrage -> cold start rapide).

FROM python:3.12-slim

# Dépendances système minimales pour Pillow / torch.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Utilisateur non-root (requis par Hugging Face Spaces).
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH \
    HF_HOME=/home/user/.cache/huggingface \
    ARISE_WARMUP_ON_STARTUP=true

WORKDIR /app

# torch en version CPU (évite le téléchargement CUDA ~2 Go).
RUN pip install --no-cache-dir --user \
    torch --index-url https://download.pytorch.org/whl/cpu

COPY --chown=user requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

COPY --chown=user app ./app

# Pré-téléchargement du modèle DINOv2 dans le cache de l'image.
RUN python -c "from transformers import AutoImageProcessor, AutoModel; \
AutoImageProcessor.from_pretrained('facebook/dinov2-base'); \
AutoModel.from_pretrained('facebook/dinov2-base')"

EXPOSE 7860
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7860"]
