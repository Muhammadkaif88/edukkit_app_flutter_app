import 'package:flutter/material.dart';
import '../../models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data based on the image
    final List<NotificationModel> notifications = [
      NotificationModel(
        id: "1",
        title: "New Course Added!",
        description: "Check out our new Robotics for Beginners course.",
        timestamp: "2 hrs ago",
        type: "course",
        isRead: false,
      ),
      NotificationModel(
        id: "2",
        title: "Order Dispatched",
        description: "Your DIY Kit order #12345 has been dispatched via WhatsApp.",
        timestamp: "1 day ago",
        type: "order",
        isRead: true,
      ),
      NotificationModel(
        id: "3",
        title: "Welcome to Edukkit",
        description: "Thanks for joining our learning community!",
        timestamp: "2 days ago",
        type: "welcome",
        isRead: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(
          color: Color(0xFFEEEEEE),
          thickness: 1,
          indent: 20,
          endIndent: 20,
        ),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    Color iconBgColor;
    Color iconColor;
    
    // Set colors based on read status or type (matching the image)
    if (!notification.isRead) {
      iconBgColor = const Color(0xFFE8EAF6); // Light purple
      iconColor = const Color(0xFF5D3AC8);   // Main purple
    } else {
      iconBgColor = const Color(0xFFF1F1F1); // Light grey
      iconColor = const Color(0xFF9E9E9E);   // Grey
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6E6E6E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.timestamp,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
