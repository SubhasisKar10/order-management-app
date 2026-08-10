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

  final po =
      (item["PO"] ?? "")
          .toString()
          .trim();

  final isCompleted = po.isNotEmpty;

  if (selectedStatus == "Completed") {
    statusMatch = isCompleted;
  }

  if (selectedStatus == "Pending") {
    statusMatch = !isCompleted;
  }
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

       if (widget.orderType == "E_OFFICE") {
  orders.sort((a, b) {
    final eOfficeA =
        int.tryParse(
          a["E-NOTE"]?.toString() ?? "",
        ) ?? 0;

    final eOfficeB =
        int.tryParse(
          b["E-NOTE"]?.toString() ?? "",
        ) ?? 0;

    return eOfficeB.compareTo(eOfficeA);
  });
}else {

  orders.sort((a, b) {

    final poA =
        int.tryParse(
          a["PURCHASE ORDER"]?.toString() ?? "",
        ) ?? 0;

    final poB =
        int.tryParse(
          b["PURCHASE ORDER"]?.toString() ?? "",
        ) ?? 0;

    return poB.compareTo(poA);
  });
}

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
Map<String, List<Map<String, dynamic>>> groupOrdersByPO() {

  final Map<String, List<Map<String, dynamic>>> grouped = {};

  for (final item in filteredOrders) {

    final order =
        item as Map<String, dynamic>;

    final po =
        (order["PURCHASE ORDER"] ?? "")
            .toString();

    grouped.putIfAbsent(po, () => []);

    grouped[po]!.add(order);
  }

  return grouped;
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
    child: Builder(
      builder: (context) {

       if (widget.orderType == "E_OFFICE") {
  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: filteredOrders.length,
    itemBuilder: (context, index) {
      final order =
          filteredOrders[index]
              as Map<String, dynamic>;

      return _buildEOfficeCard(
        order: order,
        orderNumber: index + 1,
      );
    },
  );
}else {

  final groupedOrders =
      groupOrdersByPO();

  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: groupedOrders.length,
    itemBuilder: (context, index) {

      final po =
          groupedOrders.keys
              .elementAt(index);

      final workOrders =
          groupedOrders[po]!;

      return _buildPurchaseOrderCard(
        po: po,
        workOrders: workOrders,
      );
    },
  );
}
}
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
  final purchaseOrder =
      widget.orderType == "E_OFFICE"
          ? (order["PO"]?.toString().trim() ?? "")
          : (order["PURCHASE ORDER"]?.toString().trim() ?? "");

  final isEOffice =
      widget.orderType == "E_OFFICE";

  final isCompleted =
      isEOffice
          ? purchaseOrder.isNotEmpty
          : purchaseOrder.isNotEmpty;

  final statusText =
      isEOffice
          ? (isCompleted ? "Completed" : "Pending")
          : "";

  final statusColor =
      isCompleted
          ? Colors.red
          : Colors.green;

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
                    materialReq:
                        order["MAT REQ."]
                            .toString(),
                    workOrder:
                        order["WORK ORDER"]
                            .toString(),
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

            // =========================
            // E-OFFICE HEADER
            // =========================

            if (isEOffice)
              Row(
                children: [

                  Expanded(
                    child: Text(
                      "E-Office No. ${order["E-NOTE"] ?? ""}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color: statusColor,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      statusText,
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )

            // =========================
            // DTR PO HEADER
            // =========================
            else
              Text(
                "Order #$orderNumber",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

            const Divider(
              height: 22,
            ),

            // =========================
            // E-OFFICE DETAILS
            // =========================

            if (isEOffice) ...[

              _orderField(
                "Date",
                formatDate(order["DATE"]),
              ),

              _orderField(
                "E-Office No.",
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

            ]

            // =========================
            // DTR PO DETAILS
            // =========================

            else ...[

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

            const SizedBox(
              height: 10,
            ),

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
Widget _buildPurchaseOrderCard({
  required String po,
  required List<Map<String, dynamic>> workOrders,
}) {

  final first = workOrders.first;

  return Card(
    margin: const EdgeInsets.only(bottom: 14),

    child: ExpansionTile(

      leading: const Icon(
        Icons.inventory_2,
        color: Colors.blue,
      ),

      title: Text(
        po,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(
  first["VENDOR"]?.toString() ?? "",
),

      children: workOrders.map((order) {

       return _buildOrderCard(
  order: order,
  orderNumber: workOrders.indexOf(order) + 1,
);

      }).toList(),

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
Widget _buildEOfficeCard({
  required Map<String, dynamic> order,
  required int orderNumber,
}) {
  final eNote =
      order["E-NOTE"]?.toString().trim() ?? "";

  final work =
      order["WORK"]?.toString().trim() ?? "";

  final po =
      order["PO"]?.toString().trim() ?? "";

  final isCompleted = po.isNotEmpty;

  return Card(
    margin: const EdgeInsets.only(
      bottom: 14,
    ),
    child: ExpansionTile(
      leading: Icon(
        Icons.description,
        color: isCompleted
            ? Colors.red
            : Colors.green,
      ),

      title: Text(
        eNote.isEmpty
            ? "E-Office"
            : eNote,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(
        work.isEmpty
            ? "No work description"
            : work,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

      children: [
        _buildOrderCard(
          order: order,
          orderNumber: orderNumber,
        ),
      ],
    ),
  );
}
}