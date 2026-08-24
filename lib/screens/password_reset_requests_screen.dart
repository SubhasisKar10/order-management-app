import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'edit_user_screen.dart';

class PasswordResetRequestsScreen extends StatefulWidget {
  final String adminUserId;

  const PasswordResetRequestsScreen({
    super.key,
    required this.adminUserId,
  });

  @override
  State<PasswordResetRequestsScreen> createState() =>
      _PasswordResetRequestsScreenState();
}

class _PasswordResetRequestsScreenState
    extends State<PasswordResetRequestsScreen> {

  bool isLoading = true;

  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {

    setState(() {
      isLoading = true;
    });

    try {

      final result =
          await ApiService().getPasswordResetRequests(
        adminUserId: widget.adminUserId,
      );

      if (!mounted) return;

      if (result["success"] == true) {

        final data = result["requests"];

        if (data is List) {

          requests = data
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList();

        } else {

          requests = [];

        }

      } else {

        requests = [];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"] ??
                  "Unable to load password reset requests.",
            ),
          ),
        );
      }

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load requests: $e",
          ),
        ),
      );

    } finally {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Password Reset Requests",
        ),

        actions: [

          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: "Refresh",
            onPressed: isLoading
                ? null
                : _loadRequests,
          ),

        ],
      ),

      body: isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : requests.isEmpty

              ? _emptyState()

              : RefreshIndicator(
                  onRefresh: _loadRequests,

                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),

                    itemCount: requests.length,

                    itemBuilder: (
                      context,
                      index,
                    ) {

                      final request =
                          requests[index];

                      return _requestCard(
                        request,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _emptyState() {

    return Center(

      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              Icons.lock_open,
              size: 70,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 18),

            const Text(
              "No Password Reset Requests",
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "There are currently no pending "
              "password reset requests.",
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestCard(
    Map<String, dynamic> request,
  ) {

    final userId =
        request["UserID"]?.toString() ?? "";

    final name =
        request["Name"]?.toString() ?? "";

    final vendor =
        request["Vendor"]?.toString() ?? "";

    final requestedOn =
        request["RequestedOn"]?.toString() ?? "";

    return Card(

      elevation: 5,

      margin: const EdgeInsets.only(
        bottom: 14,
      ),

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Padding(

        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
              children: [

                Container(
                  padding:
                      const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: AppColors.purple
                        .withOpacity(0.12),

                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: Icon(
                    Icons.lock_reset,
                    color:
                        AppColors.purple,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        name.isEmpty
                            ? userId
                            : name,

                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "User ID: $userId",
                        style:
                            TextStyle(
                          color: Colors
                              .grey
                              .shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.orange
                        .withOpacity(0.15),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: const Text(
                    "PENDING",

                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 10),

            if (vendor.isNotEmpty)
              Row(
                children: [

                  const Icon(
                    Icons.business,
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      "Vendor: $vendor",
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),

            Row(
              children: [

                const Icon(
                  Icons.access_time,
                  size: 20,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    "Requested: $requestedOn",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(

                icon: const Icon(
                  Icons.lock_reset,
                ),

                label: const Text(
                  "RESET PASSWORD",
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.purple,
                  foregroundColor:
                      Colors.white,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 13,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),

                onPressed: () {
                  _openResetScreen(
                    request,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openResetScreen(
  Map<String, dynamic> request,
) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditUserScreen(
        user: request,
        adminUserId: widget.adminUserId,
      ),
    ),
  );

  if (!mounted) return;

  if (result == true) {
    await _loadRequests();
  }
}
}