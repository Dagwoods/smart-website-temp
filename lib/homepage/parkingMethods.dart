import 'package:flutter/material.dart';
//import 'package:mysql1/mysql1.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
String translateName(String name) {
  String result = "";
  switch (name) {
    case "chesapeakeAccessible":
      result = "Chesapeake";
      break;
    case "chesapeakeElectric":
      result = "Chesapeake";
      break;
    case "chesapeakeCommuter":
      result = "Chesapeake";
      break;
    case "ballardAccessible":
      result = "Ballard";
      break;
    case "ballardElectric":
      result = "Ballard";
      break;
    case "ballardFaculty":
      result = "Ballard";
      break;
    case "ballardCommuter":
      result = "Ballard";
      break;
    case "championsAccessible":
      result = "Champions";
      break;
    case "championsElectric":
      result = "Champions";
      break;
    case "championsFaculty":
      result = "Champions";
      break;
    case "championsCommuter":
      result = "Champions";
      break;
    case "warsawAccessible":
      result = "Warsaw";
      break;
    case "warsawElectric":
      result = "Warsaw";
      break;
    case "warsawFaculty":
      result = "Warsaw";
      break;
    case "warsawCommuter":
      result = "Warsaw";
      break;
    case "graceAccessible":
      result = "Grace";
      break;
    case "graceElectric":
      result = "Grace";
      break;
    case "graceFaculty":
      result = "Grace";
      break;
    case "graceCommuter":
      result = "Grace";
      break;
    case "masonAccessible":
      result = "Mason";
      break;
    case "masonElectric":
      result = "Mason";
      break;
    case "masonFaculty":
      result = "Mason";
      break;
    case "chesapeakeFavorite":
      result = "Chesapeake";
      break;
    case "masonFavorite":
      result = "Mason";
      break;
    case "graceFavorite":
      result = "Grace";
      break;
    case "warsawFavorite":
      result = "Warsaw";
      break;
    case "championsFavorite":
      result = "Champions";
      break;
  }
  return result;
}

int translateId(String name) {
  int result = 0;
  switch (name) {
    case "chesapeakeAccessible":
      result = 33;
      break;
    case "chesapeakeElectric":
      result = 34;
      break;
    case "chesapeakeCommuter":
      result = 19;
      break;
    case "ballardAccessible":
      result = 29;
      break;
    case "ballardElectric":
      result = 30;
      break;
    case "ballardFaculty":
      result = 27;
      break;
    case "ballardCommuter":
      result = 22;
      break;
    case "championsAccessible":
      result = 31;
      break;
    case "championsElectric":
      result = 32;
      break;
    case "championsFaculty":
      result = 40;
      break;
    case "championsCommuter":
      result = 13;
      break;
    case "warsawAccessible":
      result = 38;
      break;
    case "warsawElectric":
      result = 39;
      break;
    case "warsawFaculty":
      result = 41;
      break;
    case "warsawCommuter":
      result = 42;
      break;
    case "graceAccessible":
      result = 35;
      break;
    case "graceElectric":
      result = 36;
      break;
    case "graceFaculty":
      result = 6;
      break;
    case "graceCommuter":
      result = 4;
      break;
    case "masonAccessible":
      result = 37;
      break;
    case "masonElectric":
      result = 28;
      break;
    case "masonFaculty":
      result = 12;
      break;
    default:
      debugPrint("Case not included$name");
      break;
  }
  return result;
}

String translateType(int mode) {
  String result = "";
  switch (mode) {
    case 4:
      result = "Accessible";
      break;
    case 3:
      result = "Electric";
      break;
    case 1:
      result = "Commuter";
      break;
    case 2:
      result = "Faculty";
      break;
  }
  return result;
}

Color translateColor(String name) {
  Color result = Colors.black;
  switch (name) {
    case "Faculty":
      result = const Color(0xFF3E64FF);
      break;
    case "Electric":
      result = const Color(0xFFDDAF17);
      break;
    case "Accessible":
      result = const Color(0xFFE52828);
      break;
    case "Commuter":
      result = const Color(0xFFA638EB);
      break;
    case "Favorite":
      result = Colors.black;
  }
  return result;
}

/*Future<Map<int, int>?> fetchAll() async {
  Map<int, int> result = {};

  debugPrint("CHECKPOINT 1: Starting fetchAll()");
  try {
    //Open Connection
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '3.148.7.106',
        port: 3306,
        user: 'appuser',
        db: 'parking_data',
        password: 'Gargamel5'));
    debugPrint("CHECKPOINT 2: MySQL Connection successful!");
    await Future.delayed(const Duration(seconds: 2));

    //Close Connection
    var query = await conn.query(
        'SELECT zone_id, result FROM parking_data ORDER BY id DESC LIMIT 22;');
    conn.close;

    //Parse Data for Value of requested deck
    for (var row in query) {
      if ([
        4,
        6,
        12,
        13,
        19,
        22,
        27,
        28,
        29,
        30,
        31,
        32,
        33,
        34,
        35,
        36,
        37,
        38,
        39,
        40,
        41,
        42
      ].contains(row[0])) {
        result[row[0]] = row[1];
      }
    }
  } on Exception catch (_) {
    debugPrint("load not successful " + result.length.toString());
    await Future.delayed(const Duration(seconds: 10));
    return fetchAll();
  }
  debugPrint("load successful " + result.length.toString());
  return result;
}

Future<String> fetchOne(String deck) async {
  try {
    //Open Connection
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '3.148.7.106',
        port: 3306,
        user: 'appuser',
        db: 'parking_data',
        password: 'Gargamel5'));
    await Future.delayed(Duration(seconds: 2));

    //Close Connection
    var query = await conn.query(
        'SELECT zone_id, result FROM parking_data ORDER BY id DESC LIMIT 22;');
    conn.close;

    //Parse Data for Value of requested deck
    for (var row in query) {
      switch (deck) {
        case "Chesapeake Deck":
          if (row[0] == 19) {
            return row[1].toString();
          }
          break;
        case "chesapeakeAccessible":
          if (row[0] == 33) {
            return row[1].toString();
          }
          break;
        case "chesapeakeElectric":
          if (row[0] == 34) {
            return row[1].toString();
          }
          break;
        case "chesapeakeCommuter":
          if (row[0] == 19) {
            return row[1].toString();
          }
          break;
        case "chesapeakeFavorite":
          if (row[0] == 19) {
            return row[1].toString();
          }
          break;
        case "ballardAccessible":
          if (row[0] == 29) {
            return row[1].toString();
          }
          break;
        case "ballardElectric":
          if (row[0] == 30) {
            return row[1].toString();
          }
          break;
        case "ballardFaculty":
          if (row[0] == 27) {
            return row[1].toString();
          }
          break;
        case "Ballard Deck":
          if (row[0] == 22) {
            return row[1].toString();
          }
        case "ballardCommuter":
          if (row[0] == 22) {
            return row[1].toString();
          }
        case "ballardFavorite":
          if (row[0] == 22) {
            return row[1].toString();
          }
          break;
        case "championsAccessible":
          if (row[0] == 31) {
            return row[1].toString();
          }
          break;
        case "championsElectric":
          if (row[0] == 32) {
            return row[1].toString();
          }
          break;
        case "championsFaculty":
          if (row[0] == 40) {
            return row[1].toString();
          }
          break;
        case "Champions Deck":
          if (row[0] == 13) {
            return row[1].toString();
          }
        case "championsCommuter":
          if (row[0] == 13) {
            return row[1].toString();
          }
        case "championsFavorite":
          if (row[0] == 13) {
            return row[1].toString();
          }
          break;
        case "warsawAccessible":
          if (row[0] == 38) {
            return row[1].toString();
          }
          break;
        case "warsawElectric":
          if (row[0] == 39) {
            return row[1];
          }
          break;
        case "warsawFaculty":
          if (row[0] == 41) {
            return row[1].toString();
          }
          break;
        case "warsawCommuter":
          if (row[0] == 42) {
            return row[1].toString();
          }
        case "Warsaw Deck":
          if (row[0] == 42) {
            return row[1].toString();
          }
        case "warsawFavorite":
          if (row[0] == 42) {
            return row[1].toString();
          }
          break;
        case "graceAccessible":
          if (row[0] == 35) {
            return row[1].toString();
          }
          break;
        case "graceElectric":
          if (row[0] == 36) {
            return row[1].toString();
          }
          break;
        case "graceFaculty":
          if (row[0] == 6) {
            return row[1].toString();
          }
          break;
        case "graceCommuter":
          if (row[0] == 4) {
            return row[1].toString();
          }
        case "Grace Deck":
          if (row[0] == 4) {
            return row[1].toString();
          }
        case "graceFavorite":
          if (row[0] == 4) {
            return row[1].toString();
          }
          break;
        case "masonAccessible":
          if (row[0] == 37) {
            return row[1].toString();
          }
          break;
        case "masonElectric":
          if (row[0] == 28) {
            return row[1].toString();
          }
          break;
        case "masonFaculty":
          if (row[0] == 12) {
            return row[1].toString();
          }
          break;
        case "Mason Deck":
          if (row[0] == 12) {
            return row[1].toString();
          }
          break;
      }
    }
    return "";
  } on Exception catch (_) {
    return fetchOne(deck);
  }
}
*/
Future<Map<int, int>?> fetchAll() async {
  Map<int, int> result = {};
  const String apiUrl = 'http://127.0.0.1:8000/decks'; // The correct, working endpoint

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // The API returns a JSON list of dictionaries [{name: ..., value: ...}]
      final List<dynamic> data = json.decode(response.body);

      // Iterate through the list and map the deck name (from API) to the ID (used by Flutter)
      for (var deckData in data) {
        String zoneName = deckData['name'];
        int value = deckData['value'];
        int zoneId = translateId(zoneName);

        if (zoneId != 0) {
          result[zoneId] = value;
        }
      }
      debugPrint("load successful ${result.length}");
      return result;
    } else {
      debugPrint("API request failed with status: ${response.statusCode}");
      return null;
    }

  } on Exception catch (e) {
    debugPrint("HTTP connection error: $e");
    return null;
  }
}
Future<String> fetchOne(String deck) async {
  // Placeholder to satisfy the search_page.dart call until it is properly updated.
  return "0";
}