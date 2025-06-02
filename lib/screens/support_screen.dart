import 'package:flutter/material.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _problemController = TextEditingController();

  final List<Map<String, dynamic>> _commonIssues = [
    {
      'title': 'Images are not loading',
      'suggestions': [
        'Check your internet connection.',
        'Clear app cache.',
        'Try restarting the app.',
      ],
    },
    {
      'title': 'App is crashing',
      'suggestions': [
        'Make sure you have the latest version.',
        'Clear storage and reopen the app.',
        'Reinstall if the issue persists.',
      ],
    },
    {
      'title': 'Can’t log in',
      'suggestions': [
        'Double-check your email and password.',
        'Try logging in after restarting your device.',
      ],
    },
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support request sent!')),
      );
      Navigator.pop(context);
    }
  }

  void _showSuggestionsDialog(String title, List<String> suggestions) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: suggestions
              .map((s) => ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(s),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter phone number' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _problemController,
                    decoration: const InputDecoration(
                        labelText: 'Describe your problem'),
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Describe your problem' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Common Issues',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _commonIssues.length,
              itemBuilder: (context, index) {
                final issue = _commonIssues[index];
                return ListTile(
                  title: Text(issue['title']),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSuggestionsDialog(
                    issue['title'],
                    List<String>.from(issue['suggestions']),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
