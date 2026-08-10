import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginSupportScreen extends StatefulWidget {
  const LoginSupportScreen({super.key});

  @override
  State<LoginSupportScreen> createState() => _LoginSupportScreenState();
}

class _LoginSupportScreenState extends State<LoginSupportScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController userIdController =
      TextEditingController();

  final TextEditingController vendorController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  String selectedCategory = "Cannot login";

  bool isSubmitting = false;

  final List<String> categories = [
    "Cannot login",
    "Forgot password",
    "Account locked",
    "Device approval problem",
    "Other",
  ];

  Future<void> submitTicket() async {
    final description =
        descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please describe your problem.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final result =
          await apiService.createLoginSupportTicket(
        userId: userIdController.text.trim(),
        vendor: vendorController.text.trim(),
        category: selectedCategory,
        description: description,
      );

      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      if (result["success"] == true) {
        final ticketId =
            result["ticketId"]?.toString() ?? "";

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8),
                  Text("Issue Submitted"),
                ],
              ),
              content: Text(
                "Your support issue has been submitted successfully.\n\n"
                "Ticket ID:\n"
                "$ticketId\n\n"
                "Please keep this Ticket ID for future reference.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );

        if (!mounted) return;

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"]?.toString() ??
                  "Unable to submit support issue.",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to submit issue: $e",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    userIdController.dispose();
    vendorController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Support"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.support_agent,
              size: 60,
            ),

            const SizedBox(height: 12),

            const Text(
              "Raise a Login Support Issue",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Use this form if you are unable to login "
              "to the application.",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: userIdController,
              decoration: InputDecoration(
                labelText: "User ID",
                hintText: "Enter your User ID",
                prefixIcon:
                    const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: vendorController,
              decoration: InputDecoration(
                labelText: "Vendor / Company",
                hintText:
                    "Enter your vendor name",
                prefixIcon:
                    const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: "Issue Category",
                prefixIcon:
                    const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              items: categories.map(
                (category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                },
              ).toList(),
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        selectedCategory =
                            value;
                      });
                    },
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  descriptionController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: "Describe your problem",
                hintText:
                    "Please explain what happens when you try to login...",
                alignLabelWithHint: true,
                prefixIcon:
                    const Padding(
                  padding: EdgeInsets.only(
                    bottom: 90,
                  ),
                  child: Icon(
                    Icons.description,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                    isSubmitting
                        ? null
                        : submitTicket,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),
                label: Text(
                  isSubmitting
                      ? "Submitting..."
                      : "SUBMIT ISSUE",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                "Support tickets are normally reviewed by Admin.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}