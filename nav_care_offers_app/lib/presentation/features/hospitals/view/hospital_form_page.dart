import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital_payload.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_form_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';

class HospitalFormPage extends StatelessWidget {
  final Hospital? initial;

  const HospitalFormPage({super.key, this.initial});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HospitalFormCubit>(param1: initial),
      child: _HospitalFormView(initial: initial),
    );
  }
}

class _HospitalFormView extends StatefulWidget {
  final Hospital? initial;

  const _HospitalFormView({required this.initial});

  @override
  State<_HospitalFormView> createState() => _HospitalFormViewState();
}

class _HospitalFormViewState extends State<_HospitalFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  final List<TextEditingController> _phoneControllers = [];
  final List<_SocialField> _socialFields = [];
  final List<XFile> _selectedImages = []; // Changed to store XFile
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.initial?.descriptionEn ?? '');
    _addressController =
        TextEditingController(text: widget.initial?.address ?? '');
    _initPhoneControllers(
      source: widget.initial?.phones ?? const [],
      target: _phoneControllers,
    );
    _initSocialFields();
    // For existing images, we will not load them into XFile as it's meant for local files.
    // They will be handled by the display logic if widget.initial?.images is not empty.
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    for (final controller in _phoneControllers) {
      controller.dispose();
    }
    for (final field in _socialFields) {
      field.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return BlocConsumer<HospitalFormCubit, HospitalFormState>(
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          messenger.showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        if (state.submissionSuccess && state.lastSaved != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'hospitals.form.success_update'.tr()
                    : 'hospitals.form.success_create'.tr(),
              ),
            ),
          );
          context.pop(true); // Indicate success for refresh
        }
      },
      builder: (context, state) {
        final onPrimary = Theme.of(context).colorScheme.onPrimary;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              isEditing
                  ? 'hospitals.form.edit_title'.tr()
                  : 'hospitals.form.create_title'.tr(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: _requiredLabel('hospitals.form.name'.tr()),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'field_required'.tr()
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText:
                          _requiredLabel('hospitals.form.description_en'.tr()),
                    ),
                    maxLines: 4,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'field_required'.tr()
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: _requiredLabel('hospitals.form.address'.tr()),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'field_required'.tr()
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(label: 'hospitals.form.phone_label'.tr()),
                  const SizedBox(height: 8),
                  ..._buildDynamicTextFields(
                    controllers: _phoneControllers,
                    hint: 'hospitals.form.phone_hint'.tr(),
                    onAdd: _addPhoneField,
                    onRemove: (index) => _removeField(
                      index,
                      _phoneControllers,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'hospitals.form.images.label'.tr()),
                  const SizedBox(height: 8),
                  ..._selectedImages
                      .map((image) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(child: Text(image.name)),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _removeSelectedImage(image),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  if (widget.initial?.images != null &&
                      widget.initial!.images.isNotEmpty)
                    ...widget.initial!.images
                        .map((imageUrl) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(imageUrl
                                          .split('/')
                                          .last)), // Display file name
                                  // No remove button for existing images from API
                                ],
                              ),
                            ))
                        .toList(),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text('hospitals.form.add_image'.tr()),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'hospitals.form.social.label'.tr()),
                  const SizedBox(height: 8),
                  ..._buildSocialFields(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed:
                          _nextAvailableType() == null ? null : _addSocialField,
                      icon: const Icon(Icons.add),
                      label: Text('hospitals.form.social.add'.tr()),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SafeArea(
                    top: false,
                    child: AppButton(
                      text: state.isSubmitting
                          ? 'hospitals.form.saving'.tr()
                          : 'hospitals.form.save'.tr(),
                      icon: state.isSubmitting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: onPrimary,
                              ),
                            )
                          : const Icon(Icons.check_outlined),
                      onPressed:
                          state.isSubmitting ? null : () => _submit(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _initPhoneControllers({
    required List<String> source,
    required List<TextEditingController> target,
  }) {
    if (source.isEmpty) {
      target.add(TextEditingController());
      return;
    }
    for (final value in source) {
      target.add(TextEditingController(text: value));
    }
  }

  List<Widget> _buildDynamicTextFields({
    required List<TextEditingController> controllers,
    required String hint,
    required VoidCallback onAdd,
    required void Function(int index) onRemove,
  }) {
    final fields = <Widget>[];
    for (var i = 0; i < controllers.length; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllers[i],
                  decoration: InputDecoration(hintText: hint),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: controllers.length > 1 ? () => onRemove(i) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ],
          ),
        ),
      );
    }
    fields.add(
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text('hospitals.form.add_entry'.tr()),
        ),
      ),
    );
    return fields;
  }

  void _addPhoneField() {
    setState(() => _phoneControllers.add(TextEditingController()));
  }

  void _initSocialFields() {
    if (_socialFields.isEmpty) {
      _socialFields.add(
        _SocialField(
          type: _socialTypes.first,
          controller: TextEditingController(),
        ),
      );
    }
  }

  List<Widget> _buildSocialFields() {
    return List.generate(_socialFields.length, (index) {
      final field = _socialFields[index];
      final availableTypes = _availableTypesForField(field);
      if (!availableTypes.contains(field.type) && availableTypes.isNotEmpty) {
        field.type = availableTypes.first;
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: DropdownButtonFormField<String>(
                value: field.type,
                decoration: InputDecoration(
                  labelText: 'hospitals.form.social.type_label'.tr(),
                ),
                items: availableTypes
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          'hospitals.form.social.types.$type'.tr(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => field.type = value);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: field.controller,
                decoration: InputDecoration(
                  labelText: 'hospitals.form.social.link_label'.tr(),
                  hintText: 'hospitals.form.social.link_hint'.tr(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _socialFields.length > 1
                  ? () => _removeSocialField(index)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
          ],
        ),
      );
    });
  }

  void _addSocialField() {
    final nextType = _nextAvailableType();
    if (nextType == null) return;
    setState(() {
      _socialFields.add(
        _SocialField(
          type: nextType,
          controller: TextEditingController(),
        ),
      );
    });
  }

  void _removeSocialField(int index) {
    setState(() {
      final removed = _socialFields.removeAt(index);
      removed.controller.dispose();
      if (_socialFields.isEmpty) {
        _socialFields.add(
          _SocialField(
            type: _nextAvailableType() ?? _socialTypes.first,
            controller: TextEditingController(),
          ),
        );
      }
    });
  }

  List<String> _availableTypesForField(_SocialField current) {
    final used = _socialFields.where((f) => f != current).map((f) => f.type).toSet();
    return _socialTypes.where((t) => !used.contains(t) || t == current.type).toList();
  }

  String? _nextAvailableType() {
    final used = _socialFields.map((f) => f.type).toSet();
    try {
      return _socialTypes.firstWhere((t) => !used.contains(t));
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(pickedFile);
      });
    }
  }

  void _removeSelectedImage(XFile image) {
    setState(() {
      _selectedImages.remove(image);
    });
  }

  String _requiredLabel(String text) => '$text *';

  void _removeField(int index, List<TextEditingController> controllers) {
    setState(() {
      final controller = controllers.removeAt(index);
      controller.dispose();
      if (controllers.isEmpty) controllers.add(TextEditingController());
    });
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<HospitalFormCubit>();

    final phones = _phoneControllers
        .map((controller) => controller.text.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    final socialLinks = _socialFields
        .map((field) {
          final link = field.controller.text.trim();
          if (link.isEmpty) return null;
          return SocialMediaLink(type: field.type, link: link);
        })
        .whereType<SocialMediaLink>()
        .toList();

    if (_selectedImages.isEmpty && cubit.state.isSubmitting) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('hospitals.form.images_required'.tr())),
      );
      return;
    }

    final payload = HospitalPayload(
      id: widget.initial?.id,
      name: _nameController.text.trim(),
      descriptionEn: _descriptionController.text.trim(),
      address: _addressController.text.trim(), // Added address
      phones: phones,
      // Coordinates will be set to 0,0 in HospitalPayload
      // FacilityType will be set to Hospital in HospitalPayload
      images: _selectedImages, // Pass XFile list directly
      socialMedia: socialLinks,
    );

    cubit.submit(payload);
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SocialField {
  String type;
  final TextEditingController controller;

  _SocialField({required this.type, required this.controller});
}

const _socialTypes = [
  'facebook',
  'instagram',
  'youtube',
  'x',
  'linkedin',
  'other',
];
