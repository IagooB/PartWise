import sys
import requests

URL = "http://localhost:8000/ingest/document"


def main():
    if len(sys.argv) != 2:
        print("Usage: python scripts/test_ocr.py <path_to_document>")
        sys.exit(1)
    path = sys.argv[1]
    with open(path, "rb") as f:
        files = {"file": (path, f, "application/octet-stream")}
        resp = requests.post(URL, files=files)
    print(f"Status: {resp.status_code}")
    try:
        print(resp.json())
    except Exception as e:
        print("Could not decode JSON:", e)
        print(resp.text)


if __name__ == "__main__":
    main()
