import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'my_support_issues_screen.dart';
import 'create_support_ticket_screen.dart';

class SupportScreen extends StatefulWidget {
  final String userId;

  const SupportScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SupportScreen> createState() =>
      _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = false;
  List<Map<String, dynamic>> tickets = [];

  @override
  void initState() {
    super.initState();
    loadMySupportIssues();
  }

  Future<void> loadMySupportIssues() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result =
          await apiService.getSupportTickets(
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
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to load support issues: $e",
          ),
        ),
      );
    }
  }

  static const String whatsappGroupUrl =
      'https://chat.whatsapp.com/L54GjzhkDmCAhrgTgtb1Vg';

  Future<void> _openWhatsApp(BuildContext context) async {
    final uri = Uri.parse(whatsappGroupUrl);

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open WhatsApp discussion',
          ),
        ),
      );
    }
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Admin Support will be available soon.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support & Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'How can we help?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'For minor questions or common issues, '
            'please use the WhatsApp discussion group. '
            'For problems requiring administrator assistance, '
            'you can raise a support issue.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 24),

          _supportCard(
            context,
            icon: Icons.chat,
            title: 'WhatsApp Discussion',
            description:
                'Ask questions, discuss common issues, '
                'and help other users.',
            color: Colors.green,
            onTap: () => _openWhatsApp(context),
          ),

          const SizedBox(height: 14),

          _supportCard(
  context,
  icon: Icons.add_comment_outlined,
  title: 'Raise New Issue',
  description:
      'Report a problem that requires administrator assistance.',
  color: const Color(0xFF5E2CA5),
  onTap: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CreateSupportTicketScreen(
          userId: widget.userId,
        ),
      ),
    );

    if (result == true && mounted) {
      await loadMySupportIssues();
    }
  },
),

          const SizedBox(height: 14),

          _supportCard(
            context,
            icon: Icons.history,
            title: 'My Support Issues',
            description:
                'View your submitted support issues '
                'and their status.',
            color: Colors.blue,
            onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MySupportIssuesScreen(
        userId: widget.userId,
      ),
    ),
  );
},
          ),
        ],
      ),
    );
  }

  Widget _supportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}