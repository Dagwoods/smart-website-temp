from flask import Flask, jsonify, request
from flask_cors import CORS, cross_origin
import ssl

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'
# Parking Decks
decks = [
    #Chesapeake Parking Zones
    #Missing Faculty Zone
    {"name": "chesapeakeAccessible", "value": 0},
    {"name": "chesapeakeElectric", "value": 0},
    {"name": "chesapeakeCommuter", "value": 0},

    #Ballard Parking Zones
    {"name": "ballardAccessible", "value": 0},
    {"name": "ballardElectric", "value": 0},
    {"name": "ballardFaculty", "value": 0},
    {"name": "ballardCommuter", "value": 0},

    #Champions Parking Zones
    {"name": "championsAccessible", "value": 0},
    {"name": "championsElectric", "value": 0},
    {"name": "championsFaculty", "value": 0},
    {"name": "championsCommuter", "value": 0},

    #Warsaw Parking Zones
    {"name": "warsawAccessible", "value": 0},
    {"name": "warsawElectric", "value": 0},
    {"name": "warsawFaculty", "value": 0},
    {"name": "warsawCommuter", "value": 0},

    #Grace Parking Zones
    {"name": "graceAccessible", "value": 0},
    {"name": "graceElectric", "value": 0},
    {"name": "graceFaculty", "value": 0},
    {"name": "graceCommuter", "value": 0},

    #Mason Parking Zones
    #Missing Commuter Zone
    {"name": "masonAccessible", "value": 0},
    {"name": "masonElectric", "value": 0},
    {"name": "masonFaculty", "value": 0}
]

# Get a single parking deck by name
@app.route('/decks/<string:deck_name>', methods=['GET'])
@cross_origin()
def get_deck(deck_name):
    deck = next((u for u in decks if u['name'] == deck_name), None)
    if deck:
        return jsonify(deck)
    return jsonify({"error": "User not found"}), 404

#Get all parking decks
@app.route('/decks', methods=['GET'])
@cross_origin()
def get_decks():
    return jsonify(decks)

# Update a parking deck
@app.route('/decks/<string:deck_name>', methods=['PUT'])
@cross_origin()
def update_deck(deck_name):
    deck = next((u for u in decks if u['name'] == deck_name), None)
    if deck:
        data = request.get_json()
        deck.update(data)
        return jsonify(deck)
    return jsonify({"error": "Deck not found"}), 404


def home():
    return "Welcome to the Flask REST API!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
