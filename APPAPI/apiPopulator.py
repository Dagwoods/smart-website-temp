import requests
import os
import xml.etree.ElementTree as ET
import mysql.connector
from mysql.connector import Error
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
import time

url = "https://www.jmu.edu/cgi-bin/parking_sign_data.cgi?hash=53616c7465645f5f4c03eadd986acf07775e314a27e46ac7b36f35b8887e4e67ea5489a0733beab3e908f947f1a121913b0c1bbaa8d855d0a76820c2ce3b3b4f9c78a1a4638afe82e66c5e27e2c5af01|869835tg89dhkdnbnsv5sg5wg0vmcf4mfcfc2qwm5968unmeh5"
# warsaw has been changed from 3 to 42
desired_zone_ids = ['22', '13', '19', '4', '42', '27', '40', '12', '6', '41', '30', '32', '34', '36', '28', '39', '29', '31', '33', '35', '37', '38']
zones = {
    '29': 'Ballard Accessible', 
    '31': 'Champions Accessible', 
    '33': 'Chesapeake Accessible', 
    '35': 'Grace Accessible', 
    '37': 'Mason Accessible', 
    '38': 'Warsaw Accessible',
    '22': 'Ballard Commuter', 
    '13': 'Champions Commuter', 
    '19': 'Chesapeake Commuter', 
    '4': 'Grace Commuter', 
    '42': 'Warsaw Commuter',
    '30': 'Ballard Electric', 
    '32': 'Champions Electric', 
    '34': 'Chesapeake Electric', 
    '36': 'Grace Electric', 
    '28': 'Mason Electric', 
    '39': 'Warsaw Electric',
    '27': 'Ballard Faulty', 
    '40': 'Champions Faculty', 
    '6': 'Grace Faculty', 
    '12': 'Mason Faculty', 
    '41': 'Warsaw Faculty'
}

api_zone_ids = ['22', '13', '19', '4', '42', '27', '40', '12', '6', '41', '30', '32', '34', '36', '28', '39', '29', '31', '33', '35', '37', '38']
api_zones = {
        '33': 'chesapeakeAccessible',
        '34': 'chesapeakeElectric',
        '19': 'chesapeakeCommuter',
        '29': 'ballardAccessible',
        '30': 'ballardElectric',
        '27': 'ballardFaculty',
        '22': 'ballardCommuter',
        '31': 'championsAccessible',
        '13': 'championsCommuter',
        '40': 'championsFaculty',
        '32': 'championsElectric',
        '38': 'warsawAccessible',
        '39': 'warsawElectric',
        '41': 'warsawFaculty',
        '42': 'warsawCommuter',
        '35': 'graceAccessible',
        '36': 'graceElectric',
        '6': 'graceFaculty',
        '4': 'graceCommuter',
        '37': 'masonAccessible',
        '28': 'masonElectric',
        '12': 'masonFaculty',
}

def sendDataToAPI(zone, value):
    if zone in api_zone_ids:
        # Use localhost for internal updates so the populator can reach
        # the Flask server when running on the same machine (avoids
        # router/NAT hairpinning issues). External clients should use
        # the public IP (configured in the Flutter web build).
        api = 'http://127.0.0.1:8000/decks/' + api_zones[zone]
        headers = {'Content-Type': 'application/json'}
        payload = {'value': value}
        r = requests.put(api,json=payload)


while True:
    zone_data = {}  

    try:
        response = requests.get(url)
        print(f"JMU API Status: {response.status_code}")
        if response.status_code == 200:
            # print(response.text)

            # Parse the XML data
            root = ET.fromstring(response.text)

            for zone_vacancy in root.findall('./ZoneVacanSpaces'):
                zone_id = zone_vacancy.find('ZoneId').text

                # Check if the ZoneId is one of the desired values and not already in the dictionary
                if zone_id in desired_zone_ids and zone_id not in zone_data:
                    zone_id_int = int(zone_id)
                    as_of = zone_vacancy.find('AsOf').text
                    result = int(zone_vacancy.find('Result').text)
                        

                    # Add the data to the dictionary
                    zone_data[zone_id] = (zone_id_int, as_of, result)
                    sendDataToAPI(zone_id, result)


        else:
            print(f"Failed to fetch data. Status code: {response.status_code}")

    except requests.exceptions.RequestException as req_error:
        print(f"HTTP request error: {req_error}")

    except ET.ParseError as parse_error:
        print(f"XML parsing error: {parse_error}")


time.sleep(60)
