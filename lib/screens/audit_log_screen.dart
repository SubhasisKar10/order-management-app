import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuditLogScreen extends StatefulWidget {
  final String userId;

  const AuditLogScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {

  bool loading = true;
  List logs = [];

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  Future<void> loadLogs() async {

    final result = await ApiService().getAuditLogs(
      userId: widget.userId,
    );

    setState(() {
      logs = result["logs"] ?? [];
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Audit Log"),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(

              itemCount: logs.length,

              itemBuilder: (context, index) {

                final log = logs[index];

                return Card(

                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  child: ListTile(

                    leading: const Icon(Icons.history),

                    title: Text(log["action"].toString()),

                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(log["details"].toString()),

                        Text(
                          log["userId"].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(log["dateTime"].toString()),

                      ],
                    ),

                  ),

                );

              },

            ),

    );

  }

}