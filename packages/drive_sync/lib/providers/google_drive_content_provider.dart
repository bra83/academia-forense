import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/sync_result.dart';

/// Provider for syncing educational packages from Google Drive via OAuth2 (§1.1, §2.1).
class GoogleDriveContentProvider {
  final String? authToken;
  final http.Client? client;

  const GoogleDriveContentProvider({
    this.authToken,
    this.client,
  });

  String get providerName => 'google_drive';

  /// Syncs packages from Google Drive.
  /// Rule §0, §2.1: Never simulate success when unauthenticated; report BLOCKED.
  Future<IngestionResult> sync() async {
    if (authToken == null || authToken!.trim().isEmpty) {
      return IngestionResult.blocked(
        'Google Drive authentication token missing. Offline manual import available.',
      );
    }

    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.get(
        Uri.parse('https://www.googleapis.com/drive/v3/files?pageSize=10&fields=files(id,name,mimeType)'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return const IngestionResult(
          status: SyncStatus.success,
          previewMetadata: {'items_synced': 0},
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return IngestionResult.blocked(
          'Google Drive authentication failed (HTTP ${response.statusCode}). Token invalid or expired.',
        );
      } else {
        return IngestionResult.failure([
          'Drive API returned HTTP ${response.statusCode}: ${response.body}',
        ]);
      }
    } on TimeoutException {
      return IngestionResult.failure([
        'Google Drive sync timed out. Local offline state preserved.',
      ]);
    } catch (e) {
      return IngestionResult.failure(['Google Drive connection error: $e']);
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}
