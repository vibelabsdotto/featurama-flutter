import 'package:flutter/widgets.dart';
import '../../models/feature_request.dart';
import '../theme/featurama_theme.dart';
import '../strings/featurama_strings.dart';
import '../icons/featurama_icons.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.theme,
    required this.strings,
    required this.request,
    required this.isVoting,
    required this.onToggleVote,
  });

  final FeaturamaTheme theme;
  final FeaturamaStrings strings;
  final FeatureRequest request;
  final bool isVoting;
  final VoidCallback onToggleVote;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: isVoting ? null : onToggleVote,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: theme.accentLight,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 48),
              child: Column(
                children: [
                  ChevronUpIcon(size: 20, color: theme.accent),
                  const SizedBox(height: 2),
                  Text(
                    '${request.voteCount}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.accent,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.text,
                    decoration: TextDecoration.none,
                  ),
                ),
                if (request.status == FeatureRequestStatus.roadmap) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.accentLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      strings.badgePlanned,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.accent,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
                if (request.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    request.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textSecondary,
                      height: 1.4,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
