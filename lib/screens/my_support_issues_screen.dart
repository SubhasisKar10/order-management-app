import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MySupportIssuesScreen extends StatefulWidget {
  final String userId;

  const MySupportIssuesScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MySupportIssuesScreen> createState() =>
      _MySupportIssuesScreenState();
}

class _MySupportIssuesScreenState
    extends State<MySupportIssuesScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> tickets = [];

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  Future<void> loadTickets() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await apiService.getSupportTickets(
        userId: widget.userId,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        final data = result["tickets"] ?? [];

        setState(() {
          tickets = List<Map<String, dynamic>>.from(
            data,
          );
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              result["message"]?.toString() ??
              "Unable to load support issues";

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

  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
  }) async {
    try {
      final result =
          await apiService.updateUserSupportTicketStatus(
        userId: widget.userId,
        ticketId: ticketId,
        status: status,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == "Closed"
                  ? "Support issue closed"
                  : "Support issue re-opened",
            ),
          ),
        );

        await loadTickets();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"]?.toString() ??
                  "Unable to update support issue",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error updating support issue: $e",
          ),
        ),
      );
    }
  }

  Future<void> confirmStatusChange({
    required String ticketId,
    required String newStatus,
  }) async {
    final isClosing = newStatus == "Closed";

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isClosing
                ? "Close Support Issue?"
                : "Re-open Support Issue?",
          ),
          content: Text(
            isClosing
                ? "Are you sure you want to close this support issue?"
                : "Are you sure you want to re-open this support issue?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                isClosing ? "Close" : "Re-open",
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await updateTicketStatus(
      ticketId: ticketId,
      status: newStatus,
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Open":
        return Colors.blue;

      case "In Progress":
        return Colors.orange;

      case "Resolved":
        return Colors.green;

      case "Closed":
        return Colors.grey;

      default:
        return Colors.grey;
    }
  }

  Widget buildStatusChip(String status) {
    return Chip(
      label: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: getStatusColor(status),
    );
  }

  void showTicketDetails(
    Map<String, dynamic> ticket,
  ) {
    final ticketId =
        ticket["TicketID"]?.toString() ?? "";

    final category =
        ticket["Category"]?.toString() ?? "";

    final description =
        ticket["Description"]?.toString() ?? "";

    final status =
        ticket["Status"]?.toString() ?? "Open";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Support Issue",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Ticket ID",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(ticketId),

                  const SizedBox(height: 16),

                  const Text(
                    "Category",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(category),

                  const SizedBox(height: 16),

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(description),

                  const SizedBox(height: 16),

                  const Text(
                    "Status",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  buildStatusChip(status),

                  const SizedBox(height: 24),

                  // RESOLVED
                  if (status == "Resolved") ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.check_circle,
                        ),
                        label: const Text(
                          "Close Issue",
                        ),
                        onPressed: () async {
                          Navigator.pop(sheetContext);

                          await confirmStatusChange(
                            ticketId: ticketId,
                            newStatus: "Closed",
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.refresh,
                        ),
                        label: const Text(
                          "Re-open Issue",
                        ),
                        onPressed: () async {
                          Navigator.pop(sheetContext);

                          await confirmStatusChange(
                            ticketId: ticketId,
                            newStatus: "Open",
                          );
                        },
                      ),
                    ),
                  ],

                  // CLOSED
                  if (status == "Closed")
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.refresh,
                        ),
                        label: const Text(
                          "Re-open Issue",
                        ),
                        onPressed: () async {
                          Navigator.pop(sheetContext);

                          await confirmStatusChange(
                            ticketId: ticketId,
                            newStatus: "Open",
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTicketCard(
    Map<String, dynamic> ticket,
  ) {
    final ticketId =
        ticket["TicketID"]?.toString() ?? "";

    final category =
        ticket["Category"]?.toString() ?? "";

    final description =
        ticket["Description"]?.toString() ?? "";

    final status =
        ticket["Status"]?.toString() ?? "Open";

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: CircleAvatar(
          child: Icon(
            status == "Closed"
                ? Icons.check
                : Icons.support_agent,
          ),
        ),

        title: Text(
          ticketId,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 8,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              buildStatusChip(status),
            ],
          ),
        ),

        onTap: () {
          showTicketDetails(ticket);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Support Issues",
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Text(
                      errorMessage!,
                      textAlign:
                          TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              : tickets.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Icon(
                            Icons
                                .confirmation_number_outlined,
                            size: 70,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No support issues found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadTickets,
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.all(
                          12,
                        ),
                        itemCount:
                            tickets.length,
                        itemBuilder:
                            (context, index) {
                          return buildTicketCard(
                            tickets[index],
                          );
                        },
                      ),
                    ),
    );
  }
}