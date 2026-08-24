import 'package:flutter/material.dart';

import '../services/api_service.dart';

class CreateSupportTicketScreen extends StatefulWidget {
  final String userId;

  const CreateSupportTicketScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CreateSupportTicketScreen> createState() =>
      _CreateSupportTicketScreenState();
}

class _CreateSupportTicketScreenState
    extends State<CreateSupportTicketScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController descriptionController =
      TextEditingController();

  bool isLoading = false;

  String selectedCategory = "Login Related";

  final List<String> categories = const [
    "Login Related",
    "System Related",
    "Order Related",
    "User Related",
    "Vendor Related",
    "Others",
  ];

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    final description =
        descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please describe your issue.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result =
          await apiService.createSupportTicket(
        userId: widget.userId,
        category: selectedCategory,
        description: description,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (result["success"] == true) {
        final ticketId =
            result["ticketId"]?.toString() ?? "";

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Issue Submitted",
                    ),
                  ),
                ],
              ),
              content: Text(
                ticketId.isEmpty
                    ? "Your support issue has been submitted successfully."
                    : "Your support issue has been submitted successfully.\n\n"
                      "Ticket ID:\n$ticketId\n\n"
                      "Status: Open",
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );

        if (!mounted) return;

        Navigator.pop(
          context,
          true,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"]?.toString() ??
                  "Unable to create support ticket.",
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
            "Unable to create support ticket: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF5E2CA5);
    const darkPurple = Color(0xFF4B168C);
    const pageBackground = Color(0xFFF9F7FC);

    return Scaffold(
      backgroundColor: pageBackground,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: darkPurple,
        title: const Text(
          "Raise New Issue",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      darkPurple,
                      Color(0xFF7B3FC6),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          Colors.white24,
                      child: Icon(
                        Icons.support_agent,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Need assistance?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Tell us about the problem and our team will help you.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Issue Category",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        Colors.purple.shade100,
                  ),
                ),
                child:
                    DropdownButtonHideUnderline(
                  child:
                      DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: categories
                        .map(
                          (category) =>
                              DropdownMenuItem<
                                  String>(
                            value: category,
                            child:
                                Text(category),
                          ),
                        )
                        .toList(),
                    onChanged:
                        isLoading
                            ? null
                            : (value) {
                                if (value ==
                                    null) {
                                  return;
                                }

                                setState(() {
                                  selectedCategory =
                                      value;
                                });
                              },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Describe Your Issue",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller:
                    descriptionController,
                enabled: !isLoading,
                maxLines: 7,
                maxLength: 1000,
                textCapitalization:
                    TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText:
                      "Please describe your problem clearly...",
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    borderSide: BorderSide(
                      color:
                          Colors.purple.shade100,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    borderSide:
                        const BorderSide(
                      color: purple,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),
                    ),
                  ),
                  onPressed:
                      isLoading
                          ? null
                          : _submitTicket,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.send,
                        ),
                  label: Text(
                    isLoading
                        ? "Submitting..."
                        : "SUBMIT ISSUE",
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}