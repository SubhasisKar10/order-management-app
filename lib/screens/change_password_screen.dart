import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';


class ChangePasswordScreen extends StatefulWidget {

  final String userId;
final String role;
final String vendorName;

const ChangePasswordScreen({
  super.key,
  required this.userId,
  required this.role,
  required this.vendorName,
});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {

  final ApiService apiService = ApiService();

  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  bool loading = false;

  Future<void> savePassword() async {

    if (newController.text != confirmController.text) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Passwords do not match"),
        ),

      );

      return;

    }

    setState(() {
      loading = true;
    });

    final result = await apiService.changePassword(

      userId: widget.userId,

      currentPassword:
          currentController.text.trim(),

      newPassword:
          newController.text.trim(),

    );

    setState(() {
      loading = false;
    });

  if (!mounted) return;

if (result["success"] == true) {

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result["message"]),
    ),
  );

  if (widget.role == "Admin") {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboardScreen(
          userId: widget.userId,
          role: widget.role,
        ),
      ),
    );

  } else {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(
  userId: widget.userId,
  vendorName: widget.vendorName,
  role: widget.role,
),
      ),
    );

  }

} else {

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result["message"]),
    ),
  );

}

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Change Password"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: currentController,
              decoration: const InputDecoration(
                labelText: "Current Password",
              ),
              obscureText: true,
            ),

            const SizedBox(height: 15),

            TextField(
              controller: newController,
              decoration: const InputDecoration(
                labelText: "New Password",
              ),
              obscureText: true,
            ),

            const SizedBox(height: 15),

            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                labelText: "Confirm Password",
              ),
              obscureText: true,
            ),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed:
                    loading ? null : savePassword,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("CHANGE PASSWORD"),

              ),

            )

          ],

        ),

      ),

    );

  }

}