import 'package:flutter/widgets.dart';
import '../theme/featurama_theme.dart';
import '../strings/featurama_strings.dart';
import '../icons/featurama_icons.dart';

class CreateRequestForm extends StatefulWidget {
  const CreateRequestForm({
    super.key,
    required this.theme,
    required this.strings,
    required this.onSubmit,
    required this.onCancel,
  });

  final FeaturamaTheme theme;
  final FeaturamaStrings strings;
  final Future<void> Function(String title, String description) onSubmit;
  final VoidCallback onCancel;

  @override
  State<CreateRequestForm> createState() => _CreateRequestFormState();
}

class _CreateRequestFormState extends State<CreateRequestForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocus = FocusNode();
  final _descFocus = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onChanged);
    _descriptionController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(title, _descriptionController.text.trim());
      _titleController.clear();
      _descriptionController.clear();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildInput(TextEditingController controller, FocusNode focusNode, String placeholder, int maxLines) {
    final t = widget.theme;
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: t.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          if (controller.text.isEmpty)
            Text(
              placeholder,
              style: TextStyle(fontSize: 16, color: t.textSecondary, decoration: TextDecoration.none),
            ),
          EditableText(
            controller: controller,
            focusNode: focusNode,
            style: TextStyle(fontSize: 16, color: t.text),
            cursorColor: t.accent,
            backgroundCursorColor: t.secondary,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final s = widget.strings;
    final canSubmit = _titleController.text.trim().isNotEmpty && !_isSubmitting;

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
          children: [
            _buildInput(_titleController, _titleFocus, s.titlePlaceholder, 1),
            _buildInput(_descriptionController, _descFocus, s.descriptionPlaceholder, 3),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: t.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(s.cancel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: t.text, decoration: TextDecoration.none)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: canSubmit ? _handleSubmit : null,
                    child: Opacity(
                      opacity: canSubmit ? 1.0 : 0.5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: t.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SendIcon(size: 16, color: t.accentForeground),
                            const SizedBox(width: 6),
                            Text(s.submit, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: t.accentForeground, decoration: TextDecoration.none)),
                          ],
                        ),
                      ),
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
