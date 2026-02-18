from flask import Flask, jsonify, request
from flask_cors import CORS, cross_origin
import requests
import ssl
import urllib3
import xml.etree.ElementTree as ET

# Disable SSL warnings for self-signed certificates
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

# Reverse zone ID mapping (zone_id -> list of deck names)
def getDecksForZoneId(zone_id):
    zone_to_decks = {
        33: ["chesapeakeAccessible"],
        34: ["chesapeakeElectric"],
        19: ["chesapeakeCommuter"],
        29: ["ballardAccessible"],
        30: ["ballardElectric"],
        27: ["ballardFaculty"],
        22: ["ballardCommuter"],
        31: ["championsAccessible"],
        32: ["championsElectric"],
        40: ["championsFaculty"],
        13: ["championsCommuter"],
        38: ["warsawAccessible"],
        39: ["warsawElectric"],
        41: ["warsawFaculty"],
        42: ["warsawCommuter"],
        35: ["graceAccessible"],
        36: ["graceElectric"],
        6: ["graceFaculty"],
        4: ["graceCommuter"],
        37: ["masonAccessible"],
        28: ["masonElectric"],
        12: ["masonFaculty"],
    }
    return zone_to_decks.get(zone_id, [])

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
        print(f"[DEBUG] Attempting to fetch from JMU API")
        # Fetch from JMU API with SSL verification disabled
        response = requests.get(JMU_API_URL, verify=False, timeout=10)
        print(f"[DEBUG] Response status: {response.status_code}")
        print(f"[DEBUG] Response content length: {len(response.content)}")
        response.raise_for_status()
        
        if response.text.strip():  # Check if response is not empty
            # Parse XML response
            root = ET.fromstring(response.text)
            result_list = []
            zone_dict = {}
            
            # Parse all ZoneVacanSpaces elements
            for zone in root.findall('ZoneVacanSpaces'):
                zone_id_elem = zone.find('ZoneId')
                result_elem = zone.find('Result')
                
                if zone_id_elem is not None and result_elem is not None:
                    try:
                        z_id = int(zone_id_elem.text)
                        result = int(result_elem.text)
                        
                        # Keep the latest result for each zone_id (in case there are duplicates)
                        zone_dict[z_id] = result
                    except (ValueError, TypeError) as e:
                        print(f"[WARNING] Could not parse zone data: {e}")
                        continue
            
            # Convert to the format expected by Flutter
            for zone_id, value in zone_dict.items():
                deck_names = getDecksForZoneId(zone_id)
                for deck_name in deck_names:
                    result_list.append({
                        'name': deck_name,
                        'value': value
                    })
            
            print(f"[DEBUG] Successfully parsed {len(result_list)} parking zones from XML")
            return jsonify(result_list)
        else:
            print(f"[ERROR] Response body is empty!")
            print(f"[FALLBACK] Returning mock data ({len(decks)} zones)")
            return jsonify(decks)
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] Error fetching from JMU API: {type(e).__name__}: {e}")
        # Fallback to mock data if JMU API fails
        print(f"[FALLBACK] Returning mock data ({len(decks)} zones)")
        return jsonify(decks)
    except ET.ParseError as e:
        print(f"[ERROR] XML Parse Error: {e}")
        print(f"[FALLBACK] Returning mock data ({len(decks)} zones)")
        return jsonify(decks)
    except Exception as e:
        print(f"[ERROR] Unexpected error: {type(e).__name__}: {e}")
        import traceback
        traceback.print_exc()
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
