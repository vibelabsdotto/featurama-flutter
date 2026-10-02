import 'package:flutter/cupertino.dart';

import '../theme/featurama_theme.dart';
import '../../exceptions/featurama_exception.dart';
import '../strings/featurama_strings.dart';
import '../icons/featurama_icons.dart';

class CreateRequestForm extends StatefulWidget {
  const CreateRequestForm({
    required this.theme,
    required this.strings,
    required this.onSubmit,
    required this.onCancel,
    super.key,
    this.emailCollection = 'none',
    this.enabled = true,
    this.settingsMessage,
    this.onRetrySettings,
    this.initialTitle = '',
    this.initialDescription = '',
    this.submitLabel,
    this.errorLabel,
    this.onBusyChanged,
  });

  final FeaturamaTheme theme;
  final FeaturamaStrings strings;
  final Future<void> Function(String title, String description, String? email)
      onSubmit;
  final VoidCallback onCancel;
  final String emailCollection;
  final bool enabled;
  final String? settingsMessage;
  final VoidCallback? onRetrySettings;
  final String initialTitle;
  final String initialDescription;
  final String? submitLabel;
  final String? errorLabel;
  final ValueChanged<bool>? onBusyChanged;

  @override
  State<CreateRequestForm> createState() => _CreateRequestFormState();
}

class _CreateRequestFormState extends State<CreateRequestForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  bool get _collectEmail =>
      widget.emailCollection == 'optional' ||
      widget.emailCollection == 'required';

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _descriptionController.text = widget.initialDescription;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting || !widget.enabled) return;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final email = _collectEmail ? _emailController.text.trim() : '';
    if (title.isEmpty || description.isEmpty) {
      setState(() => _error = widget.strings.requiredFields);
      return;
    }
    if (title.length > 200 || description.length > 5000) {
      setState(() => _error = widget.strings.requestTooLong);
      return;
    }
    if ((widget.emailCollection == 'required' && email.isEmpty) ||
        (email.isNotEmpty &&
            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email))) {
      setState(() => _error = widget.strings.invalidEmail);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    widget.onBusyChanged?.call(true);
    try {
      await widget.onSubmit(title, description, email.isEmpty ? null : email);
      if (!mounted) return;
      _titleController.clear();
      _descriptionController.clear();
      _emailController.clear();
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is UnauthorizedException
            ? widget.strings.authError
            : widget.errorLabel ?? widget.strings.submitError);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
        widget.onBusyChanged?.call(false);
      }
    }
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    int maxLines, {
    bool email = false,
  }) {
    final t = widget.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        label: label,
        child: CupertinoTextField(
          controller: controller,
          placeholder: label,
          placeholderStyle: TextStyle(fontSize: 16, color: t.textSecondary),
          style: TextStyle(fontSize: 16, color: t.text),
          cursorColor: t.accent,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          maxLines: maxLines,
          enabled: !_isSubmitting,
          keyboardType: email
              ? TextInputType.emailAddress
              : maxLines > 1
                  ? TextInputType.multiline
                  : TextInputType.text,
          textInputAction:
              maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
          textCapitalization:
              email ? TextCapitalization.none : TextCapitalization.sentences,
          autocorrect: !email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final s = widget.strings;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.borderAccent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInput(_titleController, s.titlePlaceholder, 1),
            _buildInput(_descriptionController, s.descriptionPlaceholder, 3),
            if (_collectEmail)
              _buildInput(
                _emailController,
                widget.emailCollection == 'required'
                    ? s.emailRequired
                    : s.emailOptional,
                1,
                email: true,
              ),
            if (widget.settingsMessage != null) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  widget.settingsMessage!,
                  style: TextStyle(
                    color: t.textSecondary,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              if (widget.onRetrySettings != null)
                CupertinoButton(
                  onPressed: widget.onRetrySettings,
                  child: Text(s.retry, style: TextStyle(color: t.accent)),
                ),
              const SizedBox(height: 12),
            ],
            if (_error != null) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: t.text,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: t.secondary,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: _isSubmitting ? null : widget.onCancel,
                    child: Text(
                      s.cancel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: t.text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: t.accent,
                    disabledColor: t.accent.withAlpha(128),
                    borderRadius: BorderRadius.circular(8),
                    onPressed:
                        widget.enabled && !_isSubmitting ? _handleSubmit : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isSubmitting)
                          CupertinoActivityIndicator(color: t.accentForeground)
                        else
                          SendIcon(size: 16, color: t.accentForeground),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _isSubmitting
                                ? s.loading
                                : widget.submitLabel ?? s.submit,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: t.accentForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
