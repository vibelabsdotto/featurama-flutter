import 'package:flutter/widgets.dart';
import '../../models/feature_request.dart';
import '../../models/paginated_response.dart';
import '../theme/featurama_theme.dart';
import '../strings/featurama_strings.dart';
import 'request_card.dart';

class RequestList extends StatelessWidget {
  const RequestList({
    super.key,
    required this.theme,
    required this.strings,
    required this.data,
    required this.isLoading,
    required this.error,
    required this.votingIds,
    required this.onToggleVote,
    required this.onRefresh,
  });

  final FeaturamaTheme theme;
  final FeaturamaStrings strings;
  final PaginatedResponse<FeatureRequest>? data;
  final bool isLoading;
  final String? error;
  final Set<String> votingIds;
  final void Function(String id) onToggleVote;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    // Loading (initial)
    if (isLoading && data == null) {
      return Expanded(
        child: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: _LoadingIndicator(color: theme.accent),
          ),
        ),
      );
    }

    // Error (no data)
    if (error != null && data == null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.error, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: theme.textSecondary, decoration: TextDecoration.none)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onRefresh,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                  decoration: BoxDecoration(
                    color: theme.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(strings.retry, style: TextStyle(color: theme.accentForeground, decoration: TextDecoration.none)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (data != null && data!.items.isEmpty && !isLoading) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.empty, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: theme.textSecondary, decoration: TextDecoration.none)),
              const SizedBox(height: 8),
              Text(strings.emptyHint, style: TextStyle(fontSize: 14, color: theme.textSecondary, decoration: TextDecoration.none)),
            ],
          ),
        ),
      );
    }

    // List
    if (data != null && data!.items.isNotEmpty) {
      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 40),
          itemCount: data!.items.length,
          itemBuilder: (context, index) {
            final item = data!.items[index];
            return RequestCard(
              theme: theme,
              strings: strings,
              request: item,
              isVoting: votingIds.contains(item.id),
              onToggleVote: () => onToggleVote(item.id),
            );
          },
        ),
      );
    }

    return const Expanded(child: SizedBox.shrink());
  }
}

class _LoadingIndicator extends StatefulWidget {
  const _LoadingIndicator({required this.color});
  final Color color;

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 6.28318,
          child: CustomPaint(
            painter: _SpinnerPainter(widget.color),
          ),
        );
      },
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final rect = Offset.zero & size;
    canvas.drawArc(rect, 0, 4.7, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
