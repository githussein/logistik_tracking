import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// The authentication provider
class Auth with ChangeNotifier {
  /// The locally stored base url and auth header
  var backendUrl = '';
  var authHeader = {'authorization': ''};

  /// Checks if the app can connect to a valid  backend
  ///
  /// Takes the [targetBackendUrl] and in case of no error that means
  /// a connection is successful to the valid server.
  Future<int> validateTargetBackend(String targetBackendUrl) async {
    var targetUrl = Uri.parse('$targetBackendUrl/riot-api/config');

    try {
      final response = await http.get(targetUrl);

      backendUrl = targetBackendUrl;

      return response.statusCode;
    } catch (error) {
      rethrow;
    }
  }

  /// Signs a user in using basic authentication.
  ///
  /// Takes the [baseUrl] as the target url. Takes [username] and [password]
  /// to generate a header for basic authentication.
  Future<int> signIn(String baseUrl, String username, String password) async {
    var targetUrl = Uri.parse('$baseUrl/riot-api/config');
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    try {
      authHeader = {'authorization': basicAuth};
      backendUrl = baseUrl;

      final response = await http.get(
        targetUrl,
        headers: authHeader,
      );

      return response.statusCode;
    } catch (error) {
      rethrow;
    }
  }
}
