import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LicenseResult {
  const LicenseResult({
    required this.ok,
    required this.status,
    this.message,
    this.expiresAt,
  });

  final bool ok;
  final String? status;
  final String? message;
  final DateTime? expiresAt;

  bool get isActive => ok && status == 'active';

  factory LicenseResult.fromJson(Map<String, dynamic> json) {
    final expiry = json['expiresAt'];
    return LicenseResult(
      ok: json['ok'] == true,
      status: json['status'] is String ? json['status'] as String : null,
      message: json['message'] is String ? json['message'] as String : null,
      expiresAt: expiry is String ? DateTime.tryParse(expiry) : null,
    );
  }
}

class LicenseService {
  static const String _baseUrl =
      'https://keyadmin-4byc6bqo.manus.space/api/license/';
  static const String _appVersion = '1.0.0-ios';
  static const String _licenseKeyName = 'license-key';
  static const String _installationIdName = 'installation-id';

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> readSavedKey() => _storage.read(key: _licenseKeyName);

  Future<void> saveKey(String key) =>
      _storage.write(key: _licenseKeyName, value: key);

  Future<void> clearKey() => _storage.delete(key: _licenseKeyName);

  Future<LicenseResult> activate(String key) =>
      _request('activate', key);

  Future<LicenseResult> checkStatus(String key) =>
      _request('status', key);

  Future<LicenseResult> _request(String path, String key) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    try {
      final request = await client
          .postUrl(Uri.parse('$_baseUrl$path'))
          .timeout(const Duration(seconds: 20));
      request.headers.contentType = ContentType.json;
      request.add(
        utf8.encode(
          jsonEncode({
            'key': key,
            'installationId': await _installationId(),
            'appVersion': _appVersion,
          }),
        ),
      );

      final response = await request.close().timeout(
            const Duration(seconds: 20),
          );
      final body = await utf8.decoder.bind(response).join().timeout(
            const Duration(seconds: 20),
          );
      if (response.statusCode < 200 || response.statusCode >= 500) {
        throw HttpException('License server returned ${response.statusCode}');
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid license response');
      }
      return LicenseResult.fromJson(decoded);
    } finally {
      client.close(force: true);
    }
  }

  Future<String> _installationId() async {
    final existing = await _storage.read(key: _installationIdName);
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    final id = '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
    await _storage.write(key: _installationIdName, value: id);
    return id;
  }
}
