import 'package:flutter/material.dart';
import 'add_user_screen.dart';
import 'vendor_list_screen.dart';
import 'add_vendor_screen.dart';
import 'users_screen.dart';

class VendorManagementScreen extends StatelessWidget {
  final String userId;

  const VendorManagementScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Management"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _menuCard(
            context,
            icon: Icons.person_add,
            title: "Add User",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddUserScreen(
  userId: userId,
),
                ),
              );
            },
          ),

          _menuCard(
  context,
  icon: Icons.people,
  title: "Users",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UsersScreen(
          userId: userId,
        ),
      ),
    );
  },
),

          _menuCard(
  context,
  icon: Icons.add_business,
  title: "Add Vendor",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddVendorScreen(
          userId: userId,
        ),
      ),
    );
  },
),

          _menuCard(
            context,
            icon: Icons.business,
            title: "Vendor List",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VendorListScreen(
                    userId: userId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue,
          size: 32,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}