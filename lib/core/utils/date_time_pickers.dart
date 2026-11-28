import 'package:flutter/material.dart';

/// Shared future-only date + time picker used for property viewing visits.
class DateTimePickers {
  const DateTimePickers._();

  static Future<DateTime?> futureDateTime(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: firstDate.add(const Duration(hours: 10)),
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null || !context.mounted) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
