import 'package:flutter/material.dart';

/// Data Architecture for Module 3 – Explore Domains.
/// Dynamic & Admin Ready with support for custom transparent PNG images or fallback Icons.
class DomainModel {
  final String id;
  final String title;
  final String? image; // Path or URL to transparent PNG illustration
  final IconData? icon; // Fallback icon when image is not present
  final String targetRoute;
  final int displayOrder;
  final bool isActive;
  final Color color;

  const DomainModel({
    required this.id,
    required this.title,
    this.image,
    this.icon,
    required this.targetRoute,
    required this.displayOrder,
    this.isActive = true,
    this.color = const Color(0xFF1976FF),
  });

  /// Default out-of-the-box STEM Domain Categories
  static List<DomainModel> get defaultDomains => const [
        DomainModel(
          id: 'robotics',
          title: 'Robotics',
          image: 'assets/icons/category_robotics.png',
          icon: Icons.smart_toy_rounded,
          targetRoute: '/courses/robotics',
          displayOrder: 1,
          isActive: true,
          color: Color(0xFF7C3AED), // Soft Purple / Lavender
        ),
        DomainModel(
          id: 'iot',
          title: 'IoT & Smart',
          image: 'assets/icons/category_iot.png',
          icon: Icons.sensors_rounded,
          targetRoute: '/courses/iot',
          displayOrder: 2,
          isActive: true,
          color: Color(0xFF0D9488), // Cyan / Teal
        ),
        DomainModel(
          id: 'electronics',
          title: 'Electronics',
          image: 'assets/icons/category_electronics.png',
          icon: Icons.memory_rounded,
          targetRoute: '/courses/electronics',
          displayOrder: 3,
          isActive: true,
          color: Color(0xFFEA580C), // Orange / Amber
        ),
        DomainModel(
          id: 'diy_kits',
          title: 'DIY Kits',
          image: 'assets/icons/category_diy_kits.png',
          icon: Icons.build_rounded,
          targetRoute: '/courses/diy-kits',
          displayOrder: 4,
          isActive: true,
          color: Color(0xFF16A34A), // Green
        ),
        DomainModel(
          id: '3d_printing',
          title: '3D Printing',
          image: 'assets/icons/category_3d_printing.png',
          icon: Icons.view_in_ar_rounded,
          targetRoute: '/courses/3d-printing',
          displayOrder: 5,
          isActive: true,
          color: Color(0xFFDB2777), // Pink / Magenta
        ),
      ];

  /// Factory constructor for Admin Panel / Firebase deserialization
  factory DomainModel.fromJson(Map<String, dynamic> json) {
    return DomainModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'],
      icon: _getIconData(json['iconCodePoint'], json['iconFontFamily']),
      targetRoute: json['targetRoute'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      color: json['color'] != null ? Color(json['color']) : const Color(0xFF1976FF),
    );
  }

  /// Serialize to JSON for Admin Panel saving / Firebase sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'iconCodePoint': icon?.codePoint,
      'iconFontFamily': icon?.fontFamily,
      'targetRoute': targetRoute,
      'displayOrder': displayOrder,
      'isActive': isActive,
      'color': color.toARGB32(),
    };
  }

  static IconData? _getIconData(int? codePoint, String? fontFamily) {
    if (codePoint == null) return null;
    return IconData(codePoint, fontFamily: fontFamily ?? 'MaterialIcons');
  }
}
