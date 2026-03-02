import 'package:flutter/widgets.dart';
import '../theme/featurama_theme.dart';
import '../icons/featurama_icons.dart';
import '../strings/featurama_strings.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.theme,
    required this.strings,
    this.onClose,
    required this.onAdd,
  });

  final FeaturamaTheme theme;
  final FeaturamaStrings strings;
  final VoidCallback? onClose;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16, top: 8),
      child: Row(
        children: [
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(child: CloseIcon(size: 24, color: theme.text)),
              ),
            )
          else
            const SizedBox(width: 40),
          Expanded(
            child: Center(
              child: Text(
                strings.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.text,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(child: PlusIcon(size: 24, color: theme.accent)),
            ),
          ),
        ],
      ),
    );
  }
}
