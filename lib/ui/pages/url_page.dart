import 'package:code_mate/ui/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:code_mate/ui/widgets/custom_input_field.dart';

class BackendUrlScreen extends StatelessWidget {
  final TextEditingController _urlController = TextEditingController();

  BackendUrlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Visual Indicator
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.dns_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                "Server Configuration",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Enter your backend API base URL to connect the application to your server.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 40),

              CustomInputField(
                controller: _urlController,
                label: "Backend URL",
                prefixIcon: Icons.link_rounded,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  " Example: https://apps.divyan.online",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final url = _urlController.text.trim();
                    if (url.isNotEmpty) {
                      print("Connecting to: $url");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  },
                  child: const Text("Connect & Continue"),
                ),
              ),

              // TextButton(
              //   onPressed: () {
              //   },
              //   child: Text(
              //     "Use Default Server",
              //     style: TextStyle(color: theme.colorScheme.primary),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
