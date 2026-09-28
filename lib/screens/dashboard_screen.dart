import 'package:flutter/material.dart';
import 'dart:async';

import 'order_screen.dart';
import 'support_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';
import '../services/update_service.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  final String vendorName;
  final String role;

  const DashboardScreen({
    super.key,
    required this.userId,
    required this.vendorName,
    required this.role,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  int _unreadNotificationCount = 0;

  Timer? _notificationTimer;

  static const Color purple = Color(0xFF5E2CA5);
  static const Color darkPurple = Color(0xFF4B168C);
  static const Color lightPurple = Color(0xFFF4EEFF);
  static const Color pageBackground = Color(0xFFF9F7FC);

  @override
  void initState() {
    super.initState();

    _loadUnreadNotificationCount();

    _notificationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadUnreadNotificationCount(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: darkPurple,
        title: const Text(
          "Order Management",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
         Stack(
  clipBehavior: Clip.none,
  children: [
    IconButton(
      icon: const Icon(
        Icons.notifications_outlined,
      ),
      tooltip: "Notifications",
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                NotificationsScreen(
              userId: widget.userId,
            ),
          ),
        );

        if (!mounted) return;

        await _loadUnreadNotificationCount();
      },
    ),

    if (_unreadNotificationCount > 0)
      Positioned(
        right: 5,
        top: 5,
        child: Container(
          constraints:
              const BoxConstraints(
            minWidth: 18,
            minHeight: 18,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius:
                BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
          ),
          child: Text(
            _unreadNotificationCount > 99
                ? "99+"
                : _unreadNotificationCount
                    .toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
  ],
),

          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              final shouldLogout =
                  await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  title: const Text("Logout"),
                  content: const Text(
                    "Are you sure you want to logout?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          false,
                        );
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                          true,
                        );
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (shouldLogout != true ||
                  !context.mounted) {
                return;
              }

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ------------------------------------------
              // WELCOME CARD
              // ------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      darkPurple,
                      Color(0xFF7B3FC6),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color:
                          purple.withOpacity(0.20),
                      blurRadius: 18,
                      offset:
                          const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome, ${widget.vendorName}",
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "User ID: ${widget.userId}",
                            style:
                                const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            "Role: ${widget.role}",
                            style:
                                const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Quick Access",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B3D),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Manage your purchase orders and support",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

             // ------------------------------------------
// DTR + E-OFFICE
// ------------------------------------------

Row(
  children: [
    Expanded(
      child: _dashboardCard(
        icon: Icons.shopping_cart_outlined,
        title: "DTR PO Orders",
        subtitle: "View DTR purchase orders",
        color: const Color(0xFF6C35B8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrdersScreen(
               userId: widget.userId,
                orderType: "DTR_PO",
              ),
            ),
          );
        },
      ),
    ),

    const SizedBox(width: 14),

    Expanded(
      child: _dashboardCard(
        icon: Icons.assignment_outlined,
        title: "E-Office Orders",
        subtitle: "View E-Office orders",
        color: const Color(0xFF8A4BC4),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrdersScreen(
                userId: widget.userId,
                orderType: "E_OFFICE",
              ),
            ),
          );
        },
      ),
    ),
  ],
),

const SizedBox(height: 14),

// ------------------------------------------
// OTHER PO + SUPPORT
// ------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _dashboardCard(
                      icon: Icons.inventory_2_outlined,
                      title: "Other PO",
                      subtitle: "View other purchase orders",
                      color: const Color(0xFF5E2CA5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrdersScreen(
                              userId: widget.userId,
                              orderType: "OTHER_PO",
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _dashboardCard(
                      icon: Icons.support_agent_outlined,
                      title: "Support & Help",
                      subtitle: "Get help or contact support",
                      color: const Color(0xFF5E2CA5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SupportScreen(
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

Future<void> _loadUnreadNotificationCount() async {
  try {
    final result =
        await ApiService().getNotifications(
      userId: widget.userId,
    );

    if (!mounted) return;

    if (result["success"] != true) {
      return;
    }

    final data = result["notifications"];

    if (data is! List) {
      return;
    }

    int unreadCount = 0;

    for (final item in data) {
      final notification =
          Map<String, dynamic>.from(item);

      final isRead =
          notification["IsRead"]
                  ?.toString()
                  .toLowerCase() ==
              "true";

      if (!isRead) {
        unreadCount++;
      }
    }

    setState(() {
      _unreadNotificationCount =
          unreadCount;
    });
  } catch (e) {
    debugPrint(
      "Unread notification count failed: $e",
    );
  }
}
  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 195,
          padding:
              const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: lightPurple,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.07),
                blurRadius: 14,
                offset:
                    const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration:
                    BoxDecoration(
                  color:
                      color.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 29,
                ),
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF2D1B3D),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  color:
                      Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons
                        .arrow_forward_rounded,
                    color: color,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------
  // UPDATE CHECK — KEEPING YOUR CURRENT WORKING LOGIC
  // --------------------------------------------------------

  Future<void> _checkForUpdate(
    BuildContext context,
  ) async {
    try {
      final result =
          await UpdateService().checkForUpdate();

      if (!context.mounted) return;

      if (result["updateAvailable"] != true) {
        return;
      }

      final latestVersion =
          result["latestVersion"]
                  ?.toString() ??
              "";

      final currentVersion =
          result["currentVersion"]
                  ?.toString() ??
              "";

      final releaseNotes =
          result["releaseNotes"]
                  ?.toString() ??
              "";

      final apkUrl =
          result["apkUrl"]?.toString() ??
              "";

      if (apkUrl.isEmpty) {
        return;
      }

      final shouldUpdate =
          await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.system_update,
                  color: purple,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "New Version Available",
                  ),
                ),
              ],
            ),
            content:
                SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current version: "
                    "$currentVersion",
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "New version: "
                    "$latestVersion",
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      color: purple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "What's new:",
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    releaseNotes.isEmpty
                        ? "A new version of the app is available."
                        : releaseNotes,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },
                child:
                    const Text("Later"),
              ),
              ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      purple,
                  foregroundColor:
                      Colors.white,
                ),
                icon: const Icon(
                  Icons.download,
                ),
                label: const Text(
                  "Update Now",
                ),
                onPressed: () async {
                  Navigator.pop(
                    dialogContext,
                    true,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  try {
                    await UpdateService()
                        .downloadAndInstallApk(
                      apkUrl: apkUrl,
                      onProgress:
                          (progress) {
                        debugPrint(
                          "APK download: "
                          "${(progress * 100).toStringAsFixed(0)}%",
                        );
                      },
                    );
                  } catch (e) {
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger
                        .of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          "Update failed: $e",
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      );

      if (shouldUpdate != true ||
          !context.mounted) {
        return;
      }
    } catch (e) {
      debugPrint(
        "Update check failed: $e",
      );
    }
  }
@override
void dispose() {
  _notificationTimer?.cancel();
  super.dispose();
}
}