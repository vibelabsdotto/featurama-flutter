import 'package:flutter/cupertino.dart';

import '../featurama_client.dart';
import '../exceptions/featurama_exception.dart';
import 'components/request_detail.dart';
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
    required this.client,
    super.key,
    this.accentColor = const Color(0xFF007AFF),
    this.brightness = Brightness.light,
    this.onClose,
    this.strings = const FeaturamaStrings(),
    this.submitterIdentifier,
  });

  /// The Featurama API client to use for data fetching.
  final FeaturamaClient client;

  /// Accent color for the UI theme. Defaults to iOS blue (#007AFF).
  final Color accentColor;

  /// Brightness of the UI (light or dark). Defaults to light.
  final Brightness brightness;

  /// Called when the user taps close. If null, no close button is shown.
  final VoidCallback? onClose;

  /// Localization strings. Override to customize text.
  final FeaturamaStrings strings;

  /// Uses this identity for listing, submission and voting. If omitted, a
  /// persistent installation-specific identifier is generated locally.
  final String? submitterIdentifier;

  @override
  State<FeaturamaScreen> createState() => _FeaturamaScreenState();
}

class _FeaturamaScreenState extends State<FeaturamaScreen> {
  late FeaturamaTheme _theme;
  String _activeFilter = 'new';
  bool _isAdding = false;
  bool _isSubmitting = false;
  FeatureRequest? _selected;
  String? _voterId;
  PaginatedResponse<FeatureRequest>? _data;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String? _voteError;
  final Set<String> _votingIds = {};
  ProjectConfig? _config;
  bool _isConfigLoading = true;
  int _sessionVersion = 0;
  int _loadVersion = 0;
  int _configVersion = 0;
  int _identityVersion = 0;

  bool get _showBranding => _config?.branding.showBranding ?? true;

  @override
  void initState() {
    super.initState();
    _theme = createTheme(widget.accentColor, widget.brightness);
    _initVoterId();
    _loadConfig();
  }

  @override
  void didUpdateWidget(FeaturamaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _theme = createTheme(widget.accentColor, widget.brightness);
    if (oldWidget.client != widget.client ||
        oldWidget.submitterIdentifier != widget.submitterIdentifier) {
      _sessionVersion++;
      _loadVersion++;
      _voterId = null;
      _data = null;
      _config = null;
      _error = null;
      _voteError = null;
      _isAdding = false;
      _isSubmitting = false;
      _selected = null;
      _isLoading = true;
      _isLoadingMore = false;
      _votingIds.clear();
      _initVoterId();
      _loadConfig();
    }
  }

  Future<void> _loadConfig() async {
    if (!mounted) return;
    final version = ++_configVersion;
    setState(() => _isConfigLoading = true);
    try {
      final config = await widget.client.getConfig();
      if (mounted && version == _configVersion) {
        setState(() => _config = config);
      }
    } catch (_) {
      if (mounted && version == _configVersion) {
        setState(() => _config = null);
      }
    } finally {
      if (mounted && version == _configVersion) {
        setState(() => _isConfigLoading = false);
      }
    }
  }

  Future<void> _initVoterId() async {
    if (!mounted) return;
    final version = ++_identityVersion;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final id = widget.submitterIdentifier ?? await getOrCreateVoterId();
      if (!mounted || version != _identityVersion) return;
      if (id.trim().isEmpty) throw StateError('Empty submitter identifier');
      setState(() => _voterId = id);
      await _loadData();
    } catch (_) {
      if (mounted && version == _identityVersion) {
        setState(() {
          _error = widget.strings.error;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    await Future.wait([
      _loadConfig(),
      _voterId == null ? _initVoterId() : _loadData(),
    ]);
  }

  Future<void> _loadData({bool loadMore = false}) async {
    if (!mounted || _voterId == null) return;
    if (loadMore &&
        (_isLoading || _isLoadingMore || !(_data?.hasNextPage ?? false))) {
      return;
    }
    final version = ++_loadVersion;
    final previous = _data;
    final page = loadMore ? previous!.page + 1 : 1;
    setState(() {
      _isLoading = !loadMore;
      _isLoadingMore = loadMore;
      _error = null;
    });
    try {
      final result = await widget.client.getRequests(
        page: page,
        pageSize: 20,
        filter: _activeFilter,
        submitterIdentifier: _voterId!,
      );
      if (!mounted || version != _loadVersion) return;
      final items = <String, FeatureRequest>{
        if (loadMore)
          for (final item in previous!.items) item.id: item,
        for (final item in result.items) item.id: item,
      };
      setState(() {
        _data = PaginatedResponse(
          items: items.values.toList(),
          totalCount: result.totalCount,
          page: result.page,
          pageSize: result.pageSize,
        );
      });
    } catch (error) {
      if (mounted && version == _loadVersion) {
        setState(() => _error = error is UnauthorizedException
            ? widget.strings.authError
            : widget.strings.error);
      }
    } finally {
      if (mounted && version == _loadVersion) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _handleSubmit(
    String title,
    String description,
    String? email,
  ) async {
    if (_voterId == null || _config == null || _isConfigLoading) {
      throw StateError('Submission settings are not ready');
    }
    final session = _sessionVersion;
    await widget.client.createRequest(
      CreateRequestDto(
        title: title,
        description: description,
        submitterIdentifier: _voterId!,
        email: email,
      ),
    );
    if (!mounted || session != _sessionVersion) return;
    setState(() {
      _isAdding = false;
      _isSubmitting = false;
      _activeFilter = 'new';
      _data = null;
      _voteError = null;
    });
    await _loadData();
  }

  Future<void> _handleToggleVote(String requestId) async {
    if (!mounted || _voterId == null || _votingIds.contains(requestId)) return;
    final requests = _data?.items.where((item) => item.id == requestId);
    if (requests == null || requests.isEmpty || !requests.first.isApproved) {
      return;
    }
    final request = requests.first;
    final session = _sessionVersion;
    setState(() {
      _votingIds.add(requestId);
      _voteError = null;
    });
    try {
      if (request.hasVoted) {
        await widget.client.removeVote(requestId, _voterId!);
      } else {
        await widget.client.vote(requestId, _voterId!);
      }
      if (mounted && session == _sessionVersion) {
        await _loadData();
      }
    } catch (_) {
      if (mounted && session == _sessionVersion) {
        setState(() => _voteError = widget.strings.voteError);
      }
    } finally {
      if (mounted && session == _sessionVersion) {
        setState(() => _votingIds.remove(requestId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _sessionVersion;
    if (_selected != null && _voterId != null) {
      return RequestDetail(
        key: ValueKey('$session:${_selected!.id}'),
        client: widget.client,
        request: _selected!,
        viewer: _voterId!,
        showBranding: _showBranding,
        theme: _theme,
        strings: widget.strings,
        onBack: () {
          if (!mounted || session != _sessionVersion) return;
          setState(() => _selected = null);
          _loadData();
        },
        onChanged: (updated) {
          if (!mounted || session != _sessionVersion) return;
          setState(() => _selected = updated);
        },
      );
    }
    return Container(
      color: _theme.background,
      child: SafeArea(
        child: Column(
          children: [
            Header(
              theme: _theme,
              strings: widget.strings,
              onClose: _isSubmitting ? null : widget.onClose,
              onAdd: _voterId == null || _isAdding
                  ? null
                  : () => setState(() => _isAdding = true),
            ),
            FilterTabs(
              theme: _theme,
              strings: widget.strings,
              activeFilter: _activeFilter,
              onFilterChanged: (filter) {
                if (filter == _activeFilter) return;
                setState(() {
                  _activeFilter = filter;
                  _data = null;
                  _voteError = null;
                });
                _loadData();
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  children: [
                    if (_isAdding)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * 0.6,
                        ),
                        child: SingleChildScrollView(
                          child: CreateRequestForm(
                            key: ValueKey(_sessionVersion),
                            theme: _theme,
                            strings: widget.strings,
                            emailCollection: _config?.emailCollection ?? 'none',
                            enabled: _config != null && !_isConfigLoading,
                            settingsMessage: _isConfigLoading
                                ? widget.strings.loading
                                : _config == null
                                    ? widget.strings.configError
                                    : null,
                            onRetrySettings:
                                _isConfigLoading ? null : _loadConfig,
                            onBusyChanged: (busy) {
                              if (mounted && session == _sessionVersion) {
                                setState(() => _isSubmitting = busy);
                              }
                            },
                            onSubmit: (title, description, email) {
                              if (!mounted || session != _sessionVersion) {
                                throw StateError('Viewer changed');
                              }
                              return _handleSubmit(title, description, email);
                            },
                            onCancel: () => setState(() => _isAdding = false),
                          ),
                        ),
                      ),
                    if (_voteError != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _voteError!,
                            style: TextStyle(
                              color: _theme.text,
                              fontSize: 14,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    RequestList(
                      theme: _theme,
                      strings: widget.strings,
                      data: _data,
                      isLoading: _isLoading,
                      isLoadingMore: _isLoadingMore,
                      error: _error,
                      votingIds: _votingIds,
                      onToggleVote: _handleToggleVote,
                      onOpen: _isAdding || _votingIds.isNotEmpty
                          ? null
                          : (request) {
                              if (!mounted || session != _sessionVersion) {
                                return;
                              }
                              setState(() => _selected = request);
                            },
                      onRefresh: _refresh,
                      onLoadMore: () => _loadData(loadMore: true),
                    ),
                  ],
                ),
              ),
            ),
            if (_showBranding)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Center(child: Branding(theme: _theme)),
              ),
          ],
        ),
      ),
    );
  }
}
