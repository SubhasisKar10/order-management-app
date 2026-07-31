import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UsersScreen extends StatefulWidget {
  final String userId;

  const UsersScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = true;
  String? errorMessage;
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final result = await apiService.getUsers(
        userId: widget.userId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          users = result['users'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              result['message'] ?? 'Failed to load users';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      );
    }

    if (users.isEmpty) {
      return const Center(
        child: Text('No users found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user =
            users[index] as Map<String, dynamic>;

        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(
    Map<String, dynamic> user,
  ) {
    final userId =
        user['UserID']?.toString() ?? '';

    final role =
        user['Role']?.toString() ?? '';

    final active =
        user['Active']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          role == 'Admin'
              ? Icons.admin_panel_settings
              : Icons.person,
        ),
        title: Text(userId),
        subtitle: Text('Role: $role'),
        trailing: Chip(
          label: Text(active),
        ),
      ),
    );
  }
}