import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String adminUserId;

  const EditUserScreen({
    super.key,
    required this.user,
    required this.adminUserId,
  });

  @override
  State<EditUserScreen> createState() =>
      _EditUserScreenState();
}

class _EditUserScreenState
    extends State<EditUserScreen> {
final ApiService apiService = ApiService();

List<dynamic> vendors = [];

bool isLoading = true;
  late TextEditingController passwordController;
  late TextEditingController emailController;

  late String selectedVendor;
  late String selectedRole;
  late String selectedStatus;

  @override
  void initState() {
    super.initState();


    passwordController = TextEditingController(
      text: widget.user["Password"]?.toString() ?? "",
    );

    emailController = TextEditingController(
      text: widget.user["E-mail"]?.toString() ?? "",
    );

    selectedVendor =
        widget.user["Vendor"]?.toString() ?? "";

   selectedRole =
    (widget.user["Role"] ?? "User")
        .toString()
        .toUpperCase() == "ADMIN"
    ? "Admin"
    : "User";

   selectedStatus =
    (widget.user["Active"] ?? "YES")
        .toString()
        .toUpperCase();
 	loadVendors();
  }
Future<void> loadVendors() async {
  try {
    final result = await apiService.getVendors(
      userId: widget.adminUserId,
    );

    if (!mounted) return;

    if (result["success"] == true) {
      setState(() {
        vendors = result["vendors"] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
  }
}
Future<void> updateUser() async {

  try {

    final result = await apiService.updateUser(

      adminUserId: widget.adminUserId,

      editUserId:
          widget.user["UserID"].toString(),

      password:
          passwordController.text.trim(),

      vendor: selectedVendor,

      role: selectedRole,

      active: selectedStatus,

      email: emailController.text.trim(),

    );

    if (!mounted) return;

    if (result["success"] == true) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(result["message"]),
        ),

      );

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(result["message"]),
        ),

      );

    }

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(
        content: Text(e.toString()),
      ),

    );

  }
}
Future<void> resetPassword() async {

  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Reset Password"),
      content: const Text(
        "Reset this user's password?",
      ),
      actions: [

        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Reset"),
        ),

      ],
    ),
  );

  if (confirm != true) return;

 final result = await apiService.resetPassword(
  adminUserId: widget.adminUserId,
  editUserId: widget.user["UserID"].toString(),
);

  if (!mounted) return;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Password Reset"),
      content: Text(
        "Temporary Password:\n\n${result["tempPassword"]}",
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
 	 Navigator.pop(context);      // Close dialog
  	Navigator.pop(context, true); // Close Edit User screen
	},
          child: const Text("OK"),
        )
      ],
    ),
  );

}
  @override
  Widget build(BuildContext context) {
if (isLoading) {

  return const Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );

}
    return Scaffold(

      appBar: AppBar(
        title: Text(
          widget.user["UserID"].toString(),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(

          children: [

            Text(
              "User ID",
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            Text(
              widget.user["UserID"],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(

  value: selectedVendor,

  decoration: const InputDecoration(
    labelText: "Vendor",
    border: OutlineInputBorder(),
  ),

  items: vendors.map((vendor) {

    return DropdownMenuItem<String>(
      value: vendor["Vendor"].toString(),
      child: Text(
        vendor["VendorName"].toString(),
      ),
    );

  }).toList(),

  onChanged: (value) {

    setState(() {
      selectedVendor = value!;
    });

  },

),

            const SizedBox(height: 20),

           DropdownButtonFormField<String>(

  value: selectedRole,

  decoration: const InputDecoration(
    labelText: "Role",
    border: OutlineInputBorder(),
  ),

  items: const [

    DropdownMenuItem(
      value: "User",
      child: Text("User"),
    ),

    DropdownMenuItem(
      value: "Admin",
      child: Text("Admin"),
    ),

  ],

  onChanged: (value) {

    setState(() {
      selectedRole = value!;
    });

  },

),

            const SizedBox(height: 20),

           DropdownButtonFormField<String>(

  value: selectedStatus,

  decoration: const InputDecoration(
    labelText: "Status",
    border: OutlineInputBorder(),
  ),

  items: const [

    DropdownMenuItem(
      value: "YES",
      child: Text("Active"),
    ),

    DropdownMenuItem(
      value: "NO",
      child: Text("Inactive"),
    ),

  ],

  onChanged: (value) {

    setState(() {
      selectedStatus = value!;
    });

  },

),

            const SizedBox(height: 30),

            SizedBox(
              height: 50,
              child: ElevatedButton(
               onPressed: updateUser,
                child: const Text(
                  "SAVE CHANGES",
                ),
              ),
            ),
const SizedBox(height: 15),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.lock_reset),
    label: const Text("Reset Password"),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
    ),
    onPressed: resetPassword,
  ),
),
          ],
        ),
      ),
    );
  }
}