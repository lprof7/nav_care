import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  final List<TextEditingController> _phoneControllers = [];
  final List<TextEditingController> _imageControllers = [];
  FacilityType _facilityType = FacilityType.hospital;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.initial?.descriptionEn ?? '');
    _latitudeController = TextEditingController(
      text: widget.initial?.coordinates?.latitude.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.initial?.coordinates?.longitude.toString() ?? '',
    );
    _facilityType = widget.initial?.facilityType ?? FacilityType.hospital;
    _initDynamicControllers(
      source: widget.initial?.phones ?? const [],
      target: _phoneControllers,
    );
    _initDynamicControllers(
      source: widget.initial?.images ?? const [],
      target: _imageControllers,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    for (final controller in _phoneControllers) {
      controller.dispose();
    }
    for (final controller in _imageControllers) {
      controller.dispose();
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
          context.pop(state.lastSaved);
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
                      labelText: 'hospitals.form.name'.tr(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'field_required'.tr()
                            : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'hospitals.form.description_en'.tr(),
                    ),
                    maxLines: 4,
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'field_required'.tr()
                            : null,
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(label: 'hospitals.form.facility_type.label'.tr()),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<FacilityType>(
                    initialValue: _facilityType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: FacilityType.values
                        .where((type) => type != FacilityType.unknown)
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type
                                .translationKey('hospitals.form.facility_type')
                                .tr()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _facilityType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'hospitals.form.phone_label'.tr()),
                  const SizedBox(height: 8),
                  ..._buildDynamicFields(
                    controllers: _phoneControllers,
                    hint: 'hospitals.form.phone_hint'.tr(),
                    onAdd: _addPhoneField,
                    onRemove: (index) => _removeField(
                      index,
                      _phoneControllers,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'hospitals.form.coordinates.label'.tr()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText:
                                'hospitals.form.coordinates.latitude'.tr(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText:
                                'hospitals.form.coordinates.longitude'.tr(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'hospitals.form.images.label'.tr()),
                  const SizedBox(height: 8),
                  ..._buildDynamicFields(
                    controllers: _imageControllers,
                    hint: 'hospitals.form.images.hint'.tr(),
                    onAdd: _addImageField,
                    onRemove: (index) => _removeField(
                      index,
                      _imageControllers,
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
                      onPressed: state.isSubmitting ? null : () => _submit(context),
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

  void _initDynamicControllers({
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

  List<Widget> _buildDynamicFields({
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

  void _addImageField() {
    setState(() => _imageControllers.add(TextEditingController()));
  }

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
    final images = _imageControllers
        .map((controller) => controller.text.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    HospitalCoordinates? coordinates;
    if (latitude != null && longitude != null) {
      coordinates =
          HospitalCoordinates(latitude: latitude, longitude: longitude);
    }

    final payload = HospitalPayload(
      id: widget.initial?.id,
      name: _nameController.text.trim(),
      descriptionEn: _descriptionController.text.trim(),
      phones: phones,
      coordinates: coordinates,
      facilityType: _facilityType,
      images: images,
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
