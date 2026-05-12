import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisclaimerDialog extends StatefulWidget {
  const DisclaimerDialog({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final acknowledged = prefs.getBool('disclaimer_acknowledged') ?? false;

    if (!acknowledged && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const DisclaimerDialog(),
      );
    }
  }

  @override
  State<DisclaimerDialog> createState() => _DisclaimerDialogState();
}

class _DisclaimerDialogState extends State<DisclaimerDialog> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Text('Important Notice'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This application is provided "as is" without any guarantee or warranty of any kind, express or implied.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please be advised that this is NOT an official application of the Canadian Cadet Organization (CCO) or the Department of National Defence (DND).',
            ),
            const SizedBox(height: 16),
            const Text(
              'Users are responsible for ensuring compliance with official rulebooks and range safety protocols.',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    'I acknowledge and accept these terms.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _isChecked
              ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('disclaimer_acknowledged', true);
                  if (context.mounted) Navigator.of(context).pop();
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'ACK!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
