import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  final FlutterSecureStorage _secureStorage =
    const FlutterSecureStorage();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

@override
void initState() {
  super.initState();
  _loadSavedLogin();
}

Future<void> _loadSavedLogin() async {
  try {
    final rememberMe =
        await _secureStorage.read(key: 'remember_me');

    if (rememberMe != 'true') {
      return;
    }

    final savedUserId =
        await _secureStorage.read(key: 'user_id');

    final savedPassword =
        await _secureStorage.read(key: 'password');

    if (!mounted) return;

    setState(() {
      _rememberMe = true;

      if (savedUserId != null) {
        _userController.text = savedUserId;
      }

      if (savedPassword != null) {
        _passwordController.text = savedPassword;
      }
    });
  } catch (e) {
    debugPrint("Failed to load saved login: $e");
  }
}

  // ------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------

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
        // --------------------------------------------------------
        // DEVICE AUTHENTICATION
        // --------------------------------------------------------

        final device = await DeviceService.getDeviceInfo();

        debugPrint(
          "DEVICE ID : ${device["deviceId"]}",
        );

        debugPrint(
          "DEVICE NAME : ${device["deviceName"]}",
        );

        final deviceResult =
            await ApiService().registerDevice(
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
                deviceResult["message"] ??
                    "Device rejected",
              ),
            ),
          );

          return;
        }
       // --------------------------------------------------------
// REMEMBER ME
// --------------------------------------------------------

final passwordChanged =
    (result["passwordChanged"] ?? "")
        .toString()
        .toUpperCase();

if (_rememberMe && passwordChanged != "NO") {
  await _secureStorage.write(
    key: 'remember_me',
    value: 'true',
  );

  await _secureStorage.write(
    key: 'user_id',
    value: _userController.text.trim(),
  );

  await _secureStorage.write(
    key: 'password',
    value: _passwordController.text,
  );
} else if (!_rememberMe) {
  await _secureStorage.delete(
    key: 'remember_me',
  );

  await _secureStorage.delete(
    key: 'user_id',
  );

  await _secureStorage.delete(
    key: 'password',
  );
}
        // --------------------------------------------------------
        // PASSWORD STATUS
        // --------------------------------------------------------

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
        }

        // --------------------------------------------------------
        // ADMIN
        // --------------------------------------------------------

        else if (result["role"]
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

        // --------------------------------------------------------
        // NORMAL USER / VENDOR
        // --------------------------------------------------------

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
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // FORGOT PASSWORD
  // ------------------------------------------------------------

 Future<void> _showForgotPasswordDialog() async {
  final userId = _userController.text.trim();

  if (userId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please enter your User ID first.",
        ),
      ),
    );
    return;
  }

  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.lock_reset,
              color: Color(0xFF5E2CA5),
            ),
            SizedBox(width: 10),
            Text("Forgot Password?"),
          ],
        ),
        content: Text(
          "Send a password reset request to the Admin "
          "for User ID:\n\n$userId",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E2CA5),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text("Request Reset"),
          ),
        ],
      );
    },
  );

  if (confirm != true || !mounted) {
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final result =
        await ApiService().requestPasswordReset(
      userId: userId,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result["message"]?.toString() ??
              "Password reset request sent to Admin.",
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Password reset request failed: $e",
        ),
      ),
    );
  }
}

  // ------------------------------------------------------------
  // SUPPORT
  // ------------------------------------------------------------

  void _showSupportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
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
                    color: Color(0xFF4A2085),
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
                    backgroundColor:
                        Color(0xFFF1E9FF),
                    child: Icon(
                      Icons.chat,
                      color: Color(0xFF5E2CA5),
                    ),
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
                    backgroundColor:
                        Color(0xFFF1E9FF),
                    child: Icon(
                      Icons.confirmation_number,
                      color: Color(0xFF5E2CA5),
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

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF5E2CA5);
    const lightPurple = Color(0xFFF4EEFF);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------
            // PURPLE HEADER
            // ----------------------------------------------------

            Container(
              width: double.infinity,
              height: 230,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4B168C),
                    Color(0xFF7B3FC6),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(70),
                  bottomRight: Radius.circular(70),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -50,
                    right: -40,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(
                          0.06,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -70,
                    left: -40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(
                          0.06,
                        ),
                      ),
                    ),
                  ),

                  // Electrical logo
                  Center(
                    child: Container(
                      width: 105,
                      height: 105,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.electrical_services,
                        size: 58,
                        color: purple,
                      ),
                    ),
                  ),

                  // Power-line icons
                  const Positioned(
                    left: 25,
                    bottom: 35,
                    child: Icon(
                      Icons.bolt,
                      size: 42,
                      color: Colors.white24,
                    ),
                  ),

                  const Positioned(
                    right: 25,
                    bottom: 35,
                    child: Icon(
                      Icons.electrical_services,
                      size: 42,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------
            // CONTENT
            // ----------------------------------------------------

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 18),

                    const Text(
                      "ORDER MANAGEMENT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: purple,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 45,
                          height: 1,
                          color: Colors.purple.shade200,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Vendor Portal",
                          style: TextStyle(
                            fontSize: 17,
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 45,
                          height: 1,
                          color: Colors.purple.shade200,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Welcome back 👋",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Sign in to continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ------------------------------------------------
                    // USER ID
                    // ------------------------------------------------

                    _buildInput(
                      controller: _userController,
                      label: "User ID",
                      hint: "Enter your User ID",
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // PASSWORD
                    // ------------------------------------------------

                    _buildInput(
                      controller:
                          _passwordController,
                      label: "Password",
                      hint: "Enter your password",
                      icon: Icons.lock,
                      obscureText:
                          _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: purple,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ------------------------------------------------
                    // REMEMBER + FORGOT
                    // ------------------------------------------------

                    Row(
                      children: [
                        Checkbox(
  value: _rememberMe,
  activeColor: purple,
  onChanged: (value) async {
    final remember = value ?? false;

    setState(() {
      _rememberMe = remember;
    });

    if (!remember) {
      await _secureStorage.delete(
        key: 'remember_me',
      );

      await _secureStorage.delete(
        key: 'user_id',
      );

      await _secureStorage.delete(
        key: 'password',
      );
    }
  },
),

                        const Text(
                          "Remember me",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),

                        const Spacer(),

                        TextButton(
                          onPressed:
                              _showForgotPasswordDialog,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: purple,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------------
                    // LOGIN BUTTON
                    // ------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shadowColor:
                              purple.withOpacity(0.35),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              30,
                            ),
                          ),
                        ),
                        onPressed:
                            isLoading ? null : login,
                        child: isLoading
                            ? const SizedBox(
                                width: 25,
                                height: 25,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "LOGIN",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ------------------------------------------------
                    // SUPPORT
                    // ------------------------------------------------

                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color:
                                Colors.grey.shade300,
                          ),
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          child: Text(
                            "Need Help?",
                            style: TextStyle(
                              color: purple,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color:
                                Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    OutlinedButton.icon(
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor: purple,
                        side: const BorderSide(
                          color: purple,
                          width: 1.5,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 13,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),
                        ),
                      ),
                      onPressed:
                          _showSupportOptions,
                      icon: const Icon(
                        Icons.headset_mic_outlined,
                      ),
                      label: const Text(
                        "Contact Support",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // VERSION
                    // ------------------------------------------------

                   const Text(
                      "Version 1.0.3",
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // INPUT FIELD
  // ------------------------------------------------------------

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    const purple = Color(0xFF5E2CA5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.purple.shade100,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4EEFF),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: purple,
              ),
            ),
          ),
          suffixIcon: suffixIcon,
          labelText: label,
          labelStyle: const TextStyle(
            color: purple,
            fontWeight: FontWeight.bold,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
          ),
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