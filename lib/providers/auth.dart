import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// The authentication provider
class Auth with ChangeNotifier {
  /// The locally stored data
  var backendUrl = '';
  var authHeader = {'authorization': ''};
  String username = '';

  /// Checks if the app can connect to a valid  backend
  ///
  /// Takes the [targetBackendUrl] and in case of no error that means
  /// a connection is successful to the valid server.
  Future<int> validateTargetBackend(String targetBackendUrl) async {
    var targetUrl = Uri.parse('$targetBackendUrl/api/access');

    try {
      final response = await http.get(targetUrl);

      backendUrl = targetBackendUrl;

      return response.statusCode;
    } catch (error) {
      rethrow;
    }
  }

  void saveAuthData(String baseUrl, String username, String password){
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    this.username = username;
    authHeader = {'authorization': basicAuth};
    backendUrl = baseUrl;
  }

  /// Signs a user in using basic authentication.
  ///
  /// Takes the [baseUrl] as the target url. Takes [username] and [password]
  /// to generate a header for basic authentication.
  Future<int> signIn(String baseUrl, String username, String password) async {
    var targetUrl = Uri.parse('$baseUrl/api/access');

    try {
      saveAuthData(baseUrl, username, password);

      final response = await http.get(
        targetUrl,
        headers: authHeader,
      );

      this.username = username;
      return response.statusCode;
    } catch (error) {
      rethrow;
    }
  }
}
