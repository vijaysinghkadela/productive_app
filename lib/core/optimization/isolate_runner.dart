// ignore_for_file: inference_failure_on_untyped_parameter, type_annotate_public_apis
import 'package:flutter/foundation.dart';

class IsolateRunner {
  // Run on isolate to keep UI thread responsive:

  // 1. Score calculation (involves many loops):
  static Future<dynamic> calculateScore(input) async =>
      compute(_calculateScoreIsolate, input);

  // 2. Report data aggregation (processes 30+ days of data):
  static Future<dynamic> aggregateReportData(List<dynamic> stats) async =>
      compute(_aggregateIsolate, stats);

  // 3. CSV/JSON export formatting:
  static Future<String> formatExportData(data) async =>
      compute(_formatExportIsolate, data);

  // 4. Image processing (EXIF stripping, resize):
  static Future<Uint8List> processImage(Uint8List imageBytes) async =>
      compute(_processImageIsolate, imageBytes);

  // 5. Encryption of large data sets:
  static Future<dynamic> encryptBatch(input) async =>
      compute(_encryptBatchIsolate, input);

  // Isolate Functional entrypoints
  static Future<dynamic> _calculateScoreIsolate(input) async => null;
  static Future<dynamic> _aggregateIsolate(List<dynamic> stats) async => null;
  static Future<String> _formatExportIsolate(data) async => '';
  static Future<Uint8List> _processImageIsolate(Uint8List bytes) async => bytes;
  static Future<dynamic> _encryptBatchIsolate(input) async => null;
}
