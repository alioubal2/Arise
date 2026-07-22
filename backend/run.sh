#!/usr/bin/env bash
# Lance le backend Arise en local (modèle chargé depuis le cache, sans réseau).
# Usage : ./run.sh            (port 8001 par défaut)
#         ./run.sh --port 8000
set -e
cd "$(dirname "$0")"

# Le modèle est déjà en cache -> pas besoin du réseau ni du bundle CA.
export HF_HUB_OFFLINE=1
export TRANSFORMERS_OFFLINE=1
# Filet de sécurité si un accès réseau était malgré tout tenté.
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

PORT=8001
[ "$1" = "--port" ] && PORT="$2"

exec .venv/bin/uvicorn app.main:app --host 0.0.0.0 --port "$PORT"
