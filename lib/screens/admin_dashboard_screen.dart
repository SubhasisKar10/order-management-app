import '../utils/app_colors.dart';
import 'package:flutter/material.dart';

import 'order_screen.dart';
import 'all_documents_screen.dart';
import 'login_screen.dart';
import 'admin_control_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String userId;
  final String role;

  const AdminDashboardScreen({
    super.key,
    required this.userId,
    required this.role,
  });

  static const Color purple = Color(0xFF5E2CA5);
  static const Color darkPurple = Color(0xFF4B168C);
  static const Color lightPurple = Color(0xFFF4EEFF);
  static const Color pageBackground = Color(0xFFF9F7FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: darkPurple,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text("Logout"),
                  content: const Text(
                    "Are you sure you want to logout?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (shouldLogout != true || !context.mounted) {
                return;
              }

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // WELCOME CARD
              // --------------------------------------------------

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
                      color: purple.withOpacity(0.22),
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

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome, Admin",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "User ID: $userId",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            "Role: $role",
                            style: const TextStyle(
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
                "Manage orders, documents and administration",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

             // --------------------------------------------------
// DTR PO + E-OFFICE
// --------------------------------------------------

Row(
  children: [
    Expanded(
      child: _dashboardCard(
        icon: Icons.shopping_cart,
        title: "DTR PO",
        subtitle: "DTR purchase orders",
        color: const Color(0xFF6C35B8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrdersScreen(
                userId: userId,
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
        icon: Icons.assignment,
        title: "E-Office Orders",
        subtitle: "E-Office purchase orders",
        color: const Color(0xFF8A4BC4),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrdersScreen(
                userId: userId,
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

// --------------------------------------------------
// OTHER PO
// --------------------------------------------------

_dashboardCard(
  icon: Icons.inventory_2_outlined,
  title: "Other PO",
  subtitle: "Other purchase orders",
  color: const Color(0xFF5E2CA5),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrdersScreen(
          userId: userId,
          orderType: "OTHER_PO",
        ),
      ),
    );
  },
),

const SizedBox(height: 14),

// --------------------------------------------------
// ADMIN CONTROL + DOCUMENTS
// --------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _dashboardCard(
                      icon: Icons.admin_panel_settings,
                      title: "Admin Control",
                      subtitle: "Users, devices & support",
                      color: const Color(0xFF5E2CA5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminControlScreen(
                              userId: userId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _dashboardCard(
                      icon: Icons.folder_rounded,
                      title: "Documents",
                      subtitle: "Documents & files",
                      color: const Color(0xFF7437A8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AllDocumentsScreen(
                              userId: userId,
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
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 195,
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