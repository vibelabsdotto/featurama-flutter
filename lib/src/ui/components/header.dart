import 'package:flutter/cupertino.dart';

import '../theme/featurama_theme.dart';
import '../icons/featurama_icons.dart';
import '../strings/featurama_strings.dart';

class Header extends StatelessWidget {
  const Header({
    required this.theme,
    required this.strings,
    required this.onAdd,
    super.key,
    this.onClose,
  });

  final FeaturamaTheme theme;
  final FeaturamaStrings strings;
  final VoidCallback? onClose;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16, top: 8),
      child: Row(
        children: [
          if (onClose != null)
            Semantics(
              label: strings.close,
              child: CupertinoButton(
                padding: const EdgeInsets.all(8),
                onPressed: onClose,
                child: CloseIcon(size: 24, color: theme.text),
              ),
            )
          else
            const SizedBox(width: 44),
          Expanded(
            child: Center(
              child: Text(
                strings.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.text,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          Semantics(
            label: strings.addRequest,
            child: CupertinoButton(
              padding: const EdgeInsets.all(8),
              onPressed: onAdd,
              child: PlusIcon(
                size: 24,
                color: onAdd == null ? theme.textSecondary : theme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
