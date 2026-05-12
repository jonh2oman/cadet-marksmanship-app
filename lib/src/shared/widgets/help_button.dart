import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GlobalHelpButton extends StatelessWidget {
  const GlobalHelpButton({super.key});

  Future<void> _openHelp() async {
    const url = kIsWeb ? '/#/help' : 'help'; // On web, use hash routing by default in Flutter
    final uri = Uri.parse(url);
    
    // For Web, opening in a new tab is a standard requirement from the user.
    if (kIsWeb) {
      // Use the browser's own mechanism if possible
      await launchUrl(Uri.parse(Uri.base.toString().split('#')[0] + '#/help'), webOnlyWindowName: '_blank');
    } else {
      // For desktop/mobile, we can just navigate or open a window
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: FloatingActionButton(
        onPressed: _openHelp,
        backgroundColor: Colors.white,
        mini: true,
        child: const Icon(
          LucideIcons.helpCircle,
          color: Colors.black87,
          size: 24,
        ),
      ),
    );
  }
}
