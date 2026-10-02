import 'package:flutter/cupertino.dart';

import '../../exceptions/featurama_exception.dart';
import '../../featurama_client.dart';
import '../../models/comment.dart';
import '../../models/feature_request.dart';
import '../../models/update_request_dto.dart';
import '../strings/featurama_strings.dart';
import '../theme/featurama_theme.dart';
import 'create_request_form.dart';
import 'branding.dart';

/// Internal, identity-keyed detail view. The screen replaces this entire state
/// whenever the client, viewer or selected request changes.
class RequestDetail extends StatefulWidget {
  const RequestDetail({
    required this.client,
    required this.request,
    required this.viewer,
    required this.theme,
    required this.strings,
    required this.onBack,
    required this.onChanged,
    required this.showBranding,
    super.key,
  });

  final FeaturamaClient client;
  final FeatureRequest request;
  final String viewer;
  final FeaturamaTheme theme;
  final FeaturamaStrings strings;
  final VoidCallback onBack;
  final ValueChanged<FeatureRequest> onChanged;
  final bool showBranding;

  @override
  State<RequestDetail> createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetail> {
  final _comment = TextEditingController();
  late FeatureRequest _request;
  List<Comment> _comments = [];
  int _visibleCount = 20;
  int _loadVersion = 0;
  bool _loading = true;
  bool _sending = false;
  bool _editing = false;
  bool _saving = false;
  String? _voting;
  String? _loadError;
  String? _actionError;
  String? _notice;

  bool get _owner =>
      widget.viewer.isNotEmpty && _request.submitterIdentifier == widget.viewer;
  bool get _busy => _sending || _saving || _voting != null;
  bool get _canComment => _request.isApproved || _owner;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
    _loadComments();
  }

  @override
  void dispose() {
    _loadVersion++;
    _comment.dispose();
    super.dispose();
  }

  String _message(Object error, String fallback) =>
      error is UnauthorizedException ? widget.strings.authError : fallback;

  Future<void> _loadComments() async {
    if (!mounted || _busy) return;
    final version = ++_loadVersion;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final comments = await widget.client.getComments(_request.id);
      if (!mounted || version != _loadVersion) return;
      if (comments.any((c) => c.featureRequestId != _request.id)) {
        throw StateError('Unexpected discussion response');
      }
      setState(() {
        _comments = {for (final c in comments) c.id: c}.values.toList();
        _visibleCount = 20;
      });
    } catch (error) {
      if (mounted && version == _loadVersion) {
        setState(
            () => _loadError = _message(error, widget.strings.commentsError));
      }
    } finally {
      if (mounted && version == _loadVersion) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _save(String title, String description, String? _) async {
    if (!mounted || !_owner || _sending || _voting != null) {
      throw StateError('Request is no longer editable');
    }
    final updated = await widget.client.updateRequest(
      _request.id,
      UpdateRequestDto(title: title, description: description),
      widget.viewer,
    );
    if (!mounted) throw StateError('Viewer changed');
    if (updated.id != _request.id || updated.projectId != _request.projectId) {
      throw StateError('Unexpected request response');
    }
    // Update responses omit viewer vote state. Preserve the last listing state.
    final merged = FeatureRequest.fromJson({
      ...updated.toJson(),
      'hasVoted': _request.hasVoted,
    });
    setState(() {
      _request = merged;
      _editing = false;
      _saving = false;
    });
    widget.onChanged(merged);
  }

  Future<void> _sendComment() async {
    if (!mounted || _busy || _loading || !_canComment) return;
    final content = _comment.text.trim();
    if (content.isEmpty || content.length > 2000) {
      setState(() => _actionError = content.isEmpty
          ? widget.strings.commentRequired
          : widget.strings.commentTooLong);
      return;
    }
    // Invalidate any pre-mutation read before accepting a new local record.
    _loadVersion++;
    setState(() {
      _sending = true;
      _actionError = null;
      _notice = null;
    });
    try {
      final created = await widget.client.addComment(
        _request.id,
        content: content,
        authorIdentifier: widget.viewer,
      );
      if (!mounted) return;
      if (created.featureRequestId != _request.id) {
        throw StateError('Unexpected comment response');
      }
      setState(() {
        _comments = {
          ...{for (final c in _comments) c.id: c},
          created.id: created
        }.values.toList();
        _visibleCount = _comments.length;
        _comment.clear();
        _notice = widget.strings.commentSent;
      });
    } catch (error) {
      if (mounted) {
        setState(
            () => _actionError = _message(error, widget.strings.commentError));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleVote(Comment comment) async {
    if (!mounted || _busy || _loading || !_request.isApproved) return;
    setState(() {
      _voting = comment.id;
      _actionError = null;
      _notice = null;
    });
    try {
      Comment updated;
      // The public comment API has no viewer vote state. A duplicate-vote 409
      // is its toggle signal. Never send the follow-up for a disposed identity.
      try {
        updated = await widget.client.voteComment(
          _request.id,
          comment.id,
          widget.viewer,
        );
      } on ConflictException {
        if (!mounted) return;
        updated = await widget.client.removeCommentVote(
          _request.id,
          comment.id,
          widget.viewer,
        );
      }
      if (!mounted) return;
      if (updated.id != comment.id || updated.featureRequestId != _request.id) {
        throw StateError('Unexpected comment vote response');
      }
      setState(() => _comments = [
            for (final c in _comments) c.id == updated.id ? updated : c,
          ]);
    } catch (error) {
      if (mounted) {
        setState(
            () => _actionError = _message(error, widget.strings.voteError));
      }
    } finally {
      if (mounted) setState(() => _voting = null);
    }
  }

  Widget _text(String text, {bool heading = false, bool live = false}) =>
      Semantics(
        header: heading,
        liveRegion: live,
        child: Text(text,
            style: TextStyle(
              color: widget.theme.text,
              fontSize: heading ? 20 : 15,
              fontWeight: heading ? FontWeight.w600 : FontWeight.normal,
              height: 1.4,
              decoration: TextDecoration.none,
            )),
      );

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final t = widget.theme;
    return PopScope(
      canPop: !_busy,
      child: Container(
        color: t.background,
        child: SafeArea(
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
                onPressed: _busy ? null : widget.onBack,
                child: Text(s.back, style: TextStyle(color: t.accent)),
              ),
            ),
            Expanded(
                child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                _text(_request.title, heading: true),
                const SizedBox(height: 8),
                _text(_request.description),
                const SizedBox(height: 8),
                _text(!_request.isApproved
                    ? s.badgePending
                    : switch (_request.status) {
                        FeatureRequestStatus.requested => s.filterNew,
                        FeatureRequestStatus.roadmap => s.badgePlanned,
                        FeatureRequestStatus.inProgress => s.filterInProgress,
                        FeatureRequestStatus.done => s.filterDone,
                        FeatureRequestStatus.declined => _request.status.value,
                      }),
                if (!_request.isApproved) ...[
                  const SizedBox(height: 8),
                  _text(s.pendingDiscussion),
                ],
                if (_owner && !_editing)
                  Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        onPressed: _busy
                            ? null
                            : () => setState(() => _editing = true),
                        child: Text(s.editRequest,
                            style: TextStyle(color: t.accent)),
                      )),
                if (_editing)
                  CreateRequestForm(
                    theme: t,
                    strings: s,
                    initialTitle: _request.title,
                    initialDescription: _request.description,
                    submitLabel: s.saveChanges,
                    errorLabel: s.editError,
                    onBusyChanged: (value) {
                      if (mounted) setState(() => _saving = value);
                    },
                    onSubmit: _save,
                    onCancel: () => setState(() => _editing = false),
                  ),
                const SizedBox(height: 16),
                _text(s.comments, heading: true),
                Align(
                    alignment: Alignment.centerLeft,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      onPressed: _busy || _loading ? null : _loadComments,
                      child: Text(s.refresh, style: TextStyle(color: t.accent)),
                    )),
                if (_loading)
                  Semantics(
                      label: s.loading,
                      liveRegion: true,
                      child: const CupertinoActivityIndicator()),
                if (_loadError != null) ...[
                  _text(_loadError!, live: true),
                  CupertinoButton(
                    onPressed: _busy || _loading ? null : _loadComments,
                    child: Text(s.retry, style: TextStyle(color: t.accent)),
                  ),
                ],
                if (!_loading && _loadError == null && _comments.isEmpty)
                  _text(s.noComments),
                for (final c in _comments.take(_visibleCount))
                  Container(
                    key: ValueKey(c.id),
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.card,
                      border: Border.all(color: t.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _text(c.authorName?.isNotEmpty == true
                              ? c.authorName!
                              : c.authorRole == 'developer'
                                  ? s.teamAuthor
                                  : s.anonymousAuthor),
                          const SizedBox(height: 6),
                          _text(c.content),
                          Semantics(
                            container: true,
                            label: '${s.toggleCommentVote}: ${c.content}',
                            value: '${c.voteCount}',
                            button: true,
                            enabled: !_busy && !_loading && _request.isApproved,
                            excludeSemantics: true,
                            onTap: !_busy && !_loading && _request.isApproved
                                ? () => _toggleVote(c)
                                : null,
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              onPressed:
                                  !_busy && !_loading && _request.isApproved
                                      ? () => _toggleVote(c)
                                      : null,
                              child: Text(
                                  '${s.toggleCommentVote} (${c.voteCount})',
                                  style: TextStyle(
                                    color: !_busy &&
                                            !_loading &&
                                            _request.isApproved
                                        ? t.accent
                                        : t.textSecondary,
                                  )),
                            ),
                          ),
                        ]),
                  ),
                if (_visibleCount < _comments.length)
                  CupertinoButton(
                    onPressed: () => setState(() => _visibleCount += 20),
                    child: Text(s.loadMore, style: TextStyle(color: t.accent)),
                  ),
                const SizedBox(height: 16),
                if (_canComment && !_editing) ...[
                  Semantics(
                    label: s.commentPlaceholder,
                    child: CupertinoTextField(
                      controller: _comment,
                      placeholder: s.commentPlaceholder,
                      maxLines: 3,
                      enabled: !_busy,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(color: t.text),
                      placeholderStyle: TextStyle(color: t.textSecondary),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: t.secondary,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: _busy || _loading ? null : _sendComment,
                    child: Text(_sending ? s.loading : s.addComment,
                        style: TextStyle(color: t.accent)),
                  ),
                ],
                if (_actionError != null) _text(_actionError!, live: true),
                if (_notice != null) _text(_notice!, live: true),
              ],
            )),
            if (widget.showBranding)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(child: Branding(theme: t)),
              ),
          ]),
        ),
      ),
    );
  }
}
