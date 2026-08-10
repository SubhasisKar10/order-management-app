import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminSupportScreen extends StatefulWidget {
  final String userId;

  const AdminSupportScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AdminSupportScreen> createState() =>
      _AdminSupportScreenState();
}

class _AdminSupportScreenState
    extends State<AdminSupportScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> tickets = [];

  @override
  void initState() {
    super.initState();
    loadSupportTickets();
  }

  Future<void> loadSupportTickets() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result =
          await apiService.getSupportTickets(
        userId: widget.userId,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        final data = result["tickets"];

        setState(() {
          tickets = data is List
              ? data
                  .map(
                    (item) => Map<String, dynamic>.from(
                      item as Map,
                    ),
                  )
                  .toList()
              : [];

          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              result["message"]?.toString() ??
                  "Unable to load support tickets.";
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

  String valueOf(
    Map<String, dynamic> ticket,
    String key,
  ) {
    return ticket[key]?.toString() ?? "";
  }

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case "OPEN":
        return Colors.red;

      case "IN PROGRESS":
        return Colors.orange;

      case "RESOLVED":
        return Colors.green;

      case "CLOSED":
        return Colors.grey;

      default:
        return Colors.blue;
    }
  }

  void showTicketDetails(
    Map<String, dynamic> ticket,
  ) {
    final ticketId =
        valueOf(ticket, "TicketID");

    final userId =
        valueOf(ticket, "UserID");

    final vendor =
        valueOf(ticket, "Vendor");

    final category =
        valueOf(ticket, "Category");

    final description =
        valueOf(ticket, "Description");

    final status =
        valueOf(ticket, "Status");

    final createdAt =
        valueOf(ticket, "CreatedAt");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
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
                      const Icon(
                        Icons.support_agent,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Support Issue",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  const SizedBox(height: 8),

                  _detailRow(
                    "Ticket ID",
                    ticketId,
                  ),

                  _detailRow(
                    "User ID",
                    userId,
                  ),

                  _detailRow(
                    "Vendor",
                    vendor,
                  ),

                  _detailRow(
                    "Category",
                    category,
                  ),

                  _detailRow(
                    "Created At",
                    createdAt,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(14),
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10),
                      color:
                          Colors.grey.shade100,
                    ),
                    child: Text(
                      description.isEmpty
                          ? "No description"
                          : description,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
  children: [
    const Text(
      "Status:",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(width: 10),

    Expanded(
      child: DropdownButton<String>(
        value: [
          "Open",
          "In Progress",
          "Resolved",
        ].contains(status)
            ? status
            : "Open",

        isExpanded: true,

        items: const [
          DropdownMenuItem(
            value: "Open",
            child: Text("Open"),
          ),
          DropdownMenuItem(
            value: "In Progress",
            child: Text("In Progress"),
          ),
          DropdownMenuItem(
            value: "Resolved",
            child: Text("Resolved"),
          ),
        ],

        onChanged: (newStatus) async {
          if (newStatus == null ||
              newStatus == status) {
            return;
          }

          try {
            Navigator.pop(context);

            ScaffoldMessenger.of(
              this.context,
            ).showSnackBar(
              const SnackBar(
                content: Text(
                  "Updating ticket status...",
                ),
              ),
            );

            final result =
                await apiService
                    .updateSupportTicketStatus(
              userId: widget.userId,
              ticketId: ticketId,
              status: newStatus,
            );

            if (!mounted) return;

            if (result["success"] == true) {
              await loadSupportTickets();

              ScaffoldMessenger.of(
                this.context,
              ).showSnackBar(
                SnackBar(
                  content: Text(
                    "Status changed to $newStatus",
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(
                this.context,
              ).showSnackBar(
                SnackBar(
                  content: Text(
                    result["message"]
                            ?.toString() ??
                        "Unable to update status",
                  ),
                ),
              );
            }
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(
              this.context,
            ).showSnackBar(
              SnackBar(
                content: Text(
                  "Error updating status: $e",
                ),
              ),
            );
          }
        },
      ),
    ),
  ],
),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(
    Map<String, dynamic> ticket,
  ) {
    final ticketId =
        valueOf(ticket, "TicketID");

    final userId =
        valueOf(ticket, "UserID");

    final category =
        valueOf(ticket, "Category");

    final description =
        valueOf(ticket, "Description");

    final status =
        valueOf(ticket, "Status");

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(14),

        leading: CircleAvatar(
          child: const Icon(
            Icons.confirmation_number,
          ),
        ),

        title: Text(
          ticketId.isEmpty
              ? "Support Ticket"
              : ticketId,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding:
              const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "User: ${userId.isEmpty ? "-" : userId}",
              ),

              const SizedBox(height: 4),

              Text(
                category.isEmpty
                    ? "No category"
                    : category,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 8),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor(
                    status,
                  ).withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  status.isEmpty
                      ? "Unknown"
                      : status,
                  style: TextStyle(
                    color: statusColor(
                      status,
                    ),
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),

        onTap: () {
          showTicketDetails(ticket);
        },
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),

              const SizedBox(height: 16),

              Text(
                errorMessage!,
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed:
                    loadSupportTickets,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text(
                  "Retry",
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (tickets.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadSupportTickets,
        child: ListView(
          children: const [
            SizedBox(height: 180),

            Icon(
              Icons.support_agent,
              size: 70,
              color: Colors.grey,
            ),

            SizedBox(height: 16),

            Center(
              child: Text(
                "No support issues found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadSupportTickets,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: tickets.length,
        itemBuilder: (
          context,
          index,
        ) {
          return _buildTicketCard(
            tickets[index],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Support Issues",
            ),
            Text(
              "${tickets.length} Issues",
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: isLoading
                ? null
                : loadSupportTickets,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}