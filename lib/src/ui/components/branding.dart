import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../icons/featurama_icons.dart';
import '../theme/featurama_theme.dart';

class Branding extends StatelessWidget {
  const Branding({required this.theme, super.key});
  final FeaturamaTheme theme;

  Future<void> _openFeaturama() async {
    final uri = Uri.parse('https://featurama.app');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _openFeaturama,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: theme.gray100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FeaturamaLogoIcon(size: 16, color: theme.accent),
            const SizedBox(width: 6),
            Flexible(
                child: Text(
              'Powered by Featurama',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: theme.textSecondary,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
