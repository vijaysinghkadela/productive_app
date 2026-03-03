import 'package:flutter/material.dart';
import '../../core/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text('Privacy Policy',
              style: Theme.of(context).textTheme.headlineSmall)),
      body: ListView(padding: const EdgeInsets.all(20), children: const [
        _S('Last Updated: March 1, 2026'),
        _H('1. Introduction'),
        _P('FocusGuard Pro ("we", "our", "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.'),
        _H('2. Information We Collect'),
        _P('App Usage Data: We collect data about which apps you use and for how long. This data is processed locally on your device for core blocking and tracking functionality.'),
        _P('Account Information: When you create an account, we collect your email address, display name, and profile photo (optional).'),
        _P('Focus Session Data: Duration, type, completion status, and distraction counts for each focus session.'),
        _P('Device Information: Device model, operating system version, and app version for crash reporting and compatibility.'),
        _H('3. How We Use Your Data'),
        _P('• Provide core app blocking and usage tracking functionality\n• Calculate your productivity score and analytics\n• Generate AI coaching insights (Elite tier, via OpenAI)\n• Improve our services and fix bugs\n• Send relevant notifications and reminders'),
        _H('4. Data Storage & Security'),
        _P('All app usage data is processed and stored locally on your device using encrypted storage. If you opt into cloud sync, data is stored in Firebase with AES-256 encryption. We use Firebase Security Rules to ensure you can only access your own data.'),
        _H('5. Third-Party Services'),
        _P('• Firebase (Google): Authentication, database, analytics, crash reporting\n• RevenueCat: Subscription management (we only store subscription status)\n• OpenAI: AI coaching feature (Elite tier only, no raw usage data shared)\n• Sentry: Error tracking and performance monitoring'),
        _H('6. Data Sharing'),
        _P('We do NOT sell your personal data to third parties. We do NOT share your app usage data with advertisers. Accountability partner features only share data you explicitly consent to share.'),
        _H('7. Your Rights (GDPR/CCPA)'),
        _P('• Right to access your personal data\n• Right to deletion ("right to be forgotten")\n• Right to data portability (export your data)\n• Right to object to processing\n• Right to correction of inaccurate data\n\nTo exercise any of these rights, contact privacy@focusguard.app'),
        _H('8. Children\'s Privacy (COPPA)'),
        _P('FocusGuard Pro is intended for users aged 13+. We do not knowingly collect information from children under 13. If you are under 18, you must have parental consent to use this app.'),
        _H('9. Data Retention'),
        _P('We retain your data for as long as your account is active. Upon account deletion, all your data is permanently removed within 30 days.'),
        _H('10. Contact'),
        _P('Data Protection Officer: privacy@focusguard.app\nAddress: FocusGuard Inc., Wilmington, Delaware, USA'),
        SizedBox(height: 40),
      ]),
    );
  }
}

class _H extends StatelessWidget {
  final String text;
  const _H(this.text);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700)));
}

class _P extends StatelessWidget {
  final String text;
  const _P(this.text);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 14, height: 1.6)));
}

class _S extends StatelessWidget {
  final String text;
  const _S(this.text);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(text,
          style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
              fontStyle: FontStyle.italic)));
}
