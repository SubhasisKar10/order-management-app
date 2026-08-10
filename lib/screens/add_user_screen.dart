import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddUserScreen extends StatefulWidget {
  final String userId;

  const AddUserScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState
    extends State<AddUserScreen> {

final ApiService apiService = ApiService();


  final userIdController =
      TextEditingController();

  final passwordController =
      TextEditingController();
final nameController = TextEditingController();

  String selectedRole = "User";
List<dynamic> vendors = [];

String? selectedVendor;

bool isLoading = true;
@override
void initState() {
  super.initState();
  loadVendors();
}
Future<void> loadVendors() async {
  try {
print("Admin UserID = ${widget.userId}");
    final result = await apiService.getVendorMaster(
  userId: widget.userId,
);
print(result);
    if (!mounted) return;

    if (result["success"] == true) {
      setState(() {
        vendors = result["vendors"] ?? [];

        if (vendors.isNotEmpty) {
          selectedVendor =
              vendors.first["Vendor"].toString();
	print(vendors);
        }

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
Future<void> createUser() async {
if (userIdController.text.trim().isEmpty ||
    nameController.text.trim().isEmpty ||
    passwordController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please fill all fields"),
      ),
    );
    return;
  }

  try {
  final result = await apiService.addUser(
  adminUserId: widget.userId,
  userId: userIdController.text.trim(),
  name: nameController.text.trim(),
  password: passwordController.text.trim(),
  role: selectedRole,
  vendor: selectedVendor ?? "",
  email: "",
);

    if (!mounted) return;

    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]),
        ),
      );

      userIdController.clear();
passwordController.clear();

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
        title: const Text("Add User"),
      ),
      body: SingleChildScrollView(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [

      TextField(
        controller: userIdController,
        decoration: const InputDecoration(
          labelText: "User ID",
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.person),
        ),
      ),

      const SizedBox(height: 20),
TextField(
  controller: nameController,
  decoration: const InputDecoration(
    labelText: "Name",
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.badge),
  ),
),

const SizedBox(height: 20),

      TextField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: "Password",
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.lock),
        ),
      ),

      const SizedBox(height: 20),

      DropdownButtonFormField<String>(
        value: selectedRole,
        decoration: const InputDecoration(
          labelText: "Role",
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.admin_panel_settings),
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
if (selectedRole == "User") ...[
  const SizedBox(height: 20),

  DropdownButtonFormField<String>(
    value: selectedVendor,
    decoration: const InputDecoration(
      labelText: "Vendor",
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.business),
    ),
    items: vendors.map((vendor) {
      return DropdownMenuItem<String>(
        value: vendor["Vendor"].toString(),
child: Text(
  "${vendor["Vendor"]} - ${vendor["VendorName"]}",
),
      );
    }).toList(),
    onChanged: (value) {
      setState(() {
        selectedVendor = value;
      });
    },
  ),
],
 
      const SizedBox(height: 30),

      SizedBox(
        height: 50,
        child: ElevatedButton.icon(
         onPressed: createUser,
          icon: const Icon(Icons.person_add),
          label: const Text(
            "CREATE USER",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),

    ],
  ),
),
    );
  }
}