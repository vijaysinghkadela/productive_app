import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focusguard_pro/services/usage_tracker_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UsageTrackerService service;

  setUp(() {
    service = UsageTrackerService();

    // Mock the platform channel to return demo data
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.focusguard/usage_tracker'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getUsageStats':
            return <String, int>{
              'com.instagram.android': 45,
              'com.zhiliaoapp.musically': 30,
              'com.google.android.youtube': 60,
              'com.twitter.android': 20,
              'com.facebook.katana': 15,
              'com.whatsapp': 40,
              'com.android.chrome': 35,
              'com.google.android.gm': 10,
              'com.spotify.music': 30,
              'com.netflix.mediaclient': 50,
            };
          case 'hasUsagePermission':
            return true;
          case 'getInstalledApps':
            return <Map<String, String>>[];
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.focusguard/usage_tracker'),
      null,
    );
  });

  group('UsageTrackerService', () {
    test('getUsageStats returns data from platform channel', () async {
      final stats = await service.getUsageStats(
        startDate: DateTime.now().subtract(const Duration(hours: 12)),
        endDate: DateTime.now(),
      );

      expect(stats, isA<Map<String, int>>());
      expect(stats.isNotEmpty, true);
      expect(stats['com.instagram.android'], 45);
    });

    test('getAppUsageToday returns value for known package', () async {
      final usage = await service.getAppUsageToday('com.instagram.android');
      expect(usage, 45);
    });

    test('getAppUsageToday returns 0 for unknown package', () async {
      final usage = await service.getAppUsageToday('com.nonexistent.app');
      expect(usage, 0);
    });

    test('getTotalScreenTimeToday returns sum of all usage', () async {
      final total = await service.getTotalScreenTimeToday();
      expect(total, isA<int>());
      // 45+30+60+20+15+40+35+10+30+50 = 335
      expect(total, 335);
    });

    test('getSocialMediaUsageToday returns sum of social media apps', () async {
      final socialTotal = await service.getSocialMediaUsageToday();
      // instagram(45) + tiktok(30) + youtube(60) + twitter(20) + facebook(15) = 170
      expect(socialTotal, 170);
    });

    test('hasUsagePermission returns true from mock', () async {
      final hasPermission = await service.hasUsagePermission();
      expect(hasPermission, true);
    });
  });
}
