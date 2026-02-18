from flask import Flask, jsonify, request
from flask_cors import CORS, cross_origin
import requests
import ssl
import urllib3

# Disable SSL warnings for self-signed certificates
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

# JMU API endpoint
JMU_API_URL = 'https://www.jmu.edu/cgi-bin/parking_sign_data.cgi?hash=53616c7465645f5f4c03eadd986acf07775e314a27e46ac7b36f35b8887e4e67ea5489a0733beab3e908f947f1a121913b0c1bbaa8d855d0a76820c2ce3b3b4f9c78a1a4638afe82e66c5e27e2c5af01|869835tg89dhkdnbnsv5sg5wg0vmcf4mfcfc2qwm5968unmeh5'

# Parking Decks (fallback/cache)
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

# Proxy endpoint that fetches from JMU API
@app.route('/parking', methods=['GET'])
@cross_origin()
def get_parking():
    try:
        # Fetch from JMU API with SSL verification disabled
        response = requests.get(JMU_API_URL, verify=False, timeout=10)
        response.raise_for_status()
        
        # Return the JSON data directly
        data = response.json()
        return jsonify(data)
    except requests.exceptions.RequestException as e:
        print(f"Error fetching from JMU API: {e}")
        # Fallback to mock data if JMU API fails
        return jsonify(decks)

# Get a single parking deck by name
@app.route('/decks/<string:deck_name>', methods=['GET'])
@cross_origin()
def get_deck(deck_name):
    deck = next((u for u in decks if u['name'] == deck_name), None)
    if deck:
        return jsonify(deck)
    return jsonify({"error": "Deck not found"}), 404

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

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False, ssl_context=('cert.pem', 'key.pem'))
