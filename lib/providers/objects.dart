import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';
import '../models/object.dart';

class Objects with ChangeNotifier {
  List<Object> _list = [];

  List<Object> get objectsList => [..._list];

  Future<void> fetchObjects(BuildContext context) async {
    var targetUrl =
        Uri.parse('${Provider.of<Auth>(context).backendUrl}/riot-api/objects');

    try {
      final response = await http.get(targetUrl,
          headers: Provider.of<Auth>(context).authHeader);

      List<dynamic> extractedData = json.decode(response.body) as List<dynamic>;
      final List<Object> loadedObjects = [];

      for (var object in extractedData) {
        loadedObjects.add(Object(
          id: object['id'],
          name: object['name'],
        ));
      }

      _list = loadedObjects;
    } catch (error) {
      rethrow;
    }
  }
}
