import 'dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {

    if (_userController.text.isEmpty ||
        _passwordController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter User ID and Password"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final result = await ApiService().login(
        userId: _userController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        isLoading = false;
      });

    if (result['success'] == true) {
  if (!mounted) return;

  final role = result['role'];

  if (role == 'Admin') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AdminDashboardScreen(
          userId: result['userId'],
          role: result['role'],
        ),
      ),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          userId: result['userId'],
          vendorName: result['vendorName'],
          role: result['role'],
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

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Vendor Login"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 40),

            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "User ID",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                onPressed: isLoading ? null : login,

                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "LOGIN",
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