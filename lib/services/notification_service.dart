import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/medicamento.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'medication_reminders',
    'Lembretes de medicamentos',
    description: 'Avisos no horário de tomar medicamentos.',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings),
    );

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);
    await android?.requestNotificationsPermission();
  }

  Future<void> scheduleMedication(Medicamento medicamento) async {
    if (medicamento.id == null) return;
    await cancelMedication(medicamento.id!);

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    var canScheduleExactly = await android?.canScheduleExactNotifications() ?? true;
    if (!canScheduleExactly) {
      await android?.requestExactAlarmsPermission();
      canScheduleExactly = await android?.canScheduleExactNotifications() ?? false;
    }

    final time = _parseTime(medicamento.horario);
    for (final weekday in _weekdaysFor(medicamento.diasSemana)) {
      await _notifications.zonedSchedule(
        _notificationId(medicamento.id!, weekday),
        'Hora do medicamento',
        'Está na hora de tomar ${medicamento.nome}.',
        _nextOccurrence(weekday, time.hour, time.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Lembretes de medicamentos',
            channelDescription: 'Avisos no horário de tomar medicamentos.',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: canScheduleExactly
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelMedication(int medicationId) async {
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      await _notifications.cancel(_notificationId(medicationId, weekday));
    }
  }

  int _notificationId(int medicationId, int weekday) => medicationId * 10 + weekday;

  TimeOfDayData _parseTime(String value) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value);
    if (match == null) {
      throw FormatException('Horário inválido: $value');
    }
    return TimeOfDayData(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
    );
  }

  List<int> _weekdaysFor(String days) {
    if (days == 'Todos os dias') {
      return List.generate(7, (index) => index + 1);
    }
    const weekdays = {
      'Segunda': DateTime.monday,
      'Terça': DateTime.tuesday,
      'Quarta': DateTime.wednesday,
      'Quinta': DateTime.thursday,
      'Sexta': DateTime.friday,
      'Sábado': DateTime.saturday,
      'Domingo': DateTime.sunday,
    };
    return days.split(', ').map((day) => weekdays[day]).whereType<int>().toList();
  }

  tz.TZDateTime _nextOccurrence(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

class TimeOfDayData {
  const TimeOfDayData(this.hour, this.minute);

  final int hour;
  final int minute;
}
