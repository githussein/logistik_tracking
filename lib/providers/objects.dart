import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';
import '../models/object.dart';

class Objects with ChangeNotifier {
  List<Object> _list = [];

  List<Object> get ordersList => [..._list];

  Future<void> fetchOrders(BuildContext context) async {
    var targetUrl = Uri.parse(
        '${Provider.of<Auth>(context).backendUrl}/riot-api/objects?labels=Order&current_geofences=true');

    try {
      final response = await http.get(targetUrl,
          headers: Provider.of<Auth>(context).authHeader);

      List<dynamic> extractedData = json.decode(response.body) as List<dynamic>;
      final List<Object> loadedObjects = [];

      for (var object in extractedData) {
        if (object['current_geofences'].isNotEmpty) {
          var currentGeofences = [];
          object['current_geofences'].forEach((k,v) => currentGeofences.add([k, v]));
          currentGeofences.sort((a,b) => b[1].compareTo(a[1]));

          loadedObjects.add(Object(
            id: object['id'],
            name: object['name'],
            trackingId: object['properties']['tracking-id'] ?? '',
            location: currentGeofences[0][0],
            locationEnterTimestamp: DateTime.parse(currentGeofences[0][1]),
          ));
        } else {
          loadedObjects.add(Object(
            id: object['id'],
            name: object['name'],
            trackingId: object['properties']['tracking-id'] ?? '',
            location: 'unknown',
            locationEnterTimestamp: DateTime.now(),
          ));
        }
      }

      _list = loadedObjects;
    } catch (error) {
      rethrow;
    }
  }
}
