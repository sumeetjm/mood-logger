import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtil {
  static DateTime getDateOnly(DateTime dateTime) {
    return DateFormat(DateFormat.YEAR_NUM_MONTH_DAY)
        .parse(DateFormat(DateFormat.YEAR_NUM_MONTH_DAY).format(dateTime));
  }

  static bool isSameDate(DateTime dateTime, DateTime otherDateTime) {
    return dateTime.year == otherDateTime.year &&
        dateTime.month == otherDateTime.month &&
        dateTime.day == otherDateTime.day;
  }

  static DateTime combine(DateTime date, TimeOfDay time) => DateTime(
      date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);
}
