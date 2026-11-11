
import requests

BASE_URL = "http://localhost"


def test_nginx_frontend():
    response = requests.get(
        f"{BASE_URL}/",
        timeout=10
    )

    assert response.status_code == 200
    assert "text/html" in response.headers["Content-Type"]


def test_nginx_configuration_header():
    response = requests.get(
        f"{BASE_URL}/",
        timeout=10
    )

    assert response.headers.get("X-CAP46-Config") == "candidate-v1"


def test_spring_boot_backend_health():
    response = requests.get(
        f"{BASE_URL}/api/health",
        timeout=10
    )

    assert response.status_code == 200

    data = response.json()

    assert data["status"] == "UP"
    assert data["application"] == "CAP-46 Backend"


def test_deployment_events_api():
    response = requests.get(
        f"{BASE_URL}/api/deployment-events",
        timeout=10
    )

    assert response.status_code == 200
