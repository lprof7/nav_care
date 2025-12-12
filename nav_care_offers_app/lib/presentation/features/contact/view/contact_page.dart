import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  static const _messageMaxLength = 255;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  int get _remaining =>
      _messageMaxLength - (_messageCtrl.text.characters.length);

  bool get _canSubmit =>
      _remaining >= 0 && _messageCtrl.text.trim().isNotEmpty;

  void _onSubmit() {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('contact.submit_placeholder'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subtle = theme.textTheme.bodyMedium?.color?.withOpacity(0.75);

    return Scaffold(
      appBar: AppBar(
        title: Text('contact.title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'contact.heading'.tr(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'contact.subtitle'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: subtle,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _TextField(
                          controller: _firstNameCtrl,
                          hint: 'contact.first_name'.tr(),
                        ),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _lastNameCtrl,
                          hint: 'contact.last_name'.tr(),
                        ),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _emailCtrl,
                          hint: 'contact.email'.tr(),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _phoneCtrl,
                          hint: 'contact.phone'.tr(),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TextField(
                              controller: _messageCtrl,
                              hint: 'contact.message'.tr(),
                              maxLines: 5,
                              maxLength: _messageMaxLength,
                              onChanged: (_) => setState(() {}),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'contact.remaining'
                                    .tr(namedArgs: {'count': _remaining.toString()}),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: subtle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _canSubmit ? _onSubmit : null,
                            icon: const Icon(Icons.send_rounded),
                            label: Text('contact.send'.tr()),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.4),
          ),
        ),
      ),
      inputFormatters: maxLength != null
          ? [LengthLimitingTextInputFormatter(maxLength)]
          : null,
    );
  }
}
