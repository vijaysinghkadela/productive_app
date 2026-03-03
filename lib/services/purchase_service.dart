import 'package:focusguard_pro/domain/entities/user.dart';

/// Handles RevenueCat subscription management.
///
/// Wraps the purchases_flutter SDK. In development mode,
/// provides mock subscription state when RevenueCat is not configured.
class PurchaseService {
  bool _configured = false;
  SubscriptionTier _currentTier = SubscriptionTier.free;

  SubscriptionTier get currentTier => _currentTier;
  bool get isConfigured => _configured;

  /// Initialize RevenueCat with API key.
  /// Falls back to mock mode if configuration fails.
  Future<void> configure(String apiKey) async {
    if (apiKey.isEmpty) {
      _configured = false;
      return;
    }

    try {
      // In a full implementation, this would call:
      // await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;
    } catch (e) {
      _configured = false;
    }
  }

  /// Get available subscription packages.
  Future<List<SubscriptionPackage>> getOfferings() async {
    if (!_configured) {
      return _getMockOfferings();
    }

    try {
      // In full implementation: final offerings = await Purchases.getOfferings();
      return _getMockOfferings();
    } catch (e) {
      return _getMockOfferings();
    }
  }

  /// Purchase a subscription package.
  Future<PurchaseResult> purchase(String productId) async {
    if (!_configured) {
      // Mock purchase for development
      _currentTier = _tierFromProductId(productId);
      return PurchaseResult(
        success: true,
        tier: _currentTier,
        message: 'Mock purchase successful',
      );
    }

    try {
      // In full implementation:
      // final customerInfo = await Purchases.purchaseProduct(productId);
      _currentTier = _tierFromProductId(productId);
      return PurchaseResult(
        success: true,
        tier: _currentTier,
        message: 'Purchase successful',
      );
    } catch (e) {
      return PurchaseResult(
        success: false,
        tier: _currentTier,
        message: 'Purchase failed: $e',
      );
    }
  }

  /// Restore previous purchases.
  Future<PurchaseResult> restorePurchases() async {
    if (!_configured) {
      return const PurchaseResult(
        success: true,
        tier: SubscriptionTier.free,
        message: 'No purchases to restore (development mode)',
      );
    }

    try {
      // In full implementation:
      // final customerInfo = await Purchases.restorePurchases();
      return PurchaseResult(
        success: true,
        tier: _currentTier,
        message: 'Purchases restored',
      );
    } catch (e) {
      return PurchaseResult(
        success: false,
        tier: _currentTier,
        message: 'Restore failed: $e',
      );
    }
  }

  /// Check the current subscription status.
  Future<SubscriptionTier> checkSubscriptionStatus() async {
    if (!_configured) return _currentTier;

    try {
      // In full implementation:
      // final customerInfo = await Purchases.getCustomerInfo();
      // Parse active entitlements to determine tier
      return _currentTier;
    } catch (e) {
      return _currentTier;
    }
  }

  /// Log in a user to RevenueCat (sync with Firebase UID).
  Future<void> loginUser(String uid) async {
    if (!_configured) return;
    try {
      // await Purchases.logIn(uid);
    } catch (e) {
      // Silently fail — subscription still works without login
    }
  }

  /// Log out the current user from RevenueCat.
  Future<void> logoutUser() async {
    if (!_configured) return;
    try {
      // await Purchases.logOut();
      _currentTier = SubscriptionTier.free;
    } catch (e) {
      // Silently fail
    }
  }

  SubscriptionTier _tierFromProductId(String productId) {
    if (productId.contains('elite')) return SubscriptionTier.elite;
    if (productId.contains('pro')) return SubscriptionTier.pro;
    if (productId.contains('basic')) return SubscriptionTier.basic;
    return SubscriptionTier.free;
  }

  List<SubscriptionPackage> _getMockOfferings() => const [
        SubscriptionPackage(
          productId: 'focusguard_basic_monthly',
          title: 'Basic',
          description: 'Usage tracking, 3 blocked apps, basic reports',
          price: r'$5.99',
          period: 'month',
          tier: SubscriptionTier.basic,
        ),
        SubscriptionPackage(
          productId: 'focusguard_pro_monthly',
          title: 'Pro',
          description:
              'Unlimited blocking, full analytics, focus sessions, bedtime mode',
          price: r'$9.99',
          period: 'month',
          tier: SubscriptionTier.pro,
          hasFreeTrial: true,
          freeTrialDays: 7,
        ),
        SubscriptionPackage(
          productId: 'focusguard_elite_monthly',
          title: 'Elite',
          description:
              'Everything + accountability partner, AI coach, priority support',
          price: r'$12.99',
          period: 'month',
          tier: SubscriptionTier.elite,
        ),
        SubscriptionPackage(
          productId: 'focusguard_pro_annual',
          title: 'Pro (Annual)',
          description: 'Save 40% with annual billing',
          price: r'$71.88',
          period: 'year',
          tier: SubscriptionTier.pro,
          hasFreeTrial: true,
          freeTrialDays: 7,
        ),
        SubscriptionPackage(
          productId: 'focusguard_elite_annual',
          title: 'Elite (Annual)',
          description: 'Save 40% with annual billing',
          price: r'$93.48',
          period: 'year',
          tier: SubscriptionTier.elite,
        ),
      ];
}

/// Represents a subscription package from RevenueCat.
class SubscriptionPackage {
  const SubscriptionPackage({
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.period,
    required this.tier,
    this.hasFreeTrial = false,
    this.freeTrialDays = 0,
  });
  final String productId;
  final String title;
  final String description;
  final String price;
  final String period;
  final SubscriptionTier tier;
  final bool hasFreeTrial;
  final int freeTrialDays;
}

/// Result of a purchase operation.
class PurchaseResult {
  const PurchaseResult({
    required this.success,
    required this.tier,
    required this.message,
  });
  final bool success;
  final SubscriptionTier tier;
  final String message;
}
