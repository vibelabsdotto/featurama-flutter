import 'package:flutter/cupertino.dart';

import '../../models/feature_request.dart';
import '../theme/featurama_theme.dart';
import '../strings/featurama_strings.dart';
import '../icons/featurama_icons.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    required this.theme,
    required this.strings,
    required this.request,
    required this.isVoting,
    required this.onToggleVote,
    this.onOpen,
    super.key,
  });

  final FeaturamaTheme theme;
  final FeaturamaStrings strings;
  final FeatureRequest request;
  final bool isVoting;
  final VoidCallback onToggleVote;
  final VoidCallback? onOpen;

  Widget _badge(String label, {bool pending = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: pending ? theme.secondary : theme.accentLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: pending ? theme.textSecondary : theme.accent,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = request.isApproved && !isVoting;
    final voteColor = request.hasVoted ? theme.accentForeground : theme.accent;
    final voteLabel = request.isApproved
        ? request.hasVoted
            ? strings.removeVote
            : strings.vote
        : strings.badgePending;
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
          Semantics(
            container: true,
            excludeSemantics: true,
            onTap: enabled ? onToggleVote : null,
            label: '$voteLabel: ${request.title}',
            value: '${request.voteCount}',
            button: true,
            enabled: enabled,
            selected: request.hasVoted,
            child: CupertinoButton(
              onPressed: enabled ? onToggleVote : null,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              color: request.hasVoted ? theme.accent : theme.accentLight,
              disabledColor: theme.secondary,
              borderRadius: BorderRadius.circular(8),
              child: ExcludeSemantics(
                child: Column(
                  children: [
                    ChevronUpIcon(
                      size: 20,
                      color: enabled ? voteColor : theme.textSecondary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${request.voteCount}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: enabled ? voteColor : theme.textSecondary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
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
                if (!request.isApproved) ...[
                  const SizedBox(height: 6),
                  _badge(strings.badgePending, pending: true),
                ] else if (request.status == FeatureRequestStatus.roadmap) ...[
                  const SizedBox(height: 6),
                  _badge(strings.badgePlanned),
                ],
                if (onOpen != null)
                  Semantics(
                    container: true,
                    excludeSemantics: true,
                    button: true,
                    label: '${strings.viewDetails}: ${request.title}',
                    value: '${request.commentCount} ${strings.comments}',
                    onTap: onOpen,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      onPressed: onOpen,
                      child: Text(
                        '${strings.viewDetails}: ${request.commentCount} ${strings.comments}',
                        style: TextStyle(color: theme.accent, fontSize: 14),
                      ),
                    ),
                  ),
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
