import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String appVersion = "1.0.0";

const String linkedInUrl = "https://www.linkedin.com/in/-muhammad--awais/";

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $uri');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
        centerTitle: true,
        backgroundColor: Colors.grey.shade300,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Expense Tracker',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version $appVersion',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "This app is your simple, no-fuss tool for managing daily spending. It allows you to quickly log expenses, categorize them (Food, Transport, etc.), and use tags (Monthly, Urgent) for detailed filtering. All data is stored locally on your device, giving you complete privacy and control over your financial records.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.person_pin, color: Colors.blue),
              title: const Text('Connect with the Developer'),
              subtitle: const Text('View LinkedIn Profile'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                _launchUrl(linkedInUrl);
              },
            ),
            const Divider(),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 180.0),
                child: Text(
                  '© 2025 Expense Tracker',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}