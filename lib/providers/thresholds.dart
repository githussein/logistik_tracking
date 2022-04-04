import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth.dart';
import '../models/step_thresholds.dart';

class ProcessStepThresholds with ChangeNotifier {
  List<StepThresholds> _list = [];

  List<StepThresholds> get thresholdsList => [..._list];

  Future<void> fetchProcessModel(BuildContext context) async {
    var targetUrl = Uri.parse(
        '${Provider.of<Auth>(context, listen: false).backendUrl}/riot-api/process-model?name=Production');

    try {
      final response = await http.get(targetUrl,
          headers: Provider.of<Auth>(context, listen: false).authHeader);

      List<dynamic> extractedData = json.decode(response.body) as List<dynamic>;
      final List<StepThresholds> loadedThresholds = [];

      if (extractedData.isNotEmpty) {
        var productionProcess = (extractedData.firstWhere(
            (process) => process['data']['process_name']
                .toLowerCase()
                .contains('production')) as Map);

        var subprocesses = productionProcess['data']['subprocesses'];

        for (var subprocess in subprocesses) {
          var steps = subprocess['sequence']['steps'];
          for (var step in steps) {
            loadedThresholds.add(StepThresholds(
              location: step['fence_name'] ?? 'unknown',
              warningDurationInSeconds: step['duration_thresholds_warning'] ?? -1,
              criticalDurationInSeconds: step['duration_thresholds_critical'] ?? -1,
            ));
          }
        }
      } else{
        loadedThresholds.add(StepThresholds(
          location: 'unknown',
          warningDurationInSeconds:  -1,
          criticalDurationInSeconds: -1,
        ));
      }

      _list = loadedThresholds;
    } catch (error) {
      rethrow;
    }
  }
}
