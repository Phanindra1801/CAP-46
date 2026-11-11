
import requests

BASE_URL = "http://localhost"


def test_backend_recovers_after_restart():
    response = requests.get(
        f"{BASE_URL}/api/health",
        timeout=15
    )

    assert response.status_code == 200

    data = response.json()

    assert data["status"] == "UP"
    assert data["application"] == "CAP-46 Backend"


def test_frontend_remains_accessible_after_recovery():
    response = requests.get(
        f"{BASE_URL}/",
        timeout=10
    )

    assert response.status_code == 200


def test_deployment_events_api_after_recovery():
    response = requests.get(
        f"{BASE_URL}/api/deployment-events",
        timeout=10
    )

    assert response.status_code == 200
