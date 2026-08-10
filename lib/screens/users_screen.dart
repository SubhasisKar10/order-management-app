import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter/services.dart';
import 'edit_user_screen.dart';

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

final TextEditingController searchController =
    TextEditingController();

List<dynamic> users = [];
List<dynamic> filteredUsers = [];

  @override
void initState() {
  super.initState();

  print("===== USERS SCREEN OPENED =====");

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
filteredUsers = List.from(users);
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
void filterUsers(String value) {

  setState(() {

    if (value.trim().isEmpty) {

      filteredUsers = List.from(users);

      return;

    }

    final query = value.toLowerCase();

    filteredUsers = users.where((user) {
final userId =
    user["UserID"].toString().toLowerCase();

final name =
    user["Name"].toString().toLowerCase();

final vendor =
    user["Vendor"].toString().toLowerCase();

final email =
    user["E-mail"].toString().toLowerCase();

return userId.contains(query) ||
       name.contains(query) ||
       vendor.contains(query) ||
       email.contains(query);

    }).toList();

  });

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        "Users",
        style: TextStyle(fontSize: 18),
      ),

      Text(
        "${filteredUsers.length} Registered",
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

    ],
  ),
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

   return Column(

  children: [

    Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: searchController,
        onChanged: filterUsers,
        decoration: InputDecoration(
          hintText: "Search User ID / Name / Vendor / Email",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),
    ),

    Expanded(
      child: RefreshIndicator(
        onRefresh: loadUsers,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {

            final user =
                filteredUsers[index]
                    as Map<String, dynamic>;

            return _buildUserCard(user);

          },
        ),
      ),
    ),

  ],

);
  }

  Widget _buildUserCard(
  Map<String, dynamic> user,
) {

  final userId =
      user["UserID"]?.toString() ?? "";

  final vendor =
      user["Vendor"]?.toString() ?? "";

  final role =
      user["Role"]?.toString() ?? "";

  final active =
      user["Active"]?.toString() ?? "";

  final email =
      user["E-mail"]?.toString() ?? "";

  return Card(

    margin: const EdgeInsets.only(bottom: 12),

    child: ListTile(

      leading: CircleAvatar(
        child: Icon(
          role == "Admin"
              ? Icons.admin_panel_settings
              : Icons.person,
        ),
      ),

      title: Text(
        userId,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text("Vendor : $vendor"),
            Text("Role : $role"),
            Text(email),

            const SizedBox(height: 6),

            Chip(
              backgroundColor:
                  active == "YES"
                      ? Colors.green.shade100
                      : Colors.red.shade100,

              label: Text(
                active,
                style: TextStyle(
                  color:
                      active == "YES"
                          ? Colors.green
                          : Colors.red,
                ),
              ),
            ),

          ],
        ),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
      ),

     onTap: () async {

  final updated = await Navigator.push(

    context,

    MaterialPageRoute(

      builder: (_) => EditUserScreen(

        user: user,

        adminUserId: widget.userId,

      ),

    ),

  );

  if (updated == true) {

    loadUsers();

  }

},

      onLongPress: () async {

        await Clipboard.setData(
          ClipboardData(text: userId),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text("User ID copied"),
            duration: Duration(seconds: 1),
          ),
        );

      },

    ),

  );

}
}