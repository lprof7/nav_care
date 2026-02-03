import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl_phone_field/countries.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital_payload.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_form_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/utils/hospitals_refresh_bus.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/atoms/app_button.dart';
import 'package:nav_care_offers_app/presentation/shared/theme/colors.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/network_image.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/molecules/phone_number_field.dart';
import 'package:nav_care_offers_app/core/routing/app_router.dart';

class HospitalFormPage extends StatelessWidget {
  final Hospital? initial;
  final bool isClinicContext;

  const HospitalFormPage(
      {super.key, this.initial, this.isClinicContext = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HospitalFormCubit>(param1: initial),
      child: _HospitalFormView(
        initial: initial,
        isClinicContext: isClinicContext,
      ),
    );
  }
}

class _HospitalFormView extends StatefulWidget {
  final Hospital? initial;
  final bool isClinicContext;

  const _HospitalFormView({
    required this.initial,
    required this.isClinicContext,
  });

  @override
  State<_HospitalFormView> createState() => _HospitalFormViewState();
}

class _HospitalFormViewState extends State<_HospitalFormView> {
  static const _defaultCountryCode = 'DZ';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _descriptionArController;
  late final TextEditingController _descriptionFrController;
  late final TextEditingController _addressController;
  FacilityType _facilityType = FacilityType.hospital;
  final List<TextEditingController> _phoneControllers = [];
  final List<String?> _completePhoneNumbers = [];
  final List<String> _phoneCountryCodes = [];
  final List<_SocialField> _socialFields = [];
  final List<XFile> _selectedImages = []; // Changed to store XFile
  final List<String> _existingImages = [];
  final List<String> _deletedImages = [];
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  bool _isDeleting = false;
  bool _showTranslationFields = false;

  String get _prefix => widget.isClinicContext ? 'clinics' : 'hospitals';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.initial?.descriptionEn ?? '');
    _descriptionArController =
        TextEditingController(text: widget.initial?.descriptionAr ?? '');
    _descriptionFrController =
        TextEditingController(text: widget.initial?.descriptionFr ?? '');
    _addressController =
        TextEditingController(text: widget.initial?.address ?? '');
    _facilityType = widget.initial?.facilityType ?? FacilityType.hospital;
    _initPhoneControllers(
      source: widget.initial?.phones ?? const [],
      target: _phoneControllers,
    );
    _initSocialFields();
    // For existing images, we will not load them into XFile as it's meant for local files.
    // They will be handled by the display logic if widget.initial?.images is not empty.
    _existingImages.addAll(widget.initial?.images ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _descriptionFrController.dispose();
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
    final baseUrl = sl<AppConfig>().api.baseUrl;

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
                    ? '$_prefix.form.success_update'.tr()
                    : '$_prefix.form.success_create'.tr(),
              ),
            ),
          );
          HospitalsRefreshBus.notify();
          context.pop(state.lastSaved);
        }
      },
      builder: (context, state) {
        final onPrimary = Theme.of(context).colorScheme.onPrimary;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              isEditing
                  ? '$_prefix.form.edit_title'.tr()
                  : '$_prefix.form.create_title'.tr(),
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
                      labelText: _requiredLabel('$_prefix.form.name'.tr()),
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
                          _requiredLabel('$_prefix.form.description_en'.tr()),
                    ),
                    maxLines: 4,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'field_required'.tr()
                        : null,
                  ),
                  const SizedBox(height: 12),
                  // Expandable Advanced Translations Section
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        '$_prefix.form.advanced_translations'.tr(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      initiallyExpanded: _showTranslationFields,
                      onExpansionChanged: (expanded) {
                        setState(() => _showTranslationFields = expanded);
                      },
                      children: [
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionArController,
                          decoration: InputDecoration(
                            labelText: '$_prefix.form.description_ar'.tr(),
                            hintText: '$_prefix.form.description_ar_hint'.tr(),
                          ),
                          maxLines: 3,
                          textDirection: ui.TextDirection.rtl,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionFrController,
                          decoration: InputDecoration(
                            labelText: '$_prefix.form.description_fr'.tr(),
                            hintText: '$_prefix.form.description_fr_hint'.tr(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!isEditing) ...[
                    DropdownButtonFormField<FacilityType>(
                      value: _facilityType,
                      decoration: InputDecoration(
                        labelText: _requiredLabel(
                            '$_prefix.form.facility_type.label'.tr()),
                      ),
                      items: [
                        FacilityType.hospital,
                        FacilityType.clinic,
                      ]
                          .map(
                            (type) => DropdownMenuItem<FacilityType>(
                              value: type,
                              child: Text(type
                                  .translationKey('$_prefix.facility_type')
                                  .tr()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _facilityType = value);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: _requiredLabel('$_prefix.form.address'.tr()),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'field_required'.tr()
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(label: '$_prefix.form.phone_label'.tr()),
                  const SizedBox(height: 8),
                  ..._buildDynamicTextFields(
                    controllers: _phoneControllers,
                    hint: '$_prefix.form.phone_hint'.tr(),
                    onAdd: _addPhoneField,
                    onRemove: (index) => _removeField(
                      index,
                      _phoneControllers,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: '$_prefix.form.images.label'.tr()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ..._existingImages.map(
                        (imageUrl) => _buildNetworkImageTile(
                          baseUrl: baseUrl,
                          imageUrl: imageUrl,
                          onRemove: () => _removeExistingImage(imageUrl),
                        ),
                      ),
                      ..._selectedImages.map(
                        (image) => _buildLocalImageTile(
                          image: image,
                          onRemove: () => _removeSelectedImage(image),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text('$_prefix.form.add_image'.tr()),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: '$_prefix.form.social.label'.tr()),
                  const SizedBox(height: 8),
                  ..._buildSocialFields(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed:
                          _nextAvailableType() == null ? null : _addSocialField,
                      icon: const Icon(Icons.add),
                      label: Text('$_prefix.form.social.add'.tr()),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppButton(
                          text: state.isSubmitting
                              ? '$_prefix.form.saving'.tr()
                              : '$_prefix.form.save'.tr(),
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
                          onPressed: state.isSubmitting
                              ? null
                              : () => _submit(context),
                        ),
                        if (isEditing) ...[
                          const SizedBox(height: 12),
                          AppButton(
                            text: '$_prefix.detail.delete'.tr(),
                            color: AppColors.error,
                            textColor: AppColors.textOnPrimary,
                            icon: _isDeleting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.textOnPrimary,
                                    ),
                                  )
                                : const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.textOnPrimary,
                                  ),
                            onPressed: state.isSubmitting || _isDeleting
                                ? null
                                : () => _confirmDelete(context),
                          ),
                        ],
                      ],
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
    _completePhoneNumbers.clear();
    _phoneCountryCodes.clear();
    if (source.isEmpty) {
      target.add(TextEditingController());
      _completePhoneNumbers.add(null);
      _phoneCountryCodes.add(_defaultCountryCode);
      return;
    }
    for (final value in source) {
      final seed = _seedPhone(value);
      target.add(TextEditingController(text: seed.nationalNumber));
      _completePhoneNumbers.add(seed.completeNumber);
      _phoneCountryCodes.add(seed.countryCode);
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
                child: Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: PhoneNumberField(
                    controller: controllers[i],
                    labelText: hint,
                    initialCountryCode: _phoneCountryCodes[i],
                    onChanged: (value) {
                      final raw = controllers[i].text.trim();
                      _completePhoneNumbers[i] = raw.isEmpty ? null : value;
                      final inferred = _resolveCountryCodeFromComplete(value);
                      if (inferred != null) {
                        _phoneCountryCodes[i] = inferred;
                      }
                    },
                  ),
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
          label: Text('$_prefix.form.add_entry'.tr()),
        ),
      ),
    );
    return fields;
  }

  void _addPhoneField() {
    setState(() {
      _phoneControllers.add(TextEditingController());
      _completePhoneNumbers.add(null);
      _phoneCountryCodes.add(_defaultCountryCode);
    });
  }

  void _initSocialFields() {
    if (_socialFields.isNotEmpty) return;
    final existing = widget.initial?.socialMedia ?? const [];
    if (existing.isNotEmpty) {
      for (final link in existing) {
        _socialFields.add(
          _SocialField(
            type: _normalizeSocialType(link.type),
            controller: TextEditingController(text: link.link),
          ),
        );
      }
      return;
    }
    _socialFields.add(
      _SocialField(
        type: _socialTypes.first,
        controller: TextEditingController(),
      ),
    );
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
                  labelText: '$_prefix.form.social.type_label'.tr(),
                ),
                items: availableTypes
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          '$_prefix.form.social.types.$type'.tr(),
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
                  labelText: '$_prefix.form.social.link_label'.tr(),
                  hintText: '$_prefix.form.social.link_hint'.tr(),
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
    final used =
        _socialFields.where((f) => f != current).map((f) => f.type).toSet();
    return _socialTypes
        .where((t) => !used.contains(t) || t == current.type)
        .toList();
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

  void _removeExistingImage(String imageUrl) {
    setState(() {
      _existingImages.remove(imageUrl);
      final deletePath = _toDeletePath(imageUrl);
      if (deletePath.isNotEmpty && !_deletedImages.contains(deletePath)) {
        _deletedImages.add(deletePath);
      }
    });
  }

  String _toDeletePath(String imageUrl) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return trimmed;
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final baseUri = Uri.tryParse(baseUrl);
    final imageUri = Uri.tryParse(trimmed);
    if (imageUri != null && imageUri.hasScheme) {
      if (baseUri != null && imageUri.host == baseUri.host) {
        final path = imageUri.path;
        return path.startsWith('/') ? path.substring(1) : path;
      }
      final path = imageUri.path;
      return path.startsWith('/') ? path.substring(1) : path;
    }
    if (trimmed.startsWith(baseUrl)) {
      var path = trimmed.substring(baseUrl.length);
      if (path.startsWith('/')) {
        path = path.substring(1);
      }
      return path;
    }
    return trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
  }

  String _normalizeSocialType(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return _socialTypes.first;
    }
    return _socialTypes.contains(normalized) ? normalized : 'other';
  }

  Widget _buildNetworkImageTile({
    required String baseUrl,
    required String imageUrl,
    required VoidCallback onRemove,
  }) {
    final resolved = imageUrl.startsWith('http')
        ? imageUrl
        : '$baseUrl/${imageUrl.replaceFirst(RegExp(r'^/+'), '')}';
    return _ImageTile(
      child: NetworkImageWrapper(
        imageUrl: resolved,
        height: 86,
        width: 86,
        fit: BoxFit.cover,
        shimmerChild: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        fallback: const Icon(Icons.broken_image_outlined),
      ),
      onRemove: onRemove,
    );
  }

  Widget _buildLocalImageTile({
    required XFile image,
    required VoidCallback onRemove,
  }) {
    return _ImageTile(
      child: Image.file(
        File(image.path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined),
      ),
      onRemove: onRemove,
    );
  }

  String _requiredLabel(String text) => '$text *';

  void _removeField(int index, List<TextEditingController> controllers) {
    setState(() {
      final controller = controllers.removeAt(index);
      controller.dispose();
      _completePhoneNumbers.removeAt(index);
      _phoneCountryCodes.removeAt(index);
      if (controllers.isEmpty) controllers.add(TextEditingController());
      if (_completePhoneNumbers.isEmpty) _completePhoneNumbers.add(null);
      if (_phoneCountryCodes.isEmpty) {
        _phoneCountryCodes.add(_defaultCountryCode);
      }
    });
  }

  _PhoneSeed _seedPhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const _PhoneSeed(
        countryCode: _defaultCountryCode,
        nationalNumber: '',
      );
    }

    final digits = _digitsOnly(trimmed);
    if (digits.isEmpty) {
      return const _PhoneSeed(
        countryCode: _defaultCountryCode,
        nationalNumber: '',
      );
    }

    if (trimmed.startsWith('+') || trimmed.startsWith('00')) {
      final normalized =
          trimmed.startsWith('00') ? '+${digits.substring(2)}' : '+$digits';
      final dialDigits =
          normalized.startsWith('+') ? normalized.substring(1) : digits;
      final countryCode =
          _resolveCountryCodeByDial(dialDigits) ?? _defaultCountryCode;
      final dialCode = _dialCodeForCountry(countryCode);
      final nationalNumber = dialCode != null && dialDigits.startsWith(dialCode)
          ? dialDigits.substring(dialCode.length)
          : dialDigits;
      return _PhoneSeed(
        countryCode: countryCode,
        nationalNumber: nationalNumber,
        completeNumber: normalized,
      );
    }

    final inferredCountry = _resolveCountryCodeByDial(digits);
    if (inferredCountry != null && digits.length > 9) {
      final dialCode = _dialCodeForCountry(inferredCountry);
      final nationalNumber = dialCode != null && digits.startsWith(dialCode)
          ? digits.substring(dialCode.length)
          : digits;
      return _PhoneSeed(
        countryCode: inferredCountry,
        nationalNumber: nationalNumber,
        completeNumber: '+$digits',
      );
    }

    return _PhoneSeed(
      countryCode: _defaultCountryCode,
      nationalNumber: digits,
    );
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  String? _resolveCountryCodeFromComplete(String value) {
    final digits = _digitsOnly(value);
    if (digits.isEmpty) return null;
    return _resolveCountryCodeByDial(digits);
  }

  String? _resolveCountryCodeByDial(String digits) {
    final sorted = _sortedCountriesByDial();
    for (final country in sorted) {
      if (digits.startsWith(country.dialCode)) {
        return country.code;
      }
    }
    return null;
  }

  String? _dialCodeForCountry(String countryCode) {
    for (final country in countries) {
      if (country.code == countryCode) return country.dialCode;
    }
    return null;
  }

  List<Country> _sortedCountriesByDial() {
    final list = countries.toList(growable: false);
    list.sort(
      (a, b) => b.dialCode.length.compareTo(a.dialCode.length),
    );
    return list;
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<HospitalFormCubit>();
    final isEditing = widget.initial != null;

    final phones = _phoneControllers
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final raw = entry.value.text.trim();
          final complete = _completePhoneNumbers[index];
          return (complete != null && complete.trim().isNotEmpty)
              ? complete.trim()
              : raw;
        })
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
        SnackBar(content: Text('$_prefix.form.images_required'.tr())),
      );
      return;
    }

    final facilityType = isEditing
        ? (widget.initial?.facilityType ?? _facilityType)
        : _facilityType;
    final payload = HospitalPayload(
      id: widget.initial?.id,
      name: _nameController.text.trim(),
      descriptionEn: _descriptionController.text.trim(),
      descriptionAr: _descriptionArController.text.trim().isEmpty
          ? null
          : _descriptionArController.text.trim(),
      descriptionFr: _descriptionFrController.text.trim().isEmpty
          ? null
          : _descriptionFrController.text.trim(),
      address: _addressController.text.trim(), // Added address
      phones: phones,
      // Coordinates will be set to 0,0 in HospitalPayload
      facilityType: facilityType,
      images: _selectedImages, // Pass XFile list directly
      socialMedia: socialLinks,
      deleteItems: _deletedImages,
    );

    cubit.submit(payload);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (widget.initial == null || _isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final cancelTextColor =
            theme.brightness == Brightness.dark ? Colors.white : Colors.black87;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          title: Text('$_prefix.detail.delete_confirm_title'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_prefix.detail.delete_confirm_message'.tr()),
              const SizedBox(height: 18),
              AppButton(
                text: '$_prefix.detail.delete_confirm'.tr(),
                color: theme.colorScheme.error,
                textColor: theme.colorScheme.onError,
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
              const SizedBox(height: 10),
              AppButton(
                text: '$_prefix.detail.delete_cancel'.tr(),
                color: theme.colorScheme.surfaceVariant,
                textColor: cancelTextColor,
                icon: Icon(Icons.close_rounded, color: cancelTextColor),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
            ],
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await _deleteHospital(context);
    }
  }

  Future<void> _deleteHospital(BuildContext context) async {
    if (widget.initial == null) return;
    setState(() => _isDeleting = true);
    final repository = sl<HospitalsRepository>();
    final result = await repository.deleteHospital(widget.initial!.id);

    if (!mounted) return;
    setState(() => _isDeleting = false);

    result.fold(
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_prefix.detail.delete_success'.tr())),
        );
        HospitalsRefreshBus.notify();
        context.go(AppRoute.home.path);
      },
    );
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

class _PhoneSeed {
  final String countryCode;
  final String nationalNumber;
  final String? completeNumber;

  const _PhoneSeed({
    required this.countryCode,
    required this.nationalNumber,
    this.completeNumber,
  });
}

const _socialTypes = [
  'facebook',
  'instagram',
  'youtube',
  'x',
  'linkedin',
  'other',
];

class _ImageTile extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;

  const _ImageTile({
    required this.child,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: theme.colorScheme.surfaceVariant,
              child: SizedBox.expand(child: child),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
