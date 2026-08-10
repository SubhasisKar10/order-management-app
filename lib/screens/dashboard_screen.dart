import 'package:flutter/material.dart';
import 'order_screen.dart';
import 'support_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Order Management',
  ),
  actions: [

    IconButton(
      icon: const Icon(
        Icons.notifications,
      ),
      tooltip: 'Notifications',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                NotificationsScreen(
              userId: userId,
            ),
          ),
        );
      },
    ),

    IconButton(
      icon: const Icon(
        Icons.logout,
      ),
      tooltip: 'Logout',
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
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $vendorName',
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
              'Dashboard',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _dashboardCard(
                    icon: Icons.shopping_cart,
                    title: 'DTR PO Orders',
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
                  child: _dashboardCard(
                    icon: Icons.assignment,
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

        const SizedBox(height: 12),

        _dashboardCard(
          icon: Icons.support_agent,
          title: 'Support & Help',
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
      ],
    ),
  ),
);
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}