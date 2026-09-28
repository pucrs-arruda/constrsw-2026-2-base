#!/usr/bin/env python3
# Live smoke flow for the Group 02 OAuth API and its real local Keycloak.
import getpass
import json
import os
import sys
import time
import uuid
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

BASE_URL = os.environ.get("E2E_BASE_URL", "http://localhost:8181").rstrip("/")
USERNAME = os.environ.get("E2E_USERNAME", "admin@pucrs.br")
RESOURCE = "/lessons"


def request(method, path, form=None, token=None):
    headers = {"Accept": "application/json"}
    body = None
    if form is not None:
        boundary = "----ConstrswE2E" + uuid.uuid4().hex
        chunks = []
        for name, value in form.items():
            chunks.append(
                f"--{boundary}\r\n"
                f'Content-Disposition: form-data; name="{name}"\r\n'
                "Content-Type: text/plain; charset=UTF-8\r\n\r\n"
                f"{value}\r\n"
            )
        chunks.append(f"--{boundary}--\r\n")
        body = "".join(chunks).encode("utf-8")
        headers["Content-Type"] = f"multipart/form-data; boundary={boundary}"
    if token:
        headers["Authorization"] = f"Bearer {token}"

    req = Request(f"{BASE_URL}{path}", data=body, headers=headers, method=method)
    try:
        with urlopen(req, timeout=10) as response:
            return response.status, response.read()
    except HTTPError as error:
        return error.code, error.read()


def expect_status(status, expected, step):
    if status != expected:
        raise RuntimeError(f"{step}: expected HTTP {expected}, received HTTP {status}")
    print(f"[PASS] {step}: HTTP {status}")


def token_from(payload, field):
    value = payload.get(field)
    if not isinstance(value, str) or not value.strip():
        raise RuntimeError(f"Response did not contain {field}")
    value = value.strip()
    if value.lower().startswith("bearer "):
        value = value[7:].strip()
    return value


def wait_for_api():
    deadline = time.monotonic() + 120
    while time.monotonic() < deadline:
        try:
            status, _ = request("GET", "/health")
            if status == 200:
                expect_status(status, 200, "OAuth health")
                return
        except (URLError, TimeoutError):
            pass
        time.sleep(2)
    raise RuntimeError(f"OAuth API did not become healthy at {BASE_URL}/health")


def run():
    wait_for_api()
    password = os.environ.get("E2E_PASSWORD")
    if not password:
        if not sys.stdin.isatty():
            raise RuntimeError("Set E2E_PASSWORD to the local test user's password")
        password = getpass.getpass(f"Password for {USERNAME}: ")

    status, body = request("POST", "/login", {"username": USERNAME, "password": password})
    expect_status(status, 201, "Login through OAuth and Keycloak")
    login = json.loads(body)
    refresh_token = token_from(login, "refresh_token")

    status, body = request("POST", "/refresh", {"refresh_token": refresh_token})
    expect_status(status, 200, "Refresh through OAuth and Keycloak")
    refreshed = json.loads(body)
    access_token = token_from(refreshed, "access_token")

    path = "/access?" + urlencode({"resource": RESOURCE})
    status, _ = request("GET", path, token=access_token)
    expect_status(status, 200, f"Keycloak grants access to {RESOURCE}")


if __name__ == "__main__":
    try:
        run()
    except Exception as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        sys.exit(1)
