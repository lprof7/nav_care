import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital_payload.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/clinic_creation/viewmodel/clinic_creation_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/clinics/clinic_creation/viewmodel/clinic_creation_state.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/spacing.dart';
import 'package:nav_care_offers_app/presentation/shared/utils/hospitals_refresh_bus.dart';

class ClinicFormPage extends StatelessWidget {
  final String hospitalId;
  final ClinicModel? initial;

  const ClinicFormPage({
    super.key,
    required this.hospitalId,
    this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClinicCreationCubit>(),
      child: _ClinicFormView(hospitalId: hospitalId, initial: initial),
    );
  }
}

class _ClinicFormView extends StatefulWidget {
  final String hospitalId;
  final ClinicModel? initial;

  const _ClinicFormView({
    required this.hospitalId,
    this.initial,
  });

  @override
  State<_ClinicFormView> createState() => _ClinicFormViewState();
}

class _ClinicFormViewState extends State<_ClinicFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  final List<TextEditingController> _phoneControllers = [];
  final List<_SocialField> _socialFields = [];
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _descriptionController = TextEditingController(
        text:
            widget.initial?.description ?? ''); // ClinicModel has 'description'
    _addressController =
        TextEditingController(text: widget.initial?.address ?? '');
    _initPhoneControllers(
      source: widget.initial?.phones ?? const [],
      target: _phoneControllers,
    );
    _initSocialFields();
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

    return BlocConsumer<ClinicCreationCubit, ClinicCreationState>(
      listener: (context, state) {
        if (state is ClinicCreationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'clinics.form.success_update'.tr()
                    : 'clinics.form.success_create'.tr(),
              ),
            ),
          );
          if (!isEditing) {
            HospitalsRefreshBus.notify();
          }
          context.pop(state.clinic);
        } else if (state is ClinicCreationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(state.failure.message ?? 'unknown_error'.tr()),
            ),
          );
        }
      },
      builder: (context, state) {
        final onPrimary = Theme.of(context).colorScheme.onPrimary;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              isEditing
                  ? 'clinics.form.edit_title'.tr()
                  : 'clinics.form.create_title'.tr(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: _requiredLabel('clinics.form.name'.tr()),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'field_required'.tr()
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'clinics.form.description_en'.tr(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: _requiredLabel('clinics.form.address'.tr()),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'field_required'.tr()
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionLabel(label: 'clinics.form.phone_label'.tr()),
                  const SizedBox(height: AppSpacing.sm),
                  ..._buildDynamicTextFields(
                    controllers: _phoneControllers,
                    hint: 'clinics.form.phone_hint'.tr(),
                    onAdd: _addPhoneField,
                    onRemove: (index) => _removeField(
                      index,
                      _phoneControllers,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionLabel(label: 'clinics.form.images.label'.tr()),
                  const SizedBox(height: AppSpacing.sm),
                  ..._selectedImages
                      .map((image) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
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
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
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
                    label: Text('clinics.form.add_image'.tr()),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionLabel(label: 'clinics.form.social.label'.tr()),
                  const SizedBox(height: AppSpacing.sm),
                  ..._buildSocialFields(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _nextAvailableType() == null ? null : _addSocialField,
                      icon: const Icon(Icons.add),
                      label: Text('clinics.form.social.add'.tr()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SafeArea(
                    top: false,
                    child: AppButton(
                      text: state is ClinicCreationLoading
                          ? 'clinics.form.saving'.tr()
                          : 'clinics.form.save'.tr(),
                      icon: state is ClinicCreationLoading
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
                          state is ClinicCreationLoading ? null : () => _submit(context),
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
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllers[i],
                    decoration: InputDecoration(hintText: hint),
                  ),
              ),
              const SizedBox(width: AppSpacing.sm),
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
          label: Text('clinics.form.add_entry'.tr()),
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
      _socialFields
          .add(_SocialField(type: _socialTypes.first, controller: TextEditingController()));
    }
  }

  List<Widget> _buildSocialFields() {
    return List.generate(_socialFields.length, (index) {
      final field = _socialFields[index];
      final available = _availableTypesForField(field);
      if (!available.contains(field.type) && available.isNotEmpty) {
        field.type = available.first;
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: DropdownButtonFormField<String>(
                value: field.type,
                decoration: InputDecoration(
                  labelText: 'clinics.form.social.type_label'.tr(),
                ),
                items: available
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          'clinics.form.social.types.$type'.tr(),
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
                  labelText: 'clinics.form.social.link_label'.tr(),
                  hintText: 'clinics.form.social.link_hint'.tr(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed:
                  _socialFields.length > 1 ? () => _removeSocialField(index) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
          ],
        ),
      );
    });
  }

  void _addSocialField() {
    final next = _nextAvailableType();
    if (next == null) return;
    setState(() {
      _socialFields
          .add(_SocialField(type: next, controller: TextEditingController()));
    });
  }

  void _removeSocialField(int index) {
    setState(() {
      final removed = _socialFields.removeAt(index);
      removed.controller.dispose();
      if (_socialFields.isEmpty) {
        _socialFields.add(
          _SocialField(type: _socialTypes.first, controller: TextEditingController()),
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

  void _removeField(int index, List<TextEditingController> controllers) {
    setState(() {
      final controller = controllers.removeAt(index);
      controller.dispose();
      if (controllers.isEmpty) controllers.add(TextEditingController());
    });
  }

  String _requiredLabel(String text) => '$text *';

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<ClinicCreationCubit>();

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

    if (_selectedImages.isEmpty && (widget.initial?.images ?? []).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('clinics.form.images_required'.tr())),
      );
      return;
    }

    final payload = HospitalPayload(
      id: widget.initial?.id,
      name: _nameController.text.trim(),
      descriptionEn: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      phones: phones,
      images: _selectedImages,
      facilityType: FacilityType.clinic, // This is a clinic form
      hospitalId: widget.hospitalId,
      socialMedia: socialLinks,
    );

    cubit.submitClinic(payload);
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
