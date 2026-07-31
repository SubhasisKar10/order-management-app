import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import 'documents_screen.dart';

class OrdersScreen extends StatefulWidget {
  final String userId;
  final String orderType;

  const OrdersScreen({
    super.key,
    required this.userId,
    required this.orderType,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = true;
  String? errorMessage;

  List<dynamic> orders = [];
  List<dynamic> filteredOrders = [];

  final TextEditingController searchController =
      TextEditingController();

  String selectedStatus = "All";

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String formatDate(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return "";
    }

    try {
      final date = DateTime.parse(value.toString());
      return DateFormat("dd-MM-yyyy").format(date);
    } catch (_) {
      return value.toString();
    }
  }

  void filterOrders(String keyword) {
    keyword = keyword.toLowerCase().trim();

    filteredOrders = orders.where((order) {
      final item = order as Map<String, dynamic>;

      String searchText = "";

      if (widget.orderType == "E_OFFICE") {
        searchText =
            "${item["PO"]} "
            "${item["WORK ORDER"]} "
            "${item["PROJECT ID"]} "
            "${item["E-NOTE"]} "
            "${item["VENDOR"]}";
      } else {
        searchText =
            "${item["PURCHASE ORDER"]} "
            "${item["WORK ORDER"]} "
            "${item["DTR SERIAL NO"]} "
            "${item["DTR CODE"]} "
            "${item["VENDOR"]}";
      }

      final searchMatch =
          keyword.isEmpty ||
          searchText.toLowerCase().contains(keyword);

      bool statusMatch = true;

      if (widget.orderType == "E_OFFICE" &&
          selectedStatus != "All") {
        statusMatch =
            (item["STATUS"] ?? "")
                    .toString()
                    .toLowerCase() ==
                selectedStatus.toLowerCase();
      }

      return searchMatch && statusMatch;
    }).toList();

    setState(() {});
  }

  Future<void> loadOrders() async {
      setState(() {
       isLoading = true;
 });
    try {
      final result = await apiService.getOrders(
        userId: widget.userId,
        orderType: widget.orderType,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        orders = List.from(result["orders"] ?? []);

        final poColumn = widget.orderType == "E_OFFICE"
            ? "PO"
            : "PURCHASE ORDER";

        orders.sort((a, b) {
          final poA =
              int.tryParse(a[poColumn].toString()) ?? 0;

          final poB =
              int.tryParse(b[poColumn].toString()) ?? 0;

          return poB.compareTo(poA);
        });

        filteredOrders = List.from(orders);

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              result["message"] ?? "Failed to load orders";
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.orderType == "E_OFFICE"
              ? "E-Office Orders"
              : "DTR PO Orders",
        ),
      ),
      body: _buildBody(),
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
          padding: const EdgeInsets.all(20),
          child: Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (filteredOrders.isEmpty) {
      return const Center(
        child: Text(
          "No orders found",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: searchController,
            onChanged: filterOrders,
            decoration: InputDecoration(
              hintText: "Search Orders...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        filterOrders("");
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        if (widget.orderType == "E_OFFICE")
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [

                const Text(
                  "Status",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 12),

                DropdownButton<String>(
                  value: selectedStatus,
                  items: const [

                    DropdownMenuItem(
                      value: "All",
                      child: Text("All"),
                    ),

                    DropdownMenuItem(
                      value: "Pending",
                      child: Text("Pending"),
                    ),

                    DropdownMenuItem(
                      value: "Completed",
                      child: Text("Completed"),
                    ),

                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedStatus = value;
                    });

                    filterOrders(searchController.text);
                  },
                ),

                const Spacer(),

                Text(
                  "${filteredOrders.length} Orders",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),

        const SizedBox(height: 8),

       Expanded(
 	 child: RefreshIndicator(
    	    onRefresh: loadOrders,
      	        child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order =
                  filteredOrders[index]
                      as Map<String, dynamic>;

              return _buildOrderCard(
                order: order,
                orderNumber: index + 1,
              );
            },
          ),
         ),
        ),

      ],
    );
  }

    Widget _buildOrderCard({
    required Map<String, dynamic> order,
    required int orderNumber,
  }) {
    final purchaseOrder = widget.orderType == "E_OFFICE"
        ? (order["PO"]?.toString() ?? "")
        : (order["PURCHASE ORDER"]?.toString() ?? "");

    return Card(
      margin: const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 14,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: purchaseOrder.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DocumentsScreen(
                      userId: widget.userId,
                      purchaseOrder: purchaseOrder,
                    ),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  Text(
                    "Order #$orderNumber",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  if (widget.orderType == "E_OFFICE")
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (order["STATUS"]
                                            ?.toString()
                                            .toLowerCase() ==
                                        "completed")
                                ? Colors.green
                                : Colors.orange,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        order["STATUS"]
                                ?.toString() ??
                            "",
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                ],
              ),

              const Divider(height: 22),

              if (widget.orderType ==
                  "E_OFFICE") ...[

                _orderField(
                  "Date",
                  formatDate(order["DATE"]),
                ),

                _orderField(
                  "E-Note",
                  order["E-NOTE"],
                ),

                _orderField(
                  "Project ID",
                  order["PROJECT ID"],
                ),

                _orderField(
                  "Work Order",
                  order["WORK ORDER"],
                ),

                _orderField(
                  "PO",
                  order["PO"],
                ),

                _orderField(
                  "Work",
                  order["WORK"],
                ),

                _orderField(
                  "Vendor",
                  order["VENDOR"],
                ),

              ] else ...[

                _orderField(
                  "Purchase Order",
                  order["PURCHASE ORDER"],
                ),

                _orderField(
                  "Work Order",
                  order["WORK ORDER"],
                ),

                _orderField(
                  "Purchase Requisition",
                  order["PUR REQ"],
                ),

                _orderField(
                  "DTR Serial No",
                  order["DTR SERIAL NO"],
                ),

                _orderField(
                  "DTR Code",
                  order["DTR CODE"],
                ),

                _orderField(
                  "Vendor",
                  order["VENDOR"],
                ),

                _orderField(
                  "Material Requisition",
                  order["MAT REQ."],
                ),

                _orderField(
                  "Return Reservation",
                  order["RETURN RESERVATION"],
                ),

              ],

              const SizedBox(height: 10),

              if (purchaseOrder.isNotEmpty)
                const Align(
                  alignment:
                      Alignment.centerRight,
                  child: Text(
                    "Tap to view documents →",
                    style: TextStyle(
                      color: Colors.blue,
                      fontStyle:
                          FontStyle.italic,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }

    Widget _orderField(
    String label,
    dynamic value,
  ) {
    final text = value?.toString().trim() ?? "";

    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Text(":  "),

          Expanded(
            child: SelectableText(
              text,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),

        ],
      ),
    );
  }
}