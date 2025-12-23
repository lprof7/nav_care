import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/core/translation/translation_service.dart';
import 'package:nav_care_offers_app/data/services/doctor_services_repository.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_catalog_payload.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/presentation/features/service_offerings/viewmodel/service_catalog_cubit.dart';

class ServiceCatalogPickerPage extends StatelessWidget {
  const ServiceCatalogPickerPage({
    super.key,
    this.initial,
    this.useHospitalToken = true,
  });

  final ServiceCategory? initial;
  final bool useHospitalToken;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceCatalogCubit(
        sl<DoctorServicesRepository>(),
        useHospitalToken: useHospitalToken,
      )
        ..loadCatalog(),
      child: _ServiceCatalogPickerView(
        initial: initial,
        useHospitalToken: useHospitalToken,
      ),
    );
  }
}

class _ServiceCatalogPickerView extends StatefulWidget {
  const _ServiceCatalogPickerView({
    this.initial,
    required this.useHospitalToken,
  });

  final ServiceCategory? initial;
  final bool useHospitalToken;

  @override
  State<_ServiceCatalogPickerView> createState() =>
      _ServiceCatalogPickerViewState();
}

class _ServiceCatalogPickerViewState extends State<_ServiceCatalogPickerView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text('service_offerings.form.select_service_title'.tr()),
        actions: [
          IconButton(
            tooltip: 'service_offerings.form.add_service'.tr(),
            onPressed: () => _openCreateService(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: BlocConsumer<ServiceCatalogCubit, ServiceCatalogState>(
        listener: (context, state) {
          if (state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.failure!.message.isNotEmpty
                      ? state.failure!.message
                      : 'service_offerings.form.load_services_error'.tr(),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final query = _searchController.text.trim().toLowerCase();
          final filtered = state.catalog.where((service) {
            final name = service.localizedName(locale).toLowerCase();
            final description = [
              service.descriptionEn,
              service.descriptionAr,
              service.descriptionFr,
              service.descriptionSp,
            ].whereType<String>().join(' ').toLowerCase();
            return query.isEmpty ||
                name.contains(query) ||
                description.contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText:
                        'service_offerings.form.search_services_hint'.tr(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? _EmptyServicesView(
                            onAdd: () => _openCreateService(context),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemBuilder: (context, index) {
                              final service = filtered[index];
                              final isSelected =
                                  widget.initial?.id == service.id;
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                tileColor: isSelected
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.08)
                                    : theme.colorScheme.surface,
                                title: Text(service.localizedName(locale)),
                                subtitle: _buildServiceSubtitle(service, locale),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.of(context).pop(service),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemCount: filtered.length,
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateService(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('service_offerings.form.add_service'.tr()),
      ),
    );
  }

  Widget? _buildServiceSubtitle(ServiceCategory service, String locale) {
    final description = _localizedDescription(service, locale);
    if (description == null || description.isEmpty) return null;
    return Text(
      description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String? _localizedDescription(ServiceCategory service, String locale) {
    switch (locale) {
      case 'ar':
        return service.descriptionAr ??
            service.descriptionEn ??
            service.descriptionFr ??
            service.descriptionSp;
      case 'fr':
        return service.descriptionFr ??
            service.descriptionEn ??
            service.descriptionAr ??
            service.descriptionSp;
      case 'sp':
      case 'es':
        return service.descriptionSp ??
            service.descriptionEn ??
            service.descriptionFr ??
            service.descriptionAr;
      default:
        return service.descriptionEn ??
            service.descriptionFr ??
            service.descriptionAr ??
            service.descriptionSp;
    }
  }

  Future<void> _openCreateService(BuildContext context) async {
    final cubit = context.read<ServiceCatalogCubit>();
    final created = await Navigator.of(context).push<ServiceCategory>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ServiceCatalogCreatePage(
            useHospitalToken: widget.useHospitalToken,
          ),
        ),
      ),
    );
    if (created != null && context.mounted) {
      Navigator.of(context).pop(created);
    }
  }
}

class _EmptyServicesView extends StatelessWidget {
  const _EmptyServicesView({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsBold.stethoscope,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'service_offerings.form.services_empty'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text('service_offerings.form.add_service'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCatalogCreatePage extends StatefulWidget {
  const ServiceCatalogCreatePage({
    super.key,
    required this.useHospitalToken,
  });

  final bool useHospitalToken;

  @override
  State<ServiceCatalogCreatePage> createState() =>
      _ServiceCatalogCreatePageState();
}

class _ServiceCatalogCreatePageState extends State<ServiceCatalogCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _selectedImage;
  late final TranslationService _translationService;

  @override
  void initState() {
    super.initState();
    _translationService = sl<TranslationService>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select<ServiceCatalogCubit, bool>(
      (cubit) => cubit.state.isCreating,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('service_offerings.form.create_service_title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'service_offerings.form.create_service_subtitle'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText:
                      _requiredLabel('service_offerings.form.service_name'.tr()),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: _requiredLabel(
                      'service_offerings.form.service_description'.tr()),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              Text(
                'service_offerings.form.service_image_label'.tr(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (_selectedImage != null)
                ListTile(
                  title: Text(_selectedImage!.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() {
                      _selectedImage = null;
                    }),
                  ),
                ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text('service_offerings.form.service_image_add'.tr()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('service_offerings.form.create_service_submit'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _requiredLabel(String text) => '$text *';

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'field_required'.tr();
    }
    return null;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final nameInput = _nameController.text.trim();
    final descriptionInput = _descriptionController.text.trim();
    final nameTranslations = await _translateText(nameInput);
    final descriptionTranslations = await _translateText(descriptionInput);

    final payload = ServiceCatalogPayload(
      nameEn: nameInput,
      nameAr: nameTranslations?['ar'],
      nameFr: nameTranslations?['fr'],
      descriptionEn: descriptionInput,
      descriptionAr: descriptionTranslations?['ar'],
      descriptionFr: descriptionTranslations?['fr'],
      image: _selectedImage,
    );

    final cubit = context.read<ServiceCatalogCubit>();
    final result = await cubit.createService(
      payload,
      useHospitalToken: widget.useHospitalToken,
    );

    if (!mounted) return;
    result.fold(
      onFailure: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure.message.isNotEmpty
                ? failure.message
                : 'service_offerings.form.create_service_error'.tr(),
          ),
        ),
      ),
      onSuccess: (service) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('service_offerings.form.create_service_success'.tr()),
          ),
        );
        Navigator.of(context).pop(service);
      },
    );
  }

  Future<Map<String, String>?> _translateText(String text) async {
    if (text.trim().isEmpty) return null;
    final result = await _translationService.translate(text);
    return result.fold(
      onFailure: (_) => null,
      onSuccess: (data) => data,
    );
  }
}
