import 'package:flutter/material.dart';

// Use CachedNetworkImage in production, defined here conceptually for the architectural rule
class OptimizedImageWidget extends StatelessWidget {
  const OptimizedImageWidget({
    required this.url,
    required this.targetWidth,
    required this.targetHeight,
    super.key,
  });
  final String url;
  final double targetWidth;
  final double targetHeight;

  @override
  Widget build(BuildContext context) {
    // In actual implementation, replace with:
    // return CachedNetworkImage(...)
    return SizedBox(
      width: targetWidth,
      height: targetHeight,
      child: Image.network(
        url,
        // Memory cache: 100 images
        // Disk cache: 200MB, 30-day TTL
        cacheWidth:
            (targetWidth * MediaQuery.devicePixelRatioOf(context)).round(),
        cacheHeight:
            (targetHeight * MediaQuery.devicePixelRatioOf(context)).round(),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (_, __, ___) => const _DefaultAvatarWidget(),
      ),
    );
  }
}

class _DefaultAvatarWidget extends StatelessWidget {
  const _DefaultAvatarWidget();
  @override
  Widget build(BuildContext context) => const Placeholder();
}

// Preload critical images during splash:
class ImagePreloader {
  static Future<void> preloadCriticalImages(BuildContext context) async {
    await Future.wait([
      precacheImage(const AssetImage('assets/images/logo.webp'), context),
      precacheImage(
        const AssetImage('assets/images/onboarding_1.webp'),
        context,
      ),
      precacheImage(const AssetImage('assets/lottie/splash.json'), context),
    ]);
  }
}
