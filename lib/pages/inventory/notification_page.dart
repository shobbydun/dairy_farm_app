import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: NotificationList(),
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample notifications
    final notifications = [
      NotificationItem(
        title: 'Milk Production Alert',
        description: 'Your daily milk production has reached 300 liters.',
        timestamp: '2024-08-15 08:45 AM',
      ),
      NotificationItem(
        title: 'Maintenance Reminder',
        description: 'It\'s time for the quarterly maintenance of dairy equipment.',
        timestamp: '2024-08-14 03:30 PM',
      ),
      // Add more notifications as needed
    ];

    return notifications.isEmpty
        ? Center(
            child: Text(
              'No Notifications',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          )
        : ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationCard(notification: notification);
            },
          );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        subtitle: Text(
          notification.description,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        trailing: Text(
          notification.timestamp,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String description;
  final String timestamp;

  NotificationItem({
    required this.title,
    required this.description,
    required this.timestamp,
  });
}
