import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';

class DocumentsScreen extends StatefulWidget {
  final String userId;
  final String purchaseOrder;

  const DocumentsScreen({
    super.key,
    required this.userId,
    required this.purchaseOrder,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = true;
  String? errorMessage;
  List<dynamic> documents = [];

  @override
  void initState() {
    super.initState();
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    try {
      final result = await apiService.getDocuments(
        userId: widget.userId,
        purchaseOrder: widget.purchaseOrder,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          documents = result['documents'] ?? [];
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
        title: Text(
          'Documents - ${widget.purchaseOrder}',
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

    if (documents.isEmpty) {
      return const Center(
        child: Text(
          'No documents found',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document =
            documents[index] as Map<String, dynamic>;

        return _buildDocumentCard(document);
      },
    );
  }

  Widget _buildDocumentCard(
    Map<String, dynamic> document,
  ) {
    final fileId =
        document['GoogleDriveFileID']?.toString() ?? '';

    final fileName =
        document['FileName']?.toString() ?? 'Document';

    final documentType =
        document['DocumentType']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(
          Icons.picture_as_pdf,
          size: 40,
        ),
        title: Text(fileName),
        subtitle: Text(documentType),
        trailing: const Icon(
          Icons.open_in_new,
        ),
        onTap: () async {
          if (fileId.isEmpty) {
            return;
          }

          final url = Uri.parse(
            'https://drive.google.com/file/d/$fileId/view',
          );

          if (await canLaunchUrl(url)) {
            await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
            );
          } else {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Unable to open document',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}