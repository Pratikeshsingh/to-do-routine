import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/calendar/calendar_service.dart';
import '../services/calendar/fake_calendar_service.dart';
import '../services/sheets/fake_sheets_service.dart';
import '../services/sheets/sheets_service.dart';

/// Swap to [GoogleSheetsService] once OAuth + spreadsheet ID are configured.
final sheetsServiceProvider = Provider<SheetsService>((ref) {
  return FakeSheetsService();
});

/// Swap to a live Calendar client in v2.
final calendarServiceProvider = Provider<CalendarService>((ref) {
  return FakeCalendarService();
});
