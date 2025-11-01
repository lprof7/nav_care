import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_user_app/data/search/models/search_models.dart';

class ServiceOfferingDetailPage extends StatelessWidget {
  const ServiceOfferingDetailPage({
    super.key,
    required this.item,
    required this.baseUrl,
  });

  final SearchResultItem item;
  final String baseUrl;

  Map<String, dynamic> get _service =>
      (item.extra['service'] as Map?)?.cast<String, dynamic>() ?? {};

  Map<String, dynamic> get _provider =>
      (item.extra['provider'] as Map?)?.cast<String, dynamic>() ?? {};

  Map<String, dynamic> get _providerUser =>
      (_provider['user'] as Map?)?.cast<String, dynamic>() ?? {};

  String _serviceTitle(BuildContext context) {
    final locale = context.locale.languageCode;
    final localizedName = _service['name_$locale']?.toString();
    if (localizedName != null && localizedName.isNotEmpty) return localizedName;
    return _service['name_en']?.toString() ??
        _service['name']?.toString() ??
        item.title;
  }

  String? _resolvePath(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    try {
      return Uri.parse(baseUrl).resolve(path).toString();
    } catch (_) {
      return path;
    }
  }

  List<Widget> _buildInfoChips(BuildContext context) {
    final chips = <Widget>[];
    void addChip(IconData icon, String label) {
      chips.add(
        Chip(
          avatar: Icon(icon, size: 18),
          label: Text(label),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    if (item.price != null) {
      addChip(
        Icons.attach_money_rounded,
        '${'home.search.filters.currency_symbol'.tr()}${item.price!.toStringAsFixed(0)}',
      );
    }
    if (item.rating != null) {
      addChip(
        Icons.star_rounded,
        item.rating!.toStringAsFixed(1),
      );
    }
    if (item.location.city.isNotEmpty || item.location.country.isNotEmpty) {
      addChip(
        Icons.place_rounded,
        '${item.location.city} ${item.location.country}'.trim(),
      );
    }
    if (item.languages.isNotEmpty) {
      addChip(
        Icons.language_rounded,
        item.languages.join(', '),
      );
    }
    if (item.insuranceAccepted.isNotEmpty) {
      addChip(
        Icons.verified_user_rounded,
        item.insuranceAccepted.join(', '),
      );
    }
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final coverImage = _resolvePath(item.imagePath ?? _service['image']?.toString());
    final providerAvatar = _resolvePath(_providerUser['profilePicture']?.toString());
    final providerName = _providerUser['name']?.toString() ?? item.subtitle;
    final providerSpecialty =
        _provider['specialty']?.toString() ?? item.description;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _serviceTitle(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (coverImage != null)
                    Image.network(
                      coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          size: 48,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_rounded,
                        size: 64,
                      ),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        backgroundImage: providerAvatar != null
                            ? NetworkImage(providerAvatar)
                            : null,
                        child: providerAvatar == null
                            ? const Icon(Icons.person_rounded, size: 32)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              providerName,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (providerSpecialty != null &&
                                providerSpecialty.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  providerSpecialty,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _buildInfoChips(context),
                  ),
                  const SizedBox(height: 24),
                  if (item.description.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'services.detail.about'.tr(),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description,
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  if (_service['description_en'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'services.detail.service_overview'.tr(),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _service['description_${context.locale.languageCode}']
                                  ?.toString() ??
                              _service['description_en']?.toString() ??
                              '',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text('services.detail.make_appointment'.tr()),
          ),
        ),
      ),
    );
  }
}
