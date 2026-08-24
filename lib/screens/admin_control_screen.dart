import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'vendor_management_screen.dart';
import 'pending_devices_screen.dart';
import 'audit_log_screen.dart';
import 'support_screen.dart';
import 'admin_support_screen.dart';
import 'password_reset_requests_screen.dart';
import 'create_notification_screen.dart';

class AdminControlScreen extends StatelessWidget {
  final String userId;

  const AdminControlScreen({
    super.key,
    required this.userId,
  });

  static const Color purple = Color(0xFF5E2CA5);
  static const Color darkPurple = Color(0xFF4B168C);
  static const Color pageBackground = Color(0xFFF9F7FC);
  static const Color lightPurple = Color(0xFFF4EEFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: darkPurple,
        title: const Text(
          "Admin Control",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -----------------------------------------------
              // HEADER
              // -----------------------------------------------

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
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withOpacity(0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Admin Control",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Manage users, devices, support and system activities",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
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
                "Administration",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B3D),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Select an area to manage",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),



              const SizedBox(height: 20),

              // -----------------------------------------------
              // VENDORS + PENDING DEVICES
              // -----------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _controlCard(
                      icon: Icons.business,
                      title: "Vendors",
                      subtitle: "Manage vendor accounts",
                      color: const Color(0xFF8A4BC4),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VendorManagementScreen(
                              userId: userId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _controlCard(
                      icon: Icons.phonelink_lock,
                      title: "Pending Devices",
                      subtitle: "Approve registered devices",
                      color: const Color(0xFFB04489),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PendingDevicesScreen(
                              adminUserId: userId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // -----------------------------------------------
// NOTIFICATIONS + PASSWORD RESET
// -----------------------------------------------

Row(
  children: [
    Expanded(
      child: _controlCard(
        icon: Icons.notifications_active,
        title: "Notifications",
        subtitle: "Send a message to all users",
        color: const Color(0xFF5E2CA5),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateNotificationScreen(
                adminUserId: userId,
              ),
            ),
          );
        },
      ),
    ),

    const SizedBox(width: 14),

    Expanded(
      child: _controlCard(
        icon: Icons.lock_reset,
        title: "Password Reset",
        subtitle: "View reset requests",
        color: const Color(0xFF7B3FC6),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PasswordResetRequestsScreen(
                adminUserId: userId,
              ),
            ),
          );
        },
      ),
    ),
  ],
),

              const SizedBox(height: 14),

             // -----------------------------------------------
// AUDIT LOG + SUPPORT & HELP
// -----------------------------------------------

Row(
  children: [
    Expanded(
      child: _controlCard(
        icon: Icons.history,
        title: "Audit Log",
        subtitle: "Review system activity",
        color: const Color(0xFF6D3BB2),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AuditLogScreen(
                userId: userId,
              ),
            ),
          );
        },
      ),
    ),

    const SizedBox(width: 14),

    Expanded(
      child: _controlCard(
        icon: Icons.support_agent,
        title: "Support & Help",
        subtitle: "Help resources",
        color: const Color(0xFF7B3FC6),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  SupportScreen(
                userId: userId,
              ),
            ),
          );
        },
      ),
    ),
  ],
),
const SizedBox(height: 14),

Row(
  children: [
    Expanded(
      child: _controlCard(
        icon: Icons.confirmation_number,
        title: "Support Issues",
        subtitle: "Manage support requests",
        color: const Color(0xFF5C4AB5),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AdminSupportScreen(
                userId: userId,
              ),
            ),
          );
        },
      ),
    ),

    const SizedBox(width: 14),

    Expanded(
      child: const SizedBox(),
    ),
  ],
),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 190,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: lightPurple,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
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
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B3D),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.arrow_forward_rounded,
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
}