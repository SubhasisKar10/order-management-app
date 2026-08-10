import 'package:flutter/material.dart';
import 'order_screen.dart';
import 'vendor_management_screen.dart';
import 'all_documents_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'add_user_screen.dart';
import 'pending_devices_screen.dart';
import 'audit_log_screen.dart';
import '../utils/app_colors.dart';
import 'support_screen.dart';
import 'admin_support_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String userId;
  final String role;

  const AdminDashboardScreen({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text("Admin Dashboard"),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      tooltip: "Logout",
      onPressed: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Logout"),
            content: const Text(
              "Are you sure you want to logout?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Logout"),
              ),
            ],
          ),
        );

        if (shouldLogout != true || !context.mounted) return;

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Admin',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text('User ID: $userId'),

            Text('Role: $role'),

            const SizedBox(height: 30),

            const Text(
              'Administration',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

           Row(
  children: [
    Expanded(
      child: _adminCard(
        icon: Icons.shopping_cart,
        title: 'DTR PO',
color: AppColors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrdersScreen(
                userId: userId,
                orderType: 'DTR_PO',
              ),
            ),
          );
        },
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: _adminCard(
        icon: Icons.assignment,
color: AppColors.green,
        title: 'E-Office Orders',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrdersScreen(
                userId: userId,
                orderType: 'E_OFFICE',
              ),
            ),
          );
        },
      ),
    ),
  ],
),

            Row(
              children: [
                Expanded(
                  child: _adminCard(
  icon: Icons.business,
  title: 'Vendors',
color: AppColors.orange,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorManagementScreen(
  userId: userId,
),
      ),
    );
  },
),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _adminCard(
  icon: Icons.folder,
  title: 'Documents',
color: AppColors.purple,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllDocumentsScreen(
          userId: userId,
        ),
      ),
    );
  },
),
                ),
              ],
            ),
const SizedBox(height: 12),

Row(
  children: [

    Expanded(
      child: _adminCard(
        icon: Icons.phonelink_lock,
        title: "Pending Devices",
color: AppColors.red,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PendingDevicesScreen(
                adminUserId: userId,
              ),
            ),
          );
        },
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: _adminCard(
        icon: Icons.history,
        title: "Audit Log",
color: AppColors.teal,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AuditLogScreen(
                userId: userId,
              ),
            ),
          );
        },
      ),
    ),

  ],
),
const SizedBox(height: 12),

Row(
  children: [
    Expanded(
      child: _adminCard(
        icon: Icons.support_agent,
        title: 'Support & Help',
        color: Colors.teal,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupportScreen(
                userId: userId,
              ),
            ),
          );
        },
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: _adminCard(
        icon: Icons.confirmation_number,
        title: 'Support Issues',
        color: AppColors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminSupportScreen(
                userId: userId,
              ),
            ),
          );
        },
      ),
    ),
  ],
),
    const SizedBox(width: 12),

    
          ],
        ),
      ),
    );
  }

  Widget _adminCard({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  required Color color,
}) {
  return Card(
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: color,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              color: Colors.white,
              size: 42,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

          ],
        ),
      ),
    ),
  );
}
}