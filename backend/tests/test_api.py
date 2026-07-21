"""Tests des endpoints /health et /verify (avec un faux verifier)."""

from app.core.config import settings


def test_health_ok(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_root(client):
    response = client.get("/")
    assert response.status_code == 200
    assert "version" in response.json()


def test_verify_match(client, img_a):
    response = client.post(
        "/verify",
        files=[
            ("candidate", ("c.png", img_a, "image/png")),
            ("references", ("r.png", img_a, "image/png")),
        ],
    )
    assert response.status_code == 200
    body = response.json()
    assert body["matched"] is True
    assert body["confidence"] >= settings.match_threshold
    assert len(body["reference_scores"]) == 1


def test_verify_no_match(client, img_a, img_b):
    response = client.post(
        "/verify",
        files=[
            ("candidate", ("c.png", img_b, "image/png")),
            ("references", ("r.png", img_a, "image/png")),
        ],
    )
    assert response.status_code == 200
    assert response.json()["matched"] is False


def test_verify_custom_threshold(client, img_a, img_b):
    # Avec un seuil très bas, même une non-correspondance passe.
    response = client.post(
        "/verify",
        files=[
            ("candidate", ("c.png", img_b, "image/png")),
            ("references", ("r.png", img_a, "image/png")),
        ],
        data={"threshold": "0.1"},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["threshold"] == 0.1
    assert body["matched"] is True


def test_verify_missing_references_returns_422(client, img_a):
    response = client.post(
        "/verify",
        files=[("candidate", ("c.png", img_a, "image/png"))],
    )
    assert response.status_code == 422


def test_verify_too_many_references(client, img_a):
    files = [("candidate", ("c.png", img_a, "image/png"))]
    for i in range(settings.max_references + 1):
        files.append(("references", (f"r{i}.png", img_a, "image/png")))
    response = client.post("/verify", files=files)
    assert response.status_code == 400


def test_verify_invalid_threshold(client, img_a):
    response = client.post(
        "/verify",
        files=[
            ("candidate", ("c.png", img_a, "image/png")),
            ("references", ("r.png", img_a, "image/png")),
        ],
        data={"threshold": "1.5"},
    )
    assert response.status_code == 400


def test_verify_empty_file(client, img_a):
    response = client.post(
        "/verify",
        files=[
            ("candidate", ("c.png", b"", "image/png")),
            ("references", ("r.png", img_a, "image/png")),
        ],
    )
    assert response.status_code == 400


def test_verify_too_large(client, img_a):
    big = b"\x00" * (settings.max_file_size_bytes + 1)
    response = client.post(
        "/verify",
        files=[
            ("candidate", ("c.bin", big, "application/octet-stream")),
            ("references", ("r.png", img_a, "image/png")),
        ],
    )
    assert response.status_code == 413


def test_verify_non_image_candidate(client, img_a):
    response = client.post(
        "/verify",
        files=[
            ("candidate", ("c.txt", b"pas une image", "text/plain")),
            ("references", ("r.png", img_a, "image/png")),
        ],
    )
    assert response.status_code == 400
