import 'package:flutter/material.dart';
import 'order_screen.dart';
import 'vendors_screen.dart';
import 'all_documents_screen.dart';

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
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
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
      child: _adminCard(
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

            Row(
              children: [
                Expanded(
                  child: _adminCard(
  icon: Icons.business,
  title: 'Vendors',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorsScreen(
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
          ],
        ),
      ),
    );
  }

  Widget _adminCard({
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