import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const _usernameKey = 'username';
  static const _passwordKey = 'password';
  static const _targetUrlKey = 'target_url';

  static const _storage = FlutterSecureStorage();

  static Future storeUsername(String username) async =>
      await _storage.write(key: _usernameKey, value: username);

  static Future<String?> readUsername() async =>
      await _storage.read(key: _usernameKey);

  static Future storePassword(String password) async =>
      await _storage.write(key: _passwordKey, value: password);

  static Future<String?> readPassword() async =>
      await _storage.read(key: _passwordKey);

  static Future storeTargetUrl(String targetUrl) async =>
      await _storage.write(key: _targetUrlKey, value: targetUrl);

  static Future<String?> readTargetUrl() async =>
      await _storage.read(key: _targetUrlKey);

  static void deleteCredentials() async {
    _storage.delete(key: _usernameKey);
    _storage.delete(key: _passwordKey);
  }
}
