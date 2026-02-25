import 'package:flutter/material.dart';

class AppBarDateTimeCenter extends StatelessWidget {
  const AppBarDateTimeCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Center(
          child: StreamBuilder<DateTime>(
            stream: Stream<DateTime>.periodic(
              const Duration(seconds: 1),
              (_) => DateTime.now(),
            ),
            initialData: DateTime.now(),
            builder: (context, snapshot) {
              final now = snapshot.data ?? DateTime.now();
              const weekdays = [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun',
              ];
              const months = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec',
              ];
              final hour12 = now.hour == 0 || now.hour == 12 ? 12 : now.hour % 12;
              final amPm = now.hour < 12 ? 'AM' : 'PM';
              final label =
                  '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}  |  $hour12:${now.minute.toString().padLeft(2, '0')} $amPm';

              return Text(
                label,
                style: const TextStyle(
                  color: Color.fromRGBO(235, 235, 240, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
        ),
      ),
    );
  }
}
