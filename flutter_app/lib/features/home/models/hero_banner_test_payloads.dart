import '../models/hero_banner_model.dart';

/// Test Suite Payloads for Hero Banner Acceptance Criteria Verification.
/// Covers Test Cases 1 through 9.
class HeroBannerTestPayloads {
  HeroBannerTestPayloads._();

  /// Test 1: Image Only Banner (No text, no gradient overlay)
  static const HeroBannerModel test1ImageOnly = HeroBannerModel(
    id: 'test_1_image_only',
    imagePath: 'assets/images/home/banner_bg_diy_kits.png',
    clickAction: BannerClickAction.openCategory,
    targetValue: 'DIY Kits',
    displayOrder: 1,
  );

  /// Test 2: Image + Title Only
  static const HeroBannerModel test2ImageTitle = HeroBannerModel(
    id: 'test_2_image_title',
    imagePath: 'assets/images/home/banner_bg_diy_kits.png',
    title: 'Robotics & Automation 2026',
    clickAction: BannerClickAction.openCourse,
    targetValue: 'robotics_101',
    displayOrder: 2,
  );

  /// Test 3: Image + Title + Subtitle
  static const HeroBannerModel test3ImageTitleSubtitle = HeroBannerModel(
    id: 'test_3_image_title_subtitle',
    imagePath: 'assets/images/home/banner_bg_diy_kits.png',
    title: 'Master Artificial Intelligence',
    subtitle: 'Learn Python, Computer Vision & Neural Networks Step by Step',
    clickAction: BannerClickAction.openCourse,
    targetValue: 'ai_masterclass',
    displayOrder: 3,
  );

  /// Test 4: Image + CTA Button Only
  static const HeroBannerModel test4ImageButton = HeroBannerModel(
    id: 'test_4_image_button',
    imagePath: 'assets/images/home/banner_bg_diy_kits.png',
    buttonText: 'Shop DIY Kits Now',
    clickAction: BannerClickAction.openStore,
    targetValue: 'diy_store',
    displayOrder: 4,
  );

  /// Test 5: Image + Badge Only
  static const HeroBannerModel test5ImageBadge = HeroBannerModel(
    id: 'test_5_image_badge',
    imagePath: 'assets/images/home/banner_bg_diy_kits.png',
    badge: 'LIMITED TIME OFFER 🔥',
    clickAction: BannerClickAction.openExternalUrl,
    targetValue: 'https://edukkit.com/offer',
    displayOrder: 5,
  );

  /// Test 6: Full Marketing Banner (All Fields Populated)
  static const HeroBannerModel test6FullBanner = HeroBannerModel(
    id: 'test_6_full_banner',
    imagePath: 'assets/images/home/banner_bg_diy_kits.png',
    badge: 'NEW ARRIVAL',
    title: 'Build. Create. Innovate.',
    subtitle: 'Hands-on DIY Robotics & Electronics Kits for Curious Minds',
    buttonText: 'Explore Kits Now',
    clickAction: BannerClickAction.openCategory,
    targetValue: 'DIY Kits',
    displayOrder: 6,
  );

  /// Combined List of All Admin Test Payloads
  static List<HeroBannerModel> get allTestBanners => [
        test6FullBanner,
        test1ImageOnly,
        test3ImageTitleSubtitle,
        test4ImageButton,
        test5ImageBadge,
        test2ImageTitle,
      ];
}
