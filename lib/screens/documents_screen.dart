import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';

class DocumentsScreen extends StatefulWidget {
  final String userId;
  final String purchaseOrder;
  final String materialReq;
  final String workOrder;
  final String orderType;

  const DocumentsScreen({
    super.key,
    required this.userId,
    required this.purchaseOrder,
    required this.materialReq,
    required this.workOrder,
    required this.orderType,
  });

  @override
  State<DocumentsScreen> createState() =>
      _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? purchaseOrderFile;
  Map<String, dynamic>? materialReqFile;
  Map<String, dynamic>? returnIntimationFile;

  @override
  void initState() {
    super.initState();
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    try {
     final result = await apiService.getOrderDocuments(
  userId: widget.userId,
  purchaseOrder: widget.purchaseOrder,
  materialReq: widget.materialReq,
  workOrder: widget.workOrder,
  orderType: widget.orderType,
);

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          purchaseOrderFile =
              result['purchaseOrder'] as Map<String, dynamic>?;

          materialReqFile =
              result['materialReq'] as Map<String, dynamic>?;

          returnIntimationFile =
              result['returnIntimation'] as Map<String, dynamic>?;

          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              result['message'] ?? 'Failed to load documents';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PO: ${widget.purchaseOrder}",
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              "WO: ${widget.workOrder}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
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
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
  onRefresh: loadDocuments,
  child: ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _buildDocumentCard(
        title: "Purchase Order",
        subtitle: widget.purchaseOrder,
        icon: Icons.shopping_cart,
        document: purchaseOrderFile,
      ),

      if (widget.orderType != "OTHER_PO") ...[
        const SizedBox(height: 14),

        _buildDocumentCard(
          title: "Material Requisition",
          subtitle: widget.materialReq,
          icon: Icons.assignment,
          document: materialReqFile,
        ),

        const SizedBox(height: 14),

        _buildDocumentCard(
          title: "Return Intimation",
          subtitle: widget.workOrder,
          icon: Icons.assignment_return,
          document: returnIntimationFile,
        ),
      ],
    ],
  ),
);
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Map<String, dynamic>? document,
  }) {
    final found = document?['found'] == true;

    final fileName =
        document?['name']?.toString() ?? '';

    final url =
        document?['url']?.toString() ?? '';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Icon(icon),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (found)
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("VIEW PDF"),
                      onPressed: () {
                        _openDocument(url);
                      },
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.cloud_off,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Not Uploaded Yet",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDocument(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Document URL not available"),
        ),
      );
      return;
    }

    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to open document"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to open document"),
        ),
      );
    }
  }
}