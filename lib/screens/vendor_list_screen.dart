import 'package:flutter/material.dart';
import '../services/api_service.dart';


class VendorListScreen extends StatefulWidget {
  final String userId;

  const VendorListScreen({
    super.key,
    required this.userId,
  });

  @override
 State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = true;
  String? errorMessage;
  List<dynamic> vendors = [];

  @override
  void initState() {
    super.initState();
    loadVendors();
  }

  Future<void> loadVendors() async {
    try {
      final result = await apiService.getVendors(
        userId: widget.userId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          vendors = result['vendors'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              result['message'] ?? 'Failed to load vendors';
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
      title: const Text('Vendor List'),
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
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  if (vendors.isEmpty) {
    return const Center(
      child: Text("No vendors found"),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: vendors.length,
    itemBuilder: (context, index) {
      final vendor =
          vendors[index] as Map<String, dynamic>;

      return _buildVendorCard(vendor);
    },
  );
}

  Widget _buildVendorCard(
    Map<String, dynamic> vendor,
  ) {
    final userId =
        vendor['UserID']?.toString() ?? '';

   final vendorCode =
    vendor["VendorCode"]?.toString() ?? "";

final vendorName =
    vendor["VendorName"]?.toString() ?? "";

final vendorCodeShort =
    vendor["Vendor"]?.toString() ?? "";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(
          Icons.business,
          size: 40,
        ),
        title: Text(vendorName),
        subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Vendor Code: $vendorCode'),
    Text('Vendor: $vendorCodeShort'),
  ],
),
      ),
    );
  }
}