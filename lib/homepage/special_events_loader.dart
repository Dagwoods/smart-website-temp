import 'package:flutter/services.dart';

Future<List<Map<String, String>>> loadSpecialEventsForToday() async {
  final today = DateTime.now();
  final todayStr = "${today.month}/${today.day}/${today.year}";
  final todayStrZero = "${today.month.toString().padLeft(2, '0')}/${today.day.toString().padLeft(2, '0')}/${today.year}";
  final csvString = await rootBundle.loadString('assets/events/special_events2.csv');
  final lines = csvString.split(RegExp(r'\r?\n'));
  if (lines.isEmpty) return [];
  final headers = lines.first.split(',').map((e) => e.trim()).toList();
  final dateIdx = headers.indexOf('Event DateTime');
  final titleIdx = headers.indexOf('Title');
  if (dateIdx == -1 || titleIdx == -1) return [];
  final events = <Map<String, String>>[];
  for (var i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    final row = line.split(',').map((e) => e.trim()).toList();
    if (row.length <= dateIdx) continue;
    final dateTimeRaw = row[dateIdx];
    if (dateTimeRaw.isEmpty) continue;
    final dateParts = dateTimeRaw.split(' ');
    final dateStr = dateParts[0];
    final timeStr = dateParts.length > 1 ? dateParts[1] + (dateParts.length > 2 ? ' ${dateParts[2]}' : '') : '';
    if (dateStr == todayStr || dateStr == todayStrZero) {
      events.add({
        'title': row[titleIdx],
        'time': timeStr.trim(),
      });
    }
  }
  return events;
}
