import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddVendorScreen extends StatefulWidget {
  final String userId;

  const AddVendorScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AddVendorScreen> createState() =>
      _AddVendorScreenState();
}

class _AddVendorScreenState
    extends State<AddVendorScreen> {

  final ApiService apiService = ApiService();

  final vendorCodeController = TextEditingController();
final vendorNameController = TextEditingController();
final vendorController = TextEditingController();

  bool isSaving = false;

  Future<void> saveVendor() async {

    if (vendorCodeController.text.trim().isEmpty ||
        vendorNameController.text.trim().isEmpty ||
        vendorController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      final result = await apiService.addVendor(
        userId: widget.userId,
        vendorCode:
            vendorCodeController.text.trim(),
        vendorName:
            vendorNameController.text.trim(),
        vendor:
            vendorController.text.trim().toUpperCase(),
      );

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]),
        ),
      );

      if (result["success"] == true) {
        Navigator.pop(context, true);
      }

    } catch (e) {

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Vendor"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: vendorCodeController,
              decoration: const InputDecoration(
                labelText: "Vendor Code",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: vendorNameController,
              decoration: const InputDecoration(
                labelText: "Vendor Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: vendorController,
              decoration: const InputDecoration(
                labelText: "Vendor Short Name",
                hintText: "Example: DB",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                    isSaving ? null : saveVendor,
                icon: const Icon(Icons.save),
                label: Text(
                  isSaving
                      ? "Saving..."
                      : "ADD VENDOR",
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}