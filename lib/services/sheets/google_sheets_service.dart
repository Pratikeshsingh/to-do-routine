import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/routine_block.dart';
import '../../models/task.dart';
import 'sheets_service.dart';

/// Google Sheets REST implementation.
///
/// Requires a Google Cloud OAuth client with Sheets scope and a spreadsheet
/// that the signed-in user can edit. See README for column layout.
///
/// v1 scaffold: [ensureSignedIn] / token helpers throw until OAuth client IDs
/// and `google_sign_in` 7.x `initialize()` + `authenticate()` are wired.
class GoogleSheetsService implements SheetsService {
  GoogleSheetsService({
    required this.spreadsheetId,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  static const sheetsScope = 'https://www.googleapis.com/auth/spreadsheets';

  final String spreadsheetId;
  final http.Client _http;

  /// Call after configuring platform client IDs.
  ///
  /// With `google_sign_in` 7.x:
  /// `await GoogleSignIn.instance.initialize(...);`
  /// then `authenticate()` and request [sheetsScope] via authorizationClient.
  Future<void> ensureSignedIn() async {
    throw UnimplementedError(
      'Wire GoogleSignIn client IDs, initialize(), and authenticate() '
      'before Sheets calls. See README.',
    );
  }

  Future<String> _accessToken() async {
    await ensureSignedIn();
    throw UnimplementedError('Return OAuth access token after sign-in.');
  }

  Uri _valuesUri(String range) => Uri.https(
        'sheets.googleapis.com',
        '/v4/spreadsheets/$spreadsheetId/values/$range',
      );

  Future<List<List<String>>> _readRange(String range) async {
    final token = await _accessToken();
    final response = await _http.get(
      _valuesUri(range),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode >= 400) {
      throw StateError(
        'Sheets read failed: ${response.statusCode} ${response.body}',
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final values = decoded['values'] as List<dynamic>? ?? const [];
    return values
        .map(
          (row) => (row as List<dynamic>).map((c) => '$c').toList(),
        )
        .toList();
  }

  @override
  Future<List<RoutineBlock>> fetchRoutineBlocks() async {
    final rows = await _readRange('RoutineBlocks!A:G');
    if (rows.isEmpty) return const [];
    final headers = rows.first.map((h) => h.trim()).toList();
    return rows.skip(1).map((cells) {
      final map = <String, String>{};
      for (var i = 0; i < headers.length; i++) {
        map[headers[i]] = i < cells.length ? cells[i] : '';
      }
      return RoutineBlock.fromSheetRow(map);
    }).toList();
  }

  @override
  Future<void> upsertRoutineBlock(RoutineBlock block) async {
    // TODO(v1-oauth): append or update by id via values:batchUpdate.
    throw UnimplementedError('Sheets upsert for RoutineBlocks not wired yet.');
  }

  @override
  Future<List<TaskItem>> fetchTasks() async {
    final rows = await _readRange('Tasks!A:E');
    if (rows.isEmpty) return const [];
    final headers = rows.first.map((h) => h.trim()).toList();
    return rows.skip(1).map((cells) {
      final map = <String, String>{};
      for (var i = 0; i < headers.length; i++) {
        map[headers[i]] = i < cells.length ? cells[i] : '';
      }
      return TaskItem.fromSheetRow(map);
    }).toList();
  }

  @override
  Future<void> upsertTask(TaskItem task) async {
    throw UnimplementedError('Sheets upsert for Tasks not wired yet.');
  }

  @override
  Future<void> deleteTask(String id) async {
    throw UnimplementedError('Sheets delete for Tasks not wired yet.');
  }
}
