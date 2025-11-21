import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/data/search/models/search_models.dart';
import 'package:nav_care_user_app/presentation/features/search/filter/view/search_filter_sheet.dart';
import 'package:nav_care_user_app/presentation/features/search/filter/viewmodel/search_filter_models.dart';
import 'package:nav_care_user_app/presentation/features/search/viewmodel/search_cubit.dart';
import 'package:nav_care_user_app/presentation/features/search/viewmodel/search_state.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/view/service_offering_detail_page.dart';

import '../../../../core/di/di.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchCubit>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchPressed(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    _focusNode.unfocus();
    cubit.submitSearch();
  }

  Future<void> _onFilterPressed(BuildContext context) async {
    final cubit = context.read<SearchCubit>();
    final result = await SearchFilterSheet.show(
      context: context,
      initialFilters: cubit.state.filters,
    );
    if (result != null) {
      await cubit.applyFilters(result);
    }
  }

  void _onServiceTapped(
    BuildContext context,
    SearchResultItem item,
    String baseUrl,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceOfferingDetailPage(
          item: item,
          baseUrl: baseUrl,
        ),
      ),
    );
  }

  List<Widget> _buildActiveFilterChips(SearchFilters filters) {
    final chips = <Widget>[];
    if (filters.isEmpty) return chips;

    final separator = 'home.search.filters.list_separator'.tr();
    final rangeSeparator = 'home.search.filters.badge.range_separator'.tr();

    void addChip(String key, String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      chips.add(
        Chip(
          label: Text('${key.tr()}: $trimmed'),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    String format(double value) {
      if (value % 1 == 0) return value.toStringAsFixed(0);
      return value.toStringAsFixed(1);
    }

    final addressParts = [
      filters.city,
      filters.state,
      filters.country,
    ].where((value) => value.trim().isNotEmpty).toList(growable: false);
    if (addressParts.isNotEmpty) {
      addChip(
        'home.search.filters.badge.location',
        addressParts.join(separator),
      );
    }

    final ratingTokens = <String>[];
    if (filters.minRating != null) {
      ratingTokens.add(
        'home.search.filters.badge.range_min'
            .tr(namedArgs: {'value': format(filters.minRating!)}),
      );
    }
    if (filters.maxRating != null) {
      ratingTokens.add(
        'home.search.filters.badge.range_max'
            .tr(namedArgs: {'value': format(filters.maxRating!)}),
      );
    }
    if (ratingTokens.isNotEmpty) {
      addChip(
        'home.search.filters.badge.rating',
        ratingTokens.join(rangeSeparator),
      );
    }

    final priceTokens = <String>[];
    if (filters.minPrice != null) {
      priceTokens.add(
        'home.search.filters.badge.range_min'
            .tr(namedArgs: {'value': format(filters.minPrice!)}),
      );
    }
    if (filters.maxPrice != null) {
      priceTokens.add(
        'home.search.filters.badge.range_max'
            .tr(namedArgs: {'value': format(filters.maxPrice!)}),
      );
    }
    if (priceTokens.isNotEmpty) {
      addChip(
        'home.search.filters.badge.price',
        priceTokens.join(rangeSeparator),
      );
    }

    if (filters.collections.isNotEmpty) {
      addChip(
        'home.search.filters.badge.collections',
        filters.collections
            .map((collection) => collection.labelKey.tr())
            .join(separator),
      );
    }

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('home.search.title'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: BlocListener<SearchCubit, SearchState>(
                    listenWhen: (previous, current) =>
                        previous.query != current.query,
                    listener: (context, state) {
                      if (_controller.text != state.query) {
                        _controller
                          ..text = state.query
                          ..selection = TextSelection.collapsed(
                            offset: state.query.length,
                          );
                      }
                    },
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _onSearchPressed(context),
                      onChanged: context.read<SearchCubit>().onQueryChanged,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          tooltip: 'home.search.title'.tr(),
                          icon: const Icon(Icons.send_rounded),
                          onPressed: () => _onSearchPressed(context),
                        ),
                        hintText: 'home.search.title'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                BlocBuilder<SearchCubit, SearchState>(
                  buildWhen: (previous, current) =>
                      previous.filters != current.filters,
                  builder: (context, state) {
                    final hasFilters = !state.filters.isEmpty;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          tooltip: 'home.search.filter'.tr(),
                          onPressed: () => _onFilterPressed(context),
                          style: IconButton.styleFrom(
                            backgroundColor: hasFilters
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                          ),
                          icon: Icon(
                            Icons.filter_list_rounded,
                            color: hasFilters
                                ? colorScheme.onPrimaryContainer
                                : null,
                          ),
                        ),
                        if (hasFilters)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<SearchCubit, SearchState>(
              buildWhen: (previous, current) =>
                  previous.filters != current.filters,
              builder: (context, state) {
                if (state.filters.isEmpty) {
                  return const SizedBox.shrink();
                }
                final chips = _buildActiveFilterChips(state.filters);
                if (chips.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'home.search.filter_active'.tr(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () =>
                              context.read<SearchCubit>().clearFilters(),
                          icon: const Icon(Icons.clear_all_rounded),
                          label: Text('home.search.filters.actions.clear'.tr()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chips,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  final textTheme = theme.textTheme;
                  final children = <Widget>[];
                  final hasSuggestions = state.query.trim().isNotEmpty &&
                      state.suggestionsStatus == SuggestionsStatus.loaded &&
                      state.suggestions.isNotEmpty;

                  if (hasSuggestions) {
                    children.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'home.search.suggestions'.tr(),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                    children.addAll(
                      state.suggestions
                          .map(
                            (suggestion) => ListTile(
                              leading: const Icon(Icons.history_rounded),
                              title: Text(
                                suggestion.displayText.isNotEmpty
                                    ? suggestion.displayText
                                    : suggestion.value,
                              ),
                              subtitle: suggestion.type.isNotEmpty
                                  ? Text(suggestion.type)
                                  : null,
                              onTap: () {
                                context
                                    .read<SearchCubit>()
                                    .onSuggestionSelected(suggestion);
                              },
                            ),
                          )
                          .toList(),
                    );
                    children.add(const Divider(height: 32));
                  } else if (state.suggestionsStatus ==
                      SuggestionsStatus.loading) {
                    children.add(const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(),
                    ));
                  }

                  switch (state.resultsStatus) {
                    case SearchResultsStatus.loading:
                      children.add(
                        const Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                      break;
                    case SearchResultsStatus.failure:
                      children.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            state.errorMessage ?? 'home.search.error'.tr(),
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      );
                      break;
                    case SearchResultsStatus.loaded:
                      final sections = state.resultsByType;
                      if (sections.isEmpty) {
                        children.add(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'home.search.results_empty'.tr(),
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge,
                            ),
                          ),
                        );
                      } else {
                        final orderedTypes = [
                          SearchResultType.doctor,
                          SearchResultType.hospital,
                          SearchResultType.serviceOffering,
                          SearchResultType.unknown,
                        ];
                        final baseUrl = sl<AppConfig>().api.baseUrl;

                        for (final type in orderedTypes) {
                          final items = sections[type];
                          if (items == null || items.isEmpty) continue;
                          children.add(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _sectionLabel(type),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                          children.add(
                            _SearchResultCarousel(
                              type: type,
                              items: items,
                              baseUrl: baseUrl,
                              onServiceTap: (item) =>
                                  _onServiceTapped(context, item, baseUrl),
                            ),
                          );
                        }
                      }
                      break;
                    case SearchResultsStatus.initial:
                      if (children.isEmpty) {
                        children.add(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'home.search.empty'.tr(),
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge,
                            ),
                          ),
                        );
                      }
                      break;
                  }

                  return ListView(children: children);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sectionLabel(SearchResultType type) {
    switch (type) {
      case SearchResultType.doctor:
        return 'home.search.section.doctors'.tr();
      case SearchResultType.hospital:
        return 'home.search.section.hospitals'.tr();
      case SearchResultType.serviceOffering:
        return 'home.search.section.services'.tr();
      case SearchResultType.unknown:
        return 'home.search.section.others'.tr();
    }
  }
}

class _SearchResultCarousel extends StatelessWidget {
  const _SearchResultCarousel({
    required this.type,
    required this.items,
    required this.baseUrl,
    required this.onServiceTap,
  });

  final SearchResultType type;
  final List<SearchResultItem> items;
  final String baseUrl;
  final void Function(SearchResultItem item) onServiceTap;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableWidth = mediaQuery.size.width;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    final targetWidth = availableWidth * 0.48;
    final cardWidth = targetWidth.clamp(150.0, 240.0).toDouble();
    final imageHeight = cardWidth * 0.58;
    final baseCardHeight = imageHeight + 120;
    final extraHeight = switch (type) {
      SearchResultType.serviceOffering => 36.0,
      _ => 0.0,
    };
    final scaleOverflow = math.min(math.max(textScale - 1.0, 0.0), 0.8);
    final cardHeight = baseCardHeight + extraHeight + scaleOverflow * 80;

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          final item = items[index];
          return _SearchResultCard(
            item: item,
            type: type,
            typeLabel: _typeLabel(context, type),
            baseUrl: baseUrl,
            cardWidth: cardWidth,
            imageHeight: imageHeight,
            onServiceTap: () => onServiceTap(item),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: items.length,
      ),
    );
  }

  String _typeLabel(BuildContext context, SearchResultType type) {
    switch (type) {
      case SearchResultType.doctor:
        return 'home.search.type.doctor'.tr();
      case SearchResultType.hospital:
        return 'home.search.type.hospital'.tr();
      case SearchResultType.serviceOffering:
        return 'home.search.type.service'.tr();
      case SearchResultType.unknown:
        return 'home.search.type.unknown'.tr();
    }
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.item,
    required this.type,
    required this.typeLabel,
    required this.baseUrl,
    required this.cardWidth,
    required this.imageHeight,
    required this.onServiceTap,
  });

  final SearchResultItem item;
  final SearchResultType type;
  final String typeLabel;
  final String baseUrl;
  final double cardWidth;
  final double imageHeight;
  final VoidCallback onServiceTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final resolvedImage =
        _resolveImagePath(item.imagePath ?? item.secondaryImagePath, baseUrl);
    final locationText = [
      item.location.city,
      item.location.country,
    ].where((part) => part.trim().isNotEmpty).join(', ');
    final showLocation = locationText.isNotEmpty;

    return SizedBox(
      width: cardWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: type == SearchResultType.serviceOffering ? onServiceTap : null,
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: _ResultImage(
                  imageUrl: resolvedImage,
                  height: imageHeight,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isNotEmpty ? item.title : typeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        typeLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (item.rating != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              item.rating!.toStringAsFixed(1),
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    if (item.price != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.price!.toStringAsFixed(0),
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (showLocation)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.place_rounded, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                locationText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall,
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
      ),
    );
  }

  static String? _resolveImagePath(String? path, String baseUrl) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    try {
      return Uri.parse(baseUrl).resolve(path).toString();
    } catch (_) {
      return path;
    }
  }
}

class _ResultImage extends StatelessWidget {
  const _ResultImage({this.imageUrl, this.height = 110});

  final String? imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    if (imageUrl == null) {
      return Container(
        height: height,
        color: color,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_rounded, size: 32),
      );
    }

    return Image.network(
      imageUrl!,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: color,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_rounded, size: 32),
      ),
    );
  }
}
