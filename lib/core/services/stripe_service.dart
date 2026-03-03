import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:focusguard_pro/core/errors/app_exceptions.dart';

/// Provides Stripe integrations.
final stripeServiceProvider = Provider<StripeService>((ref) => StripeService());

class StripeService {
  bool _isInitialized = false;

  /// Ensure Stripe publishable key is set before presenting the payment sheet
  Future<void> initStripe(String publishableKey) async {
    if (_isInitialized) return;

    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
    _isInitialized = true;
  }

  /// Triggers a subscription checkout via Firebase Function + Stripe Payment Sheet.
  ///
  /// Returns a structured checkout result that can be mapped into
  /// the app subscription model in presentation/data layers.
  Future<StripeCheckoutResult> presentSubscriptionSheet(String tierId) async {
    try {
      if (!_isInitialized) {
        throw const AppException(
          'Stripe has not been initialized with a publishable key.',
        );
      }

      // Step 1: Call our backend to create a Stripe Subscription -> gets a SetupIntent/PaymentIntent client secret
      final callable =
          FirebaseFunctions.instance.httpsCallable('createStripeSubscription');

      final HttpsCallableResult<dynamic> result =
          await callable.call<Map<String, dynamic>>(<String, dynamic>{
        'tierId': tierId, // e.g., "pro", "elite"
      });

      final data = result.data as Map<String, dynamic>;
      final clientSecret = data['clientSecret'] as String?;
      final customerId = data['customer'] as String?;
      final ephemeralKey = data['ephemeralKey'] as String?;
      final subscriptionId = data['subscriptionId'] as String?;
      final priceId = data['priceId'] as String?;
      final currencyCode = data['currencyCode'] as String? ?? 'USD';

      if (clientSecret == null || clientSecret.isEmpty) {
        throw const AppException(
          'Failed to fetch client secret from backend. The subscription process cannot continue.',
        );
      }

      // Step 2: Initialize Payment Sheet from Stripe Native UI
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKey,
          merchantDisplayName: 'FocusGuard Pro',
          // Optional: styling
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF6200EA), // Deep purple as primary
            ),
          ),
        ),
      );

      // Step 3: Present Payment Sheet to the user
      await Stripe.instance.presentPaymentSheet();

      // If no exception was thrown, payment/setup was complete.
      return StripeCheckoutResult(
        success: true,
        tierId: tierId,
        customerId: customerId,
        subscriptionId: subscriptionId,
        priceId: priceId,
        currencyCode: currencyCode,
      );
    } on StripeException catch (err) {
      if (err.error.code == FailureCode.Canceled) {
        debugPrint('User cancelled the Stripe payment sheet.');
        return StripeCheckoutResult(
          success: false,
          tierId: tierId,
          message: 'User cancelled checkout.',
        );
      }
      debugPrint(r'StripeException: ${err.error.localizedMessage}');
      throw AppException(
        err.error.localizedMessage ??
            'An error occurred during secure checkout.',
      );
    } catch (err) {
      debugPrint(r'StripeService error: $err');
      throw AppException('An unexpected error happened during checkout: $err');
    }
  }
}

/// Structured response returned by Stripe checkout flow.
class StripeCheckoutResult {
  const StripeCheckoutResult({
    required this.success,
    required this.tierId,
    this.customerId,
    this.subscriptionId,
    this.priceId,
    this.currencyCode = 'USD',
    this.message,
  });

  final bool success;
  final String tierId;
  final String? customerId;
  final String? subscriptionId;
  final String? priceId;
  final String currencyCode;
  final String? message;
}
