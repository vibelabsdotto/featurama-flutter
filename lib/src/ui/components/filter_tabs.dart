import 'package:flutter/widgets.dart';
import '../theme/featurama_theme.dart';
import '../strings/featurama_strings.dart';

class FilterTabs extends StatelessWidget {
  const FilterTabs({
    super.key,
    required this.theme,
    required this.strings,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final FeaturamaTheme theme;
  final FeaturamaStrings strings;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('new', strings.filterNew),
      ('in_progress', strings.filterInProgress),
      ('done', strings.filterDone),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.gray100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: filters.map((f) {
            final isActive = f.$1 == activeFilter;
            return Expanded(
              child: GestureDetector(
                onTap: () => onFilterChanged(f.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? theme.card : null,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isActive
                        ? [BoxShadow(color: const Color(0x1A000000), blurRadius: 2, offset: const Offset(0, 1))]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    f.$2,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isActive ? theme.text : theme.textSecondary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
