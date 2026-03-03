import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Offloads heavy processing to background isolates to prevent UI thread blocking.
/// Use for JSON parsing, analytics aggregation, score calculations, and DB sync.
class BackgroundProcessor {
  BackgroundProcessor._();

  /// Run a computation in a background isolate.
  /// [function] must be a top-level or static function.
  static Future<R> run<T, R>(R Function(T) function, T input) {
    return compute(function, input);
  }

  /// Parse a large JSON string in a background isolate.
  static Future<Map<String, dynamic>> parseJson(String jsonString) {
    return compute(_parseJsonIsolate, jsonString);
  }

  /// Aggregate daily stats in background.
  static Future<Map<String, num>> aggregateStats(
      List<Map<String, dynamic>> rawStats) {
    return compute(_aggregateStatsIsolate, rawStats);
  }

  /// Batch-process score calculations in background.
  static Future<List<int>> batchCalculateScores(
      List<Map<String, dynamic>> inputs) {
    return compute(_batchScoresIsolate, inputs);
  }
}

// ─── Top-level isolate functions (must be top-level for compute()) ───

Map<String, dynamic> _parseJsonIsolate(String json) {
  return Map<String, dynamic>.from(jsonDecode(json) as Map);
}

Map<String, num> _aggregateStatsIsolate(List<Map<String, dynamic>> stats) {
  num totalScreenTime = 0;
  num totalSocialMedia = 0;
  num totalFocusMinutes = 0;
  num totalSessions = 0;
  num scoreSum = 0;

  for (final stat in stats) {
    totalScreenTime += (stat['totalScreenTimeMinutes'] as num?) ?? 0;
    totalSocialMedia += (stat['socialMediaMinutes'] as num?) ?? 0;
    totalFocusMinutes += (stat['focusMinutes'] as num?) ?? 0;
    totalSessions += (stat['focusSessionsCompleted'] as num?) ?? 0;
    scoreSum += (stat['productivityScore'] as num?) ?? 0;
  }

  return {
    'totalScreenTime': totalScreenTime,
    'totalSocialMedia': totalSocialMedia,
    'totalFocusMinutes': totalFocusMinutes,
    'totalSessions': totalSessions,
    'averageScore': stats.isEmpty ? 0 : scoreSum / stats.length,
    'count': stats.length,
  };
}

List<int> _batchScoresIsolate(List<Map<String, dynamic>> inputs) {
  return inputs.map((input) {
    const baseScore = 100;
    final socialDeduction = ((input['socialMinutes'] as num?) ?? 0) * 0.3;
    final screenDeduction = ((input['screenMinutes'] as num?) ?? 0) * 0.1;
    final focusBonus = ((input['focusSessions'] as num?) ?? 0) * 5;
    final goalBonus = ((input['goalsMet'] as num?) ?? 0) * 3;

    return (baseScore -
            socialDeduction -
            screenDeduction +
            focusBonus +
            goalBonus)
        .round()
        .clamp(0, 100);
  }).toList();
}
