import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_support_screen.dart';

import 'dashboard_screen.dart';
import '../services/api_service.dart';
import 'admin_dashboard_screen.dart';
import 'change_password_screen.dart';
import '../services/device_service.dart';

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

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (result["success"] == true) {
        // Get device information
        final device = await DeviceService.getDeviceInfo();

        print("DEVICE ID : ${device["deviceId"]}");
        print("DEVICE NAME : ${device["deviceName"]}");

        // Register device
        final deviceResult = await ApiService().registerDevice(
          userId: result["userId"].toString(),
          deviceId: device["deviceId"]!,
          deviceName: device["deviceName"]!,
        );

        // Device waiting for approval
        if (deviceResult["status"] == "Pending") {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Your device is waiting for Admin approval.",
              ),
            ),
          );

          return;
        }

        // Device rejected
        if (deviceResult["status"] == "Rejected") {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                deviceResult["message"] ?? "Device rejected",
              ),
            ),
          );

          return;
        }

        // Device approved → check password status
        if ((result["passwordChanged"] ?? "")
                .toString()
                .toUpperCase() ==
            "NO") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ChangePasswordScreen(
                userId: result["userId"].toString(),
                role: result["role"].toString(),
                vendorName:
                    result["vendorName"].toString(),
              ),
            ),
          );
        } else {
          // Admin
          if (result["role"]
                  .toString()
                  .toUpperCase() ==
              "ADMIN") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AdminDashboardScreen(
                  userId:
                      result["userId"].toString(),
                  role:
                      result["role"].toString(),
                ),
              ),
            );
          }

          // Vendor/user
          else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardScreen(
                  userId:
                      result["userId"].toString(),
                  vendorName:
                      result["vendorName"].toString(),
                  role:
                      result["role"].toString(),
                ),
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"] ??
                  "Login failed",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

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

  void _showSupportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Need Help?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Choose how you want to get help.",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.chat),
                  ),
                  title: const Text(
                    "WhatsApp Discussion",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    "Ask questions and discuss common issues",
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () async {
                    Navigator.pop(context);

                    final uri = Uri.parse(
                      "https://chat.whatsapp.com/"
                      "L54GjzhkDmCAhrgTgtb1Vg",
                    );

                    await launchUrl(
                      uri,
                      mode:
                          LaunchMode.externalApplication,
                    );
                  },
                ),

                const SizedBox(height: 8),

                ListTile(
  leading: const CircleAvatar(
    child: Icon(
      Icons.confirmation_number,
    ),
  ),
  title: const Text(
    "Login Support",
    style: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
  subtitle: const Text(
    "Having trouble logging into the app?",
  ),
  trailing: const Icon(
    Icons.arrow_forward_ios,
    size: 18,
  ),
  onTap: () {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginSupportScreen(),
      ),
    );
  },
),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
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
                onPressed:
                    isLoading ? null : login,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "LOGIN",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 18),

            TextButton.icon(
              onPressed: isLoading
                  ? null
                  : _showSupportOptions,
              icon: const Icon(
                Icons.help_outline,
              ),
              label: const Text(
                "Need Help?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}