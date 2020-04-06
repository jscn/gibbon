from flask import Flask, make_response, request
import json

app = Flask(__name__)


DATA = [
    {
        "_id":"40f5e0c9eb794761af5baa4f46c6529c",
        "created_at":"2019-07-01 14:21:21",
        "send_at":"2019-07-03 14:21:20",
        "from_email":"fake@website.com",
        "to":"real.person@somewhere.nz",
        "subject":"Handy tips"
    },
    {
        "_id": "0fa7ac18e39b474083c96ff806a9112e",
        "created_at": "2019-08-14 13:52:57",
        "send_at": "2019-08-29 13:52:54",
        "from_email":"someone@somewhere.nz",
        "to":"bob@bob.com",
        "subject":"Spam!"
    },
    {
        "_id": "1fa7ac18e39b474083c96ff806a9112e",
        "created_at": "2019-08-14 13:52:57",
        "send_at": "2019-08-29 13:52:54",
        "from_email":"someone@somewhere.nz",
        "to":"bob@bob.com",
        "subject":"Spam! Spam!"
    },
    {
        "_id": "2fa7ac18e39b474083c96ff806a9112e",
        "created_at": "2019-08-14 13:52:57",
        "send_at": "2019-08-29 13:52:54",
        "from_email":"someone@somewhere.nz",
        "to":"bob@bob.com",
        "subject":"Spam! Spam! Spam!"
    },
    {
        "_id": "3fa7ac18e39b474083c96ff806a9112e",
        "created_at": "2019-08-14 13:52:57",
        "send_at": "2019-08-29 13:52:54",
        "from_email":"someone@somewhere.nz",
        "to":"bob@bob.com",
        "subject":"Spam! Spam! Spam! Spam!"
    },
    {
        "_id": "4fa7ac18e39b474083c96ff806a9112e",
        "created_at": "2019-08-14 13:52:57",
        "send_at": "2019-08-29 13:52:54",
        "from_email":"someone@somewhere.nz",
        "to":"bob@bob.com",
        "subject":"Spam! Spam! Spam! Spam! Spam!"
    },
]


def make_json_response(data, response_code):
    """Make a JSON response."""
    response = make_response(json.dumps(data), response_code)
    response.mimetype = "application/json"
    return response


def add_headers(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    response.headers["Access-Control-Allow-Credentials"] = "false"
    return response


@app.route("/api/1.0/messages/list-scheduled.json", methods=["POST", "OPTIONS"])
def list():
    if request.method == "OPTIONS":
        response = make_response("", 200)
    else:
        response = make_json_response(DATA, 200)

    return add_headers(response)


@app.route("/api/1.0/messages/cancel-scheduled.json", methods=["POST", "OPTIONS"])
def cancel():
    global DATA
    if request.method == "OPTIONS":
        response = make_response("", 200)
    else:
        message_id = request.json["id"]
        message = [m for m in DATA if m["_id"] == message_id][0]
        DATA = [m for m in DATA if m["_id"] != message_id]
        response = make_json_response(message, 200)

    return add_headers(response)
