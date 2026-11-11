
import requests

BASE_URL = "http://localhost"


def test_frontend_available_when_backend_is_down():
    response = requests.get(
        f"{BASE_URL}/",
        timeout=10
    )

    assert response.status_code == 200


def test_api_returns_503_when_backend_is_down():
    response = requests.get(
        f"{BASE_URL}/api/health",
        timeout=10
    )

    assert response.status_code == 503


def test_api_returns_custom_error_message():
    response = requests.get(
        f"{BASE_URL}/api/health",
        timeout=10
    )

    data = response.json()

    assert data["status"] == "DOWN"
    assert data["message"] == (
        "Backend service is temporarily unavailable"
    )
