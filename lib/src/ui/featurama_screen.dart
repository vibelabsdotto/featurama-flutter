import 'package:flutter/widgets.dart';
import '../featurama_client.dart';
import '../models/create_request_dto.dart';
import '../models/feature_request.dart';
import '../models/paginated_response.dart';
import '../models/project_config.dart';
import 'theme/create_theme.dart';
import 'theme/featurama_theme.dart';
import 'strings/featurama_strings.dart';
import 'utils/voter_id.dart';
import 'components/header.dart';
import 'components/filter_tabs.dart';
import 'components/create_request_form.dart';
import 'components/request_list.dart';
import 'components/branding.dart';

/// A pre-built full-screen widget for displaying and managing feature requests.
///
/// This widget provides a complete UI including:
/// - Header with close and add buttons
/// - Filter tabs (New, Planned, In Progress, Done)
/// - Feature request list with voting
/// - Create request form
///
/// Example:
/// ```dart
/// FeaturamaScreen(
///   client: FeaturamaClient(apiKey: 'fm_live_xxx'),
///   accentColor: Colors.indigo,
///   brightness: Brightness.light,
///   onClose: () => Navigator.of(context).pop(),
/// )
/// ```
class FeaturamaScreen extends StatefulWidget {
  const FeaturamaScreen({
    super.key,
    required this.client,
    this.accentColor = const Color(0xFF007AFF),
    this.brightness = Brightness.light,
    this.onClose,
    this.strings = const FeaturamaStrings(),
  });

  /// The Featurama API client to use for data fetching.
  final FeaturamaClient client;

  /// Accent color for the UI theme. Defaults to iOS blue (#007AFF).
  final Color accentColor;

  /// Brightness of the UI (light or dark). Defaults to light.
  final Brightness brightness;

  /// Called when the user taps the close button. If null, no close button is shown.
  final VoidCallback? onClose;

  /// Localization strings. Override to customize text.
  final FeaturamaStrings strings;

  @override
  State<FeaturamaScreen> createState() => _FeaturamaScreenState();
}

class _FeaturamaScreenState extends State<FeaturamaScreen> {
  late FeaturamaTheme _theme;
  String _activeFilter = 'new';
  bool _isAdding = false;
  String? _voterId;
  PaginatedResponse<FeatureRequest>? _data;
  bool _isLoading = false;
  String? _error;
  final Set<String> _votingIds = {};
  ProjectConfig? _config;

  bool get _showBranding => _config?.branding.showBranding ?? true;

  @override
  void initState() {
    super.initState();
    _theme = createTheme(widget.accentColor, widget.brightness);
    _initVoterId();
    _loadConfig();
    _loadData();
  }

  @override
  void didUpdateWidget(FeaturamaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accentColor != widget.accentColor || oldWidget.brightness != widget.brightness) {
      _theme = createTheme(widget.accentColor, widget.brightness);
    }
  }

  Future<void> _loadConfig() async {
    try {
      final config = await widget.client.getConfig();
      if (mounted) setState(() => _config = config);
    } catch (_) {
      // Config fetch failed — default to showing branding
    }
  }

  Future<void> _initVoterId() async {
    final id = await getOrCreateVoterId();
    if (mounted) setState(() => _voterId = id);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await widget.client.getRequests(
        pageSize: 50,
        filter: _activeFilter,
      );
      if (mounted) setState(() => _data = result);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit(String title, String description) async {
    if (_voterId == null) return;
    await widget.client.createRequest(
      CreateRequestDto(
        title: title,
        description: description,
        submitterIdentifier: _voterId!,
      ),
    );
    setState(() => _isAdding = false);
    await _loadData();
  }

  Future<void> _handleToggleVote(String requestId) async {
    if (_voterId == null || _votingIds.contains(requestId)) return;
    setState(() => _votingIds.add(requestId));
    try {
      await widget.client.toggleVote(requestId, _voterId!);
      await _loadData();
    } finally {
      if (mounted) setState(() => _votingIds.remove(requestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _theme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Header(
                  theme: _theme,
                  strings: widget.strings,
                  onClose: widget.onClose,
                  onAdd: () => setState(() => _isAdding = true),
                ),
                FilterTabs(
                  theme: _theme,
                  strings: widget.strings,
                  activeFilter: _activeFilter,
                  onFilterChanged: (filter) {
                    setState(() => _activeFilter = filter);
                    _loadData();
                  },
                ),
                const SizedBox(height: 12),
                if (_isAdding)
                  CreateRequestForm(
                    theme: _theme,
                    strings: widget.strings,
                    onSubmit: _handleSubmit,
                    onCancel: () => setState(() => _isAdding = false),
                  ),
                RequestList(
                  theme: _theme,
                  strings: widget.strings,
                  data: _data,
                  isLoading: _isLoading,
                  error: _error,
                  votingIds: _votingIds,
                  onToggleVote: _handleToggleVote,
                  onRefresh: _loadData,
                ),
              ],
            ),
            if (_showBranding)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Branding(theme: _theme),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
