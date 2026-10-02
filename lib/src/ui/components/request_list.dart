import 'package:flutter/cupertino.dart';

import '../../models/feature_request.dart';
import '../../models/paginated_response.dart';
import '../theme/featurama_theme.dart';
import '../strings/featurama_strings.dart';
import 'request_card.dart';

class RequestList extends StatelessWidget {
  const RequestList({
    required this.theme,
    required this.strings,
    required this.data,
    required this.isLoading,
    required this.error,
    required this.votingIds,
    required this.onToggleVote,
    required this.onRefresh,
    super.key,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.onOpen,
  });

  final FeaturamaTheme theme;
  final FeaturamaStrings strings;
  final PaginatedResponse<FeatureRequest>? data;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final Set<String> votingIds;
  final void Function(String id) onToggleVote;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoadMore;
  final ValueChanged<FeatureRequest>? onOpen;

  @override
  Widget build(BuildContext context) {
    final items = data?.items ?? <FeatureRequest>[];
    return Expanded(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: onRefresh),
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: isLoading ? null : onRefresh,
                child: Text(
                  strings.refresh,
                  style: TextStyle(color: theme.accent, fontSize: 14),
                ),
              ),
            ),
          ),
          if (error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        error!,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textSecondary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: isLoading || isLoadingMore ? null : onRefresh,
                      child: Text(
                        strings.retry,
                        style: TextStyle(color: theme.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Semantics(
                  label: strings.loading,
                  liveRegion: true,
                  child: CupertinoActivityIndicator(color: theme.accent),
                ),
              ),
            ),
          if (items.isEmpty && !isLoading && error == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      strings.empty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.textSecondary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.emptyHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textSecondary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  return RequestCard(
                    key: ValueKey(item.id),
                    theme: theme,
                    strings: strings,
                    request: item,
                    isVoting: isLoading || votingIds.contains(item.id),
                    onToggleVote: () => onToggleVote(item.id),
                    onOpen: isLoading || onOpen == null
                        ? null
                        : () => onOpen!(item),
                  );
                }, childCount: items.length),
              ),
            ),
            if (data?.hasNextPage ?? false)
              SliverToBoxAdapter(
                child: CupertinoButton(
                  onPressed: isLoading || isLoadingMore ? null : onLoadMore,
                  child: isLoadingMore
                      ? Semantics(
                          label: strings.loading,
                          child: CupertinoActivityIndicator(
                            color: theme.accent,
                          ),
                        )
                      : Text(
                          strings.loadMore,
                          style: TextStyle(color: theme.accent),
                        ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ],
      ),
    );
  }
}
