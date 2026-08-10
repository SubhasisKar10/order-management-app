import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PendingDevicesScreen extends StatefulWidget {
  final String adminUserId;

  const PendingDevicesScreen({
    super.key,
    required this.adminUserId,
  });

  @override
  State<PendingDevicesScreen> createState() =>
      _PendingDevicesScreenState();
}

class _PendingDevicesScreenState
    extends State<PendingDevicesScreen> {

  final ApiService apiService = ApiService();

  bool loading = true;

  List devices = [];

  @override
  void initState() {
    super.initState();
    loadDevices();
  }

  Future<void> loadDevices() async {

    final result = await apiService.getPendingDevices(
      userId: widget.adminUserId,
    );

    if (!mounted) return;

    setState(() {

      loading = false;

      if (result["success"] == true) {
        devices = result["devices"];
      }

    });

  }

  Future<void> approve(String userId) async {

    await apiService.approveDevice(
      adminUserId: widget.adminUserId,
      editUserId: userId,
    );

    loadDevices();

  }

  Future<void> reject(String userId) async {

    await apiService.rejectDevice(
      adminUserId: widget.adminUserId,
      editUserId: userId,
    );

    loadDevices();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Pending Devices"),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : devices.isEmpty
              ? const Center(
                  child: Text(
                    "No Pending Devices",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(

                  itemCount: devices.length,

                  itemBuilder: (context, index) {

                    final d = devices[index];

                    return Card(

                      margin: const EdgeInsets.all(10),

                      child: Padding(

                        padding: const EdgeInsets.all(15),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              d["Name"],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "User ID : ${d["UserID"]}",
                            ),

                            Text(
                              "Vendor : ${d["Vendor"]}",
                            ),

                            Text(
                              "Phone : ${d["DeviceName"]}",
                            ),

                            Text(
                              "Registered : ${d["CreatedOn"]}",
                            ),

                            const SizedBox(height: 15),

                            Row(

                              children: [

                                Expanded(

                                  child: ElevatedButton(

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.green,
                                    ),

                                    onPressed: () {

                                      approve(
                                        d["UserID"],
                                      );

                                    },

                                    child: const Text(
                                      "APPROVE",
                                    ),

                                  ),

                                ),

                                const SizedBox(width: 10),

                                Expanded(

                                  child: ElevatedButton(

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.red,
                                    ),

                                    onPressed: () {

                                      reject(
                                        d["UserID"],
                                      );

                                    },

                                    child: const Text(
                                      "REJECT",
                                    ),

                                  ),

                                ),

                              ],

                            )

                          ],

                        ),

                      ),

                    );

                  },

                ),

    );

  }

}