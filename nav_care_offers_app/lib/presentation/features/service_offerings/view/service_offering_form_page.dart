import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/services/doctor_services_repository.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/service_offerings/service_offerings_repository.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/view/service_catalog_picker_page.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_offering_form_cubit.dart';

class ServiceOfferingFormPage extends StatelessWidget {
  const ServiceOfferingFormPage({
    super.key,
    this.hospitalId,
    this.initial,
    this.useHospitalToken = true,
  });

  final String? hospitalId;
  final ServiceOffering? initial;
  final bool useHospitalToken;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceOfferingFormCubit(
        sl<ServiceOfferingsRepository>(),
        servicesRepository: sl<DoctorServicesRepository>(),
        translationService: sl(),
        initial: initial,
        useHospitalToken: useHospitalToken,
      )..loadCatalog(),
      child: _ServiceOfferingFormView(
        hospitalId: hospitalId,
        initial: initial,
      ),
    );
  }
}

class _ServiceOfferingFormView extends StatefulWidget {
  const _ServiceOfferingFormView({
    required this.hospitalId,
    this.initial,
  });

  final String? hospitalId;
  final ServiceOffering? initial;

  @override
  State<_ServiceOfferingFormView> createState() =>
      _ServiceOfferingFormViewState();
}

class _ServiceOfferingFormViewState extends State<_ServiceOfferingFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late final TextEditingController _offersController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _descriptionFrController;
  late final TextEditingController _descriptionArController;
  late final TextEditingController _descriptionSpController;
  String? _selectedServiceId;
  ServiceCategory? _selectedService;
  late final TextEditingController _nameEnController;
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _priceController = TextEditingController(
      text: initial?.price.toStringAsFixed(2) ?? '',
    );
    _offersController = TextEditingController(
      text: initial?.offers.join(', ') ?? '',
    );
    _descriptionEnController =
        TextEditingController(text: initial?.descriptionEn ?? '');
    _descriptionFrController =
        TextEditingController(text: initial?.descriptionFr ?? '');
    _descriptionArController =
        TextEditingController(text: initial?.descriptionAr ?? '');
    _descriptionSpController =
        TextEditingController(text: initial?.descriptionSp ?? '');
    _nameEnController =
        TextEditingController(text: initial?.nameEn ?? initial?.service.nameEn ?? '');
    _selectedServiceId = initial?.service.id;
    _selectedService = initial?.service;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _offersController.dispose();
    _descriptionEnController.dispose();
    _descriptionFrController.dispose();
    _descriptionArController.dispose();
    _descriptionSpController.dispose();
    _nameEnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final titleKey = isEdit
        ? 'service_offerings.form.edit_title'
        : 'service_offerings.form.create_title';

    return BlocConsumer<ServiceOfferingFormCubit, ServiceOfferingFormState>(
      listener: (context, state) {
        if (state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.failure!.message ?? 'service_offerings.form.error'.tr(),
              ),
            ),
          );
        } else if (state.isSuccess && state.result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit
                  ? 'service_offerings.form.update_success'.tr()
                  : 'service_offerings.form.create_success'.tr()),
            ),
          );
          Navigator.of(context).pop(state.result);
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final services = state.catalog;
        final selectedServiceExists =
            services.any((service) => service.id == _selectedServiceId);
        if (_selectedService == null && selectedServiceExists) {
          _selectedService = services
              .firstWhere((service) => service.id == _selectedServiceId);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(titleKey.tr()),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'service_offerings.form.description'.tr(),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      _ServiceSelectionButton(
                        selectedService: _selectedService,
                        onTap: () => _openServicePicker(context),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText:
                                _requiredLabel('service_offerings.form.price'.tr()),
                          ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'field_required'.tr();
                                }
                                return double.tryParse(value) == null
                                    ? 'service_offerings.form.price_invalid'
                                        .tr()
                                    : null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (state.isCatalogLoading)
                            const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _offersController,
                        decoration: InputDecoration(
                          labelText: 'service_offerings.form.offers'.tr(),
                          hintText: 'service_offerings.form.offers_hint'.tr(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameEnController,
                        decoration: InputDecoration(
                          labelText: 'service_offerings.form.name_en'.tr(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _MultilineField(
                        controller: _descriptionEnController,
                        label: 'service_offerings.form.description_en'.tr(),
                      ),
                      const SizedBox(height: 12),
                      _MultilineField(
                        controller: _descriptionArController,
                        label: 'service_offerings.form.description_ar'.tr(),
                      ),
                      const SizedBox(height: 12),
                      _MultilineField(
                        controller: _descriptionFrController,
                        label: 'service_offerings.form.description_fr'.tr(),
                      ),
                      const SizedBox(height: 12),
                      _MultilineField(
                        controller: _descriptionSpController,
                        label: 'service_offerings.form.description_sp'.tr(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'service_offerings.form.images.label'.tr(),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ..._selectedImages.map((image) => ListTile(
                            title: Text(image.name ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => setState(() {
                                _selectedImages.remove(image);
                              }),
                            ),
                          )),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: Text('service_offerings.form.add_image'.tr()),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => _submit(context),
                          child: Text(isEdit
                              ? 'service_offerings.form.update_button'.tr()
                              : 'service_offerings.form.create_button'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.isSubmitting)
                Positioned.fill(
                  child: Container(
                    color: theme.colorScheme.surface.withOpacity(0.4),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final selected = _selectedServiceId;
    if (selected == null || selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('service_offerings.form.select_service'.tr()),
        ),
      );
      return;
    }
    final price = double.tryParse(_priceController.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('service_offerings.form.price_invalid'.tr()),
        ),
      );
      return;
    }

    context.read<ServiceOfferingFormCubit>().submit(
          serviceId: selected,
          price: price,
          offers: _offersController.text,
          descriptionEn: _descriptionEnController.text.trim().isEmpty
              ? null
              : _descriptionEnController.text.trim(),
          descriptionFr: _descriptionFrController.text.trim().isEmpty
              ? null
              : _descriptionFrController.text.trim(),
          descriptionAr: _descriptionArController.text.trim().isEmpty
              ? null
              : _descriptionArController.text.trim(),
          descriptionSp: _descriptionSpController.text.trim().isEmpty
              ? null
              : _descriptionSpController.text.trim(),
          nameEn: _nameEnController.text.trim(),
          images: _selectedImages,
        );
  }

  Future<void> _openServicePicker(BuildContext context) async {
    final useHospitalToken =
        context.read<ServiceOfferingFormCubit>().useHospitalToken;
    final result = await Navigator.of(context).push<ServiceCategory>(
      MaterialPageRoute(
        builder: (_) => ServiceCatalogPickerPage(
          initial: _selectedService,
          useHospitalToken: useHospitalToken,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedService = result;
        _selectedServiceId = result.id;
      });
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

  String _requiredLabel(String text) => '$text *';
}

class _MultilineField extends StatelessWidget {
  const _MultilineField({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
      ),
    );
  }
}

class _ServiceSelectionButton extends StatelessWidget {
  const _ServiceSelectionButton({
    required this.selectedService,
    required this.onTap,
  });

  final ServiceCategory? selectedService;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;
    final label = selectedService?.localizedName(locale);
    final hasSelection = label != null && label.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _requiredLabelText(context),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              const Icon(PhosphorIconsBold.stethoscope),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasSelection
                      ? label!
                      : 'service_offerings.form.select_service'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ],
    );
  }

  String _requiredLabelText(BuildContext context) {
    final text = 'service_offerings.form.service'.tr();
    return '$text *';
  }
}
