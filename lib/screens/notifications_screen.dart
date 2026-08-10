import 'package:flutter/material.dart';

import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;

  const NotificationsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {

  final ApiService apiService = ApiService();

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {

    try {

      final result =
          await apiService.getNotifications(
        userId: widget.userId,
      );

      if (!mounted) return;

      if (result['success'] == true) {

        final data =
            result['notifications'] ?? [];

        setState(() {

          notifications =
              List<Map<String, dynamic>>.from(
            data,
          );

          isLoading = false;
        });

      } else {

        setState(() {
          errorMessage =
              result['message'] ??
              'Failed to load notifications';

          isLoading = false;
        });
      }

    } catch (e) {

      if (!mounted) return;

      setState(() {

        errorMessage = e.toString();

        isLoading = false;
      });
    }
  }

  Future<void> markAsRead(
    Map<String, dynamic> notification,
  ) async {

    final notificationId =
        notification['NotificationID']
            ?.toString() ??
        '';

    if (notificationId.isEmpty) {
      return;
    }

    try {

      await apiService.markNotificationRead(
        userId: widget.userId,
        notificationId: notificationId,
      );

      if (!mounted) return;

      setState(() {

        notification['IsRead'] = true;
      });

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update notification',
          ),
        ),
      );
    }
  }

  IconData _getNotificationIcon(
    String type,
  ) {

    switch (type.toUpperCase()) {

      case 'ORDER':
        return Icons.shopping_cart;

      case 'SUPPORT':
        return Icons.support_agent;

      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(
    String type,
  ) {

    switch (type.toUpperCase()) {

      case 'ORDER':
        return Colors.blue;

      case 'SUPPORT':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
  ) {

    final title =
        notification['Title']
            ?.toString() ??
        'Notification';

    final message =
        notification['Message']
            ?.toString() ??
        '';

    final type =
        notification['Type']
            ?.toString() ??
        '';

    final isRead =
        notification['IsRead']
            .toString()
            .toLowerCase() ==
        'true';

    final color =
        _getNotificationColor(type);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: isRead ? 1 : 4,
      color: isRead
          ? null
          : Colors.blue.shade50,
      child: InkWell(
        onTap: () => markAsRead(
          notification,
        ),
        borderRadius:
            BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              CircleAvatar(
                backgroundColor:
                    color.withOpacity(0.15),
                child: Icon(
                  _getNotificationIcon(
                    type,
                  ),
                  color: color,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: Text(
                            title,
                            style:
                                TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                            ),
                          ),
                        ),

                        if (!isRead)
                          Container(
                            width: 9,
                            height: 9,
                            decoration:
                                const BoxDecoration(
                              color: Colors.blue,
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.grey
                            .shade700,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      type.isEmpty
                          ? ''
                          : type,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {

    if (isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Text(
            errorMessage!,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      );
    }

    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Icon(
              Icons.notifications_none,
              size: 70,
              color: Colors.grey,
            ),

            SizedBox(height: 16),

            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadNotifications,
      child: ListView.builder(
        padding:
            const EdgeInsets.all(12),
        itemCount:
            notifications.length,
        itemBuilder:
            (context, index) {

          return _buildNotificationCard(
            notifications[index],
          );
        },
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Notifications',
        ),
      ),

      body: _buildBody(),
    );
  }
}