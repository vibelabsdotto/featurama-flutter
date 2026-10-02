import 'package:flutter/cupertino.dart';

import '../theme/featurama_theme.dart';
import '../strings/featurama_strings.dart';

class FilterTabs extends StatelessWidget {
  const FilterTabs({
    required this.theme,
    required this.strings,
    required this.activeFilter,
    required this.onFilterChanged,
    super.key,
  });

  final FeaturamaTheme theme;
  final FeaturamaStrings strings;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('new', strings.filterNew),
      ('planned', strings.filterPlanned),
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
          children: filters.map((filter) {
            final isActive = filter.$1 == activeFilter;
            return Expanded(
              child: Semantics(
                selected: isActive,
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive ? theme.card : null,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isActive
                        ? [
                            const BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    onPressed: () => onFilterChanged(filter.$1),
                    child: Text(
                      filter.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isActive ? theme.text : theme.textSecondary,
                        decoration: TextDecoration.none,
                      ),
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
