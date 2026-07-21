"""Calibration des seuils de vérification sur de VRAIES photos.

Compare des photos du même objet et d'autres objets à des photos de référence,
puis suggère des seuils (structure DINOv2 + couleur) qui les séparent au mieux.

Usage :
    python scripts/calibrate.py \
        --references chemin/vers/references \
        --same       chemin/vers/photos_du_meme_objet \
        --different  chemin/vers/photos_autres_objets

Chaque dossier contient des images (.jpg/.png). Astuce : si vous êtes derrière un
proxy TLS, exportez d'abord :
    export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
"""

from __future__ import annotations

import argparse
import glob
import os
import sys

# Permet de lancer le script depuis backend/ sans installer le package.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.services.verification import (  # noqa: E402
    Dinov2Verifier,
    _color_histogram,
    _histogram_similarity,
    _load_image,
)


def _images(folder: str) -> list[bytes]:
    files: list[bytes] = []
    for pattern in ("*.jpg", "*.jpeg", "*.png", "*.webp"):
        for path in glob.glob(os.path.join(folder, pattern)):
            with open(path, "rb") as handle:
                files.append(handle.read())
    return files


def _best_scores(dino, ref_embs, ref_hists, image_bytes):
    """Meilleure similarité structure et couleur d'une image vs les références."""
    img = _load_image(image_bytes)
    emb = dino._embed([img])[0]
    hist = _color_histogram(img)
    struct = max(float(e @ emb) for e in ref_embs)
    color = max(_histogram_similarity(hist, h) for h in ref_hists)
    return struct, color


def _summary(name: str, values: list[float]) -> None:
    if not values:
        print(f"  {name}: (aucune donnée)")
        return
    print(
        f"  {name}: min={min(values):.3f}  moy={sum(values)/len(values):.3f}  "
        f"max={max(values):.3f}"
    )


def _suggest(same: list[float], different: list[float], label: str) -> None:
    if not same or not different:
        return
    worst_same = min(same)
    best_diff = max(different)
    margin = worst_same - best_diff
    suggestion = (worst_same + best_diff) / 2
    verdict = "SÉPARABLE" if margin > 0 else "CHEVAUCHEMENT (seuil imparfait)"
    print(
        f"  {label}: même(min)={worst_same:.3f}  autre(max)={best_diff:.3f}  "
        f"marge={margin:+.3f}  -> seuil suggéré ≈ {suggestion:.2f}  [{verdict}]"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--references", required=True)
    parser.add_argument("--same", required=True)
    parser.add_argument("--different", required=True)
    args = parser.parse_args()

    dino = Dinov2Verifier()
    ref_bytes = _images(args.references)
    if not ref_bytes:
        sys.exit(f"Aucune image de référence dans {args.references}")

    ref_imgs = [_load_image(b) for b in ref_bytes]
    ref_embs = list(dino._embed(ref_imgs))
    ref_hists = [_color_histogram(i) for i in ref_imgs]

    same_struct, same_color, diff_struct, diff_color = [], [], [], []
    for b in _images(args.same):
        s, c = _best_scores(dino, ref_embs, ref_hists, b)
        same_struct.append(s)
        same_color.append(c)
    for b in _images(args.different):
        s, c = _best_scores(dino, ref_embs, ref_hists, b)
        diff_struct.append(s)
        diff_color.append(c)

    print(f"\nRéférences : {len(ref_bytes)} | même : {len(same_struct)} | "
          f"autre : {len(diff_struct)}")
    print("\n--- Similarité STRUCTURE (DINOv2) ---")
    _summary("même objet ", same_struct)
    _summary("autre objet", diff_struct)
    print("\n--- Similarité COULEUR (histogramme) ---")
    _summary("même objet ", same_color)
    _summary("autre objet", diff_color)
    print("\n--- Seuils suggérés ---")
    _suggest(same_struct, diff_struct, "structure (ARISE_MATCH_THRESHOLD)")
    _suggest(same_color, diff_color, "couleur   (ARISE_COLOR_THRESHOLD)  ")
    print()


if __name__ == "__main__":
    main()
