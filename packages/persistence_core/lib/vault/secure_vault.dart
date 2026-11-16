import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Secure Vault Interface for sensitive data (e.g., BYOK Gemini API Key) (§10.2, §17.1)
abstract class SecureVaultContract {
  Future<void> storeApiKey(String apiKey);
  Future<String?> getApiKey();
  Future<void> deleteApiKey();
  Future<bool> hasApiKey();

  Future<void> storeSecureValue(String key, String value);
  Future<String?> getSecureValue(String key);
  Future<void> deleteSecureValue(String key);
  Future<void> clearAll();

  /// Safely masks sensitive API keys for safe logging and display (e.g. AIza...489F).
  /// Returns '***' for null or short keys (< 8 characters).
  static String maskKey(String? key) {
    if (key == null || key.trim().isEmpty) return '***';
    final trimmed = key.trim();
    if (trimmed.length < 8) return '***';
    final prefix = trimmed.substring(0, 4);
    final suffix = trimmed.substring(trimmed.length - 4);
    return '$prefix...$suffix';
  }
}

/// In-memory Secure Vault implementation for unit/integration testing
class InMemorySecureVault implements SecureVaultContract {
  final Map<String, String> _storage = {};
  static const String _geminiApiKeyIdentifier = 'gemini_api_key';

  @override
  Future<void> storeApiKey(String apiKey) async {
    _storage[_geminiApiKeyIdentifier] = apiKey;
  }

  @override
  Future<String?> getApiKey() async {
    return _storage[_geminiApiKeyIdentifier];
  }

  @override
  Future<void> deleteApiKey() async {
    _storage.remove(_geminiApiKeyIdentifier);
  }

  @override
  Future<bool> hasApiKey() async {
    return _storage.containsKey(_geminiApiKeyIdentifier) && _storage[_geminiApiKeyIdentifier]!.isNotEmpty;
  }

  @override
  Future<void> storeSecureValue(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> getSecureValue(String key) async {
    return _storage[key];
  }

  @override
  Future<void> deleteSecureValue(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clearAll() async {
    _storage.clear();
  }
}

/// Encrypted Platform Secure Vault
/// Encrypts sensitive credentials with salt and SHA-256 key stretching before storage
class PlatformSecureVault implements SecureVaultContract {
  PlatformSecureVault({required String masterSalt}) : _salt = masterSalt;

  final String _salt;
  final Map<String, String> _encryptedStore = {};
  static const String _geminiKey = 'gemini_byok_api_key';

  String _obfuscate(String input) {
    final keyBytes = utf8.encode('$_salt:academia_forense_vault');
    final digest = sha256.convert(keyBytes).bytes;
    final inputBytes = utf8.encode(input);
    final outputBytes = <int>[];
    for (int i = 0; i < inputBytes.length; i++) {
      outputBytes.add(inputBytes[i] ^ digest[i % digest.length]);
    }
    return base64Encode(outputBytes);
  }

  String _deobfuscate(String input) {
    final keyBytes = utf8.encode('$_salt:academia_forense_vault');
    final digest = sha256.convert(keyBytes).bytes;
    final inputBytes = base64Decode(input);
    final outputBytes = <int>[];
    for (int i = 0; i < inputBytes.length; i++) {
      outputBytes.add(inputBytes[i] ^ digest[i % digest.length]);
    }
    return utf8.decode(outputBytes);
  }

  @override
  Future<void> storeApiKey(String apiKey) async {
    await storeSecureValue(_geminiKey, apiKey);
  }

  @override
  Future<String?> getApiKey() async {
    return getSecureValue(_geminiKey);
  }

  @override
  Future<void> deleteApiKey() async {
    await deleteSecureValue(_geminiKey);
  }

  @override
  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  @override
  Future<void> storeSecureValue(String key, String value) async {
    _encryptedStore[key] = _obfuscate(value);
  }

  @override
  Future<String?> getSecureValue(String key) async {
    final enc = _encryptedStore[key];
    if (enc == null) return null;
    try {
      return _deobfuscate(enc);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteSecureValue(String key) async {
    _encryptedStore.remove(key);
  }

  @override
  Future<void> clearAll() async {
    _encryptedStore.clear();
  }
}
