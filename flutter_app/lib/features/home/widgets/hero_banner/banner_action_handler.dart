import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/hero_banner_model.dart';

/// Reusable Production Navigation Handler for Edukkit Banners.
/// Dispatches click actions from Admin Panel configuration.
class BannerActionHandler {
  BannerActionHandler._();

  static Future<void> execute(
    BuildContext context, {
    required BannerClickAction action,
    String? targetValue,
  }) async {
    final String target = targetValue?.trim() ?? '';

    switch (action) {
      case BannerClickAction.openCourse:
        if (target.isNotEmpty) {
          Navigator.pushNamed(context, '/course-detail', arguments: {'courseId': target});
        } else {
          Navigator.pushNamed(context, '/courses');
        }
        break;

      case BannerClickAction.openCategory:
        if (target.isNotEmpty) {
          Navigator.pushNamed(context, '/category-courses', arguments: {'category': target});
        }
        break;

      case BannerClickAction.openProduct:
      case BannerClickAction.openStore:
        if (target.isNotEmpty) {
          Navigator.pushNamed(context, '/store', arguments: {'productId': target});
        } else {
          Navigator.pushNamed(context, '/store');
        }
        break;

      case BannerClickAction.openExternalUrl:
      case BannerClickAction.openYouTube:
      case BannerClickAction.openPdf:
      case BannerClickAction.openWebView:
        if (target.isNotEmpty) {
          final Uri uri = Uri.parse(target);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            debugPrint('Could not launch URL: $target');
          }
        }
        break;

      case BannerClickAction.openCustomScreen:
        if (target.isNotEmpty) {
          final routeName = target.startsWith('/') ? target : '/$target';
          Navigator.pushNamed(context, routeName);
        }
        break;

      case BannerClickAction.doNothing:
        debugPrint('Banner tapped with action: doNothing');
        break;
    }
  }
}
