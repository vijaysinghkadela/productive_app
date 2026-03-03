import 'package:flutter_test/flutter_test.dart';
import 'package:focus_guard/domain/entities/user.dart';
import 'package:focus_guard/services/purchase_service.dart';

void main() {
  late PurchaseService service;

  setUp(() {
    service = PurchaseService();
  });

  group('PurchaseService', () {
    test('starts in free tier', () {
      expect(service.currentTier, SubscriptionTier.free);
      expect(service.isConfigured, false);
    });

    test('configure with empty key leaves service unconfigured', () async {
      await service.configure('');
      expect(service.isConfigured, false);
    });

    test('getOfferings returns mock offerings when unconfigured', () async {
      final offerings = await service.getOfferings();
      expect(offerings.length, 5);
      expect(offerings[0].productId, 'focusguard_basic_monthly');
      expect(offerings[1].productId, 'focusguard_pro_monthly');
      expect(offerings[2].productId, 'focusguard_elite_monthly');
      expect(offerings[3].productId, 'focusguard_pro_annual');
      expect(offerings[4].productId, 'focusguard_elite_annual');
    });

    test('offering tiers are correct', () async {
      final offerings = await service.getOfferings();
      expect(offerings[0].tier, SubscriptionTier.basic);
      expect(offerings[1].tier, SubscriptionTier.pro);
      expect(offerings[2].tier, SubscriptionTier.elite);
    });

    test('pro offerings have free trial', () async {
      final offerings = await service.getOfferings();
      final proMonthly =
          offerings.firstWhere((o) => o.productId == 'focusguard_pro_monthly');
      expect(proMonthly.hasFreeTrial, true);
      expect(proMonthly.freeTrialDays, 7);
    });

    test('mock purchase updates current tier to basic', () async {
      final result = await service.purchase('focusguard_basic_monthly');
      expect(result.success, true);
      expect(result.tier, SubscriptionTier.basic);
      expect(service.currentTier, SubscriptionTier.basic);
    });

    test('mock purchase updates current tier to pro', () async {
      final result = await service.purchase('focusguard_pro_monthly');
      expect(result.success, true);
      expect(result.tier, SubscriptionTier.pro);
      expect(service.currentTier, SubscriptionTier.pro);
    });

    test('mock purchase updates current tier to elite', () async {
      final result = await service.purchase('focusguard_elite_annual');
      expect(result.success, true);
      expect(result.tier, SubscriptionTier.elite);
      expect(service.currentTier, SubscriptionTier.elite);
    });

    test('restorePurchases returns success in mock mode', () async {
      final result = await service.restorePurchases();
      expect(result.success, true);
    });

    test('checkSubscriptionStatus returns current tier', () async {
      await service.purchase('focusguard_pro_monthly');
      final tier = await service.checkSubscriptionStatus();
      expect(tier, SubscriptionTier.pro);
    });

    test('logoutUser resets tier to free when configured', () async {
      await service.configure('test_api_key');
      await service.purchase('focusguard_pro_monthly');
      await service.logoutUser();
      expect(service.currentTier, SubscriptionTier.free);
    });
  });
}
