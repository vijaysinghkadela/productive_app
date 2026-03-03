# GEMINI.md — FocusGuard Pro Memory Context

> Last Updated: March 3, 2026
> Goal: Give any LLM a compact, accurate project memory to work safely in this repo.

## 1) Quick Identity

- App: **FocusGuard Pro**
- Tagline: **Guard your focus. Own your time.**
- Product: Cross-platform productivity + digital wellness SaaS
- Client: Flutter (Android, iOS, Linux target in repo)
- Backend: Firebase (Auth, Firestore, Cloud Functions, Crashlytics)
- AI: OpenAI GPT-4o live, Gemini planned
- Billing: RevenueCat primary + Stripe payment sheet integration in-app

## 2) Tech Snapshot

- Flutter: 3.19+
- Dart: 3.x
- State: Riverpod 2.x
- Navigation: `go_router`
- Local persistence: Hive (+ Isar planned/partial)
- Network: Dio + Firebase callable functions
- Subscriptions: RevenueCat + Stripe (`flutter_stripe`)

## 3) Source-of-Truth Architecture

Primary code roots:

- `lib/core/`: constants, shared services, errors, utilities
- `lib/data/`: models, datasources, repository implementations
- `lib/domain/`: entities, repository interfaces, use cases
- `lib/presentation/`: screens, providers, widgets
- `functions/`: Firebase Cloud Functions (Stripe + RevenueCat backend logic)

Design intent (enforced where possible):

- Business logic in use cases/repositories
- UI in screens/widgets
- Providers coordinate state, not heavy logic

## 4) Subscription + Billing (Current State)

### Tier model

- Free, Basic, Pro, Elite
- Tier enum used in domain: `lib/domain/entities/user.dart`

### Subscription data model (updated)

File: `lib/data/models/feature_models.dart`

`SubscriptionModel` now supports both RevenueCat and Stripe:

- Existing fields: `userId`, `tier`, `productId`, `purchaseDate`, `expirationDate`, `isTrialActive`, `willRenew`, `store`
- New fields:
  - `paymentProvider` (`BillingProvider` enum)
  - `stripeCustomerId`
  - `stripeSubscriptionId`
  - `stripePriceId`
  - `metadata` (`Map<String, String>`)
- New helper:
  - `SubscriptionModel.stripe(...)` factory for Stripe-backed payloads
- Provider enum:
  - `BillingProvider.revenueCat`
  - `BillingProvider.stripe`
  - `BillingProvider.appStore`
  - `BillingProvider.playStore`
  - `BillingProvider.unknown`

### Stripe service contract (updated)

File: `lib/core/services/stripe_service.dart`

- `presentSubscriptionSheet(tierId)` now returns a **structured** `StripeCheckoutResult` instead of raw bool.
- `StripeCheckoutResult` includes:
  - `success`
  - `tierId`
  - `customerId`
  - `subscriptionId`
  - `priceId`
  - `currencyCode`
  - `message`

### Subscription screen behavior (updated)

File: `lib/presentation/screens/subscription_screen.dart`

- Uses Stripe checkout result
- On success:
  - Builds `SubscriptionModel.stripe(...)`
  - Updates local auth tier (`authProvider.updateTier(...)`)
  - Shows success snackbar
- On cancel/failure:
  - Shows user-safe message

## 5) Stripe Backend Context

Cloud Functions files:

- `functions/src/subscriptions/subscriptions.service.ts`
  - `createStripeSubscription` callable
  - Returns client secret + customer + ephemeral key (and optional extra metadata)
- `functions/src/webhooks/webhooks.handlers.ts`
  - `stripeWebhook` updates Firestore subscription state
- RevenueCat webhook path is also active and supported

## 6) Anti-Gravity (Elite)

Implemented components now present:

- `lib/data/providers/anti_gravity_provider.dart`
- `lib/domain/use_cases/focus/activate_anti_gravity.dart`
- `lib/presentation/screens/focus/anti_gravity_overlay.dart`
- `lib/presentation/widgets/floating_card.dart`
- `lib/presentation/widgets/particle_painter.dart`

Behavior summary:

- Elite + active session + elapsed threshold => active
- Pro users get upsell shimmer/upgrade badge
- Sensor stream throttled and paused when inactive

## 7) Key Env / Secrets

`.env` / runtime keys used in project context:

- `OPENAI_API_KEY`
- `FIREBASE_API_KEY`
- `REVENUECAT_API_KEY_ANDROID`
- `REVENUECAT_API_KEY_IOS`
- `GEMINI_API_KEY`
- Stripe publishable key:
  - configure secure runtime/build injection for `STRIPE_PUBLISHABLE_KEY`
  - current UI uses `pk_test_placeholder` fallback until secure wiring is finalized

Cloud Function secrets:

- `stripe-secret-key`
- `stripe-webhook-secret`
- `revenuecat-webhook-secret`

## 8) LLM Working Rules

When editing this repo:

- Keep feature gate logic tier-safe
- Do not break existing route names unless migrating router everywhere
- Maintain backward compatibility when changing model JSON shape
- If touching billing, update both:
  - app side (`lib/`)
  - function side (`functions/`) if contract changes

## 9) Fast Navigation Map

- Entry: `lib/main.dart`
- Router: `lib/core/router.dart`
- Route constants: `lib/core/constants/route_constants.dart`
- Focus session UI: `lib/presentation/screens/focus_session_screen.dart`
- Subscription UI: `lib/presentation/screens/subscription_screen.dart`
- Stripe service: `lib/core/services/stripe_service.dart`
- Subscription model: `lib/data/models/feature_models.dart`
- Repository interfaces: `lib/domain/repositories/repositories.dart`

## 10) Session Bootstrap Block (for Gemini/LLM)

Use this at start of a fresh model session:

```text
Project: FocusGuard Pro
Stack: Flutter + Riverpod + Firebase
Billing: RevenueCat + Stripe
Source of truth: GEMINI.md + code under lib/ and functions/
Priorities: preserve tier gates, keep JSON compatibility, keep UI responsive
Task: [insert concrete task]
```

---

If architecture, billing contracts, or key flows change, update this file in the same PR.
