/// Data Architecture model for Free DIY Video Classes
class DiyVideoModel {
  final String id;
  final String title;
  final String description;
  final String assetPath;
  final String videoUrl;
  final String duration;
  final String level;
  final bool isFree;
  final String? relatedKitId;

  const DiyVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.videoUrl,
    required this.duration,
    required this.level,
    this.isFree = true,
    this.relatedKitId,
  });

  factory DiyVideoModel.fromJson(Map<String, dynamic> json) {
    return DiyVideoModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      assetPath: json['assetPath'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      duration: json['duration'] ?? '10:00',
      level: json['level'] ?? 'Beginner',
      isFree: json['isFree'] ?? true,
      relatedKitId: json['relatedKitId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assetPath': assetPath,
      'videoUrl': videoUrl,
      'duration': duration,
      'level': level,
      'isFree': isFree,
      'relatedKitId': relatedKitId,
    };
  }
}

/// Data Architecture model for Physical DIY Hardware Kits
class DiyKitModel {
  final String id;
  final String title;
  final String description;
  final String assetPath;
  final double price;
  final String priceText;
  final String level;
  final String buildTime;
  final double rating;
  final bool isAvailable;

  const DiyKitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.price,
    required this.priceText,
    required this.level,
    required this.buildTime,
    this.rating = 4.8,
    this.isAvailable = true,
  });

  factory DiyKitModel.fromJson(Map<String, dynamic> json) {
    return DiyKitModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      assetPath: json['assetPath'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      priceText: json['priceText'] ?? '₹0',
      level: json['level'] ?? 'Beginner',
      buildTime: json['buildTime'] ?? '2 hrs',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assetPath': assetPath,
      'price': price,
      'priceText': priceText,
      'level': level,
      'buildTime': buildTime,
      'rating': rating,
      'isAvailable': isAvailable,
    };
  }
}

/// Central Static & Dynamic Data Provider for DIY Kits Workshop
class DiyKitsData {
  static List<DiyVideoModel> get freeVideoClasses => const [
        DiyVideoModel(
          id: 'v_diy_01',
          title: 'Build Your First Robot Car',
          description:
              'Step-by-step tutorial covering TT DC motors, acrylic chassis assembly, L298N driver wiring & Arduino code.',
          assetPath: 'assets/images/courses/junior_automation.png',
          videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
          duration: '12:45',
          level: 'Beginner',
          relatedKitId: 'kit_car_01',
        ),
        DiyVideoModel(
          id: 'v_diy_02',
          title: 'How to Use a Breadboard',
          description:
              'Learn circuit connections, breadboard rails, power lines, and jumper wire placement for DIY electronics.',
          assetPath: 'assets/images/courses/iot_house_3d.png',
          videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
          duration: '08:15',
          level: 'Beginner',
          relatedKitId: 'kit_iot_02',
        ),
        DiyVideoModel(
          id: 'v_diy_03',
          title: 'LED Projects for Beginners',
          description:
              'Build blinking LED circuits, traffic light controllers, and RGB color mixing experiments step-by-step.',
          assetPath: 'assets/images/courses/senior_robotics_banner.png',
          videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
          duration: '10:30',
          level: 'Beginner',
          relatedKitId: 'kit_solar_03',
        ),
        DiyVideoModel(
          id: 'v_diy_04',
          title: 'Fun with Buzzer & Sound',
          description:
              'Create musical tones, alarm sounders, and interactive audio feedback circuits using piezo buzzers.',
          assetPath: 'assets/images/courses/ai_robotics_hero.png',
          videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
          duration: '06:45',
          level: 'Beginner',
          relatedKitId: 'kit_solar_04',
        ),
      ];

  static List<DiyKitModel> get diyPhysicalKits => const [
        DiyKitModel(
          id: 'kit_car_01',
          title: 'Smart Obstacle Avoiding Car Kit',
          description:
              'Complete hands-on kit with Ultrasonic sensor, HC-SR04, servo motor mount, L298N driver & chassis.',
          assetPath: 'assets/images/courses/junior_automation.png',
          price: 1299.0,
          priceText: '₹1,299',
          level: 'Beginner',
          buildTime: '2–3 hrs',
          rating: 4.9,
        ),
        DiyKitModel(
          id: 'kit_iot_02',
          title: 'IoT Smart Home Starter Kit',
          description:
              'ESP32 Wi-Fi NodeMCU module, 4-channel relay board, DHT11 temp sensor & OLED display panel.',
          assetPath: 'assets/images/courses/iot_house_3d.png',
          price: 1699.0,
          priceText: '₹1,699',
          level: 'Intermediate',
          buildTime: '3–4 hrs',
          rating: 4.8,
        ),
        DiyKitModel(
          id: 'kit_solar_03',
          title: '4WD Robotics Exploration Kit',
          description:
              'Heavy duty 4-wheel drive acrylic robot chassis with optical speed encoders, Arduino Uno & motor shield.',
          assetPath: 'assets/images/courses/senior_robotics_banner.png',
          price: 1499.0,
          priceText: '₹1,499',
          level: 'Beginner',
          buildTime: '2 hrs',
          rating: 4.9,
        ),
        DiyKitModel(
          id: 'kit_solar_04',
          title: 'Solar Power Maker Kit',
          description:
              'Solar cell panels, micro DC motors, gear wheels, propellers & step-by-step experiment project book.',
          assetPath: 'assets/images/courses/ai_robotics_hero.png',
          price: 899.0,
          priceText: '₹899',
          level: 'Beginner',
          buildTime: '1–2 hrs',
          rating: 4.7,
        ),
      ];
}
