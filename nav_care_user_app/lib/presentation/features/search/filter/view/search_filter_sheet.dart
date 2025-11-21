import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../viewmodel/search_filter_cubit.dart';
import '../viewmodel/search_filter_models.dart';
import '../viewmodel/search_filter_state.dart';

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key, required this.initialFilters});

  final SearchFilters initialFilters;

  static Future<SearchFilters?> show({
    required BuildContext context,
    required SearchFilters initialFilters,
  }) {
    return showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (modalContext) {
        return BlocProvider(
          create: (_) => SearchFilterCubit(initial: initialFilters),
          child: SearchFilterSheet(initialFilters: initialFilters),
        );
      },
    );
  }

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _minPriceCtrl;
  late final TextEditingController _maxPriceCtrl;

  @override
  void initState() {
    super.initState();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _countryCtrl = TextEditingController();
    _minPriceCtrl = TextEditingController();
    _maxPriceCtrl = TextEditingController();
    _syncControllers(widget.initialFilters);
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Material(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BlocListener<SearchFilterCubit, SearchFilterState>(
          listenWhen: (previous, current) =>
              previous.filters != current.filters,
          listener: (context, state) {
            _syncControllers(state.filters);
          },
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 640;
                return Column(
                  children: [
                    _SheetHeader(onClose: () => Navigator.of(context).pop()),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          24,
                          24,
                          24 + bottomPadding,
                        ),
                        child: BlocBuilder<SearchFilterCubit, SearchFilterState>(
                          builder: (context, state) {
                            final cubit = context.read<SearchFilterCubit>();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'home.search.filters.title'.tr(),
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildLocationSection(isWide, cubit),
                                const SizedBox(height: 24),
                                _buildRatingSection(theme, state, cubit),
                                const SizedBox(height: 24),
                                _buildPriceSection(theme, cubit),
                                const SizedBox(height: 24),
                                _buildCollectionsSection(theme, state, cubit),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: BlocBuilder<SearchFilterCubit, SearchFilterState>(
                        builder: (context, state) {
                          final cubit = context.read<SearchFilterCubit>();
                          return Row(
                            children: [
                              TextButton(
                                onPressed: () => cubit.clearAll(),
                                child: Text(
                                  'home.search.filters.actions.clear'.tr(),
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _onApplyPressed(context, state.filters),
                                icon: const Icon(Icons.check_rounded),
                                label: Text(
                                  'home.search.filters.actions.apply'.tr(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection(
    bool isWide,
    SearchFilterCubit cubit,
  ) {
    final fields = <Widget>[
      _buildTextField(
        controller: _cityCtrl,
        label: 'home.search.filters.address.city'.tr(),
        onChanged: cubit.updateCity,
      ),
      _buildTextField(
        controller: _stateCtrl,
        label: 'home.search.filters.address.state'.tr(),
        onChanged: cubit.updateState,
      ),
      _buildTextField(
        controller: _countryCtrl,
        label: 'home.search.filters.address.country'.tr(),
        onChanged: cubit.updateCountry,
      ),
    ];

    return _SectionContainer(
      title: 'home.search.filters.location'.tr(),
      child: _ResponsiveWrap(isWide: isWide, children: fields),
    );
  }

  Widget _buildRatingSection(
    ThemeData theme,
    SearchFilterState state,
    SearchFilterCubit cubit,
  ) {
    final currentValues = RangeValues(
      (state.filters.minRating ?? 0).clamp(0, 5),
      (state.filters.maxRating ?? 5).clamp(0, 5),
    );

    String formatLabel(double value) => value.toStringAsFixed(0);

    return _SectionContainer(
      title: 'home.search.filters.rating.title'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'home.search.filters.rating.range_label'.tr(namedArgs: {
                  'min': formatLabel(currentValues.start),
                  'max': currentValues.end >= 5
                      ? 'home.search.filters.rating.max_default'.tr()
                      : formatLabel(currentValues.end),
                }),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          RangeSlider(
            values: currentValues,
            min: 0,
            max: 5,
            divisions: 5,
            labels: RangeLabels(
              formatLabel(currentValues.start),
              currentValues.end >= 5
                  ? 'home.search.filters.rating.max_default'.tr()
                  : formatLabel(currentValues.end),
            ),
            onChanged: (values) =>
                cubit.updateRatingRange(values.start, values.end),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(ThemeData theme, SearchFilterCubit cubit) {
    return _SectionContainer(
      title: 'home.search.filters.price.title'.tr(),
      child: _ResponsiveWrap(
        isWide: false,
        children: [
          _buildNumberField(
            controller: _minPriceCtrl,
            label: 'home.search.filters.price.min'.tr(),
            hint: '100',
            prefixText: 'home.search.filters.currency_symbol'.tr(),
            onChanged: (value) => cubit.updateMinPrice(_parseDouble(value)),
          ),
          _buildNumberField(
            controller: _maxPriceCtrl,
            label: 'home.search.filters.price.max'.tr(),
            hint: '500',
            prefixText: 'home.search.filters.currency_symbol'.tr(),
            onChanged: (value) => cubit.updateMaxPrice(_parseDouble(value)),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitySection(ThemeData theme, SearchFilterCubit cubit) {
    return const SizedBox.shrink();
  }

  Widget _buildCollectionsSection(
    ThemeData theme,
    SearchFilterState state,
    SearchFilterCubit cubit,
  ) {
    return _SectionContainer(
      title: 'home.search.filters.collections.title'.tr(),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: SearchCollection.values
            .map(
              (collection) => FilterChip(
                label: Text(collection.labelKey.tr()),
                selected: state.filters.collections.contains(collection),
                onSelected: (_) => cubit.toggleCollection(collection),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _buildSortSection(
    ThemeData theme,
    SearchFilterState state,
    SearchFilterCubit cubit,
  ) {
    return const SizedBox.shrink();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? helperText,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefixText,
    String? suffixText,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: false),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        suffixText: suffixText,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  void _syncControllers(SearchFilters filters) {
    _setControllerValue(_cityCtrl, filters.city);
    _setControllerValue(_stateCtrl, filters.state);
    _setControllerValue(_countryCtrl, filters.country);
    _setControllerValue(_minPriceCtrl, _formatDouble(filters.minPrice));
    _setControllerValue(_maxPriceCtrl, _formatDouble(filters.maxPrice));
  }

  void _setControllerValue(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller
      ..text = value
      ..selection = TextSelection.collapsed(offset: value.length);
  }

  String _formatDouble(double? value) {
    if (value == null) return '';
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  double? _parseDouble(String input) {
    final cleaned = input.replaceAll(',', '.').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  List<String> _parseList(String input) {
    return input
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _onApplyPressed(
    BuildContext context,
    SearchFilters filters,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (filters.minRating != null &&
        filters.maxRating != null &&
        filters.minRating! > filters.maxRating!) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('home.search.filters.validation.rating'.tr()),
        ),
      );
      return;
    }

    if (filters.minPrice != null &&
        filters.maxPrice != null &&
        filters.minPrice! > filters.maxPrice!) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('home.search.filters.validation.price'.tr()),
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(filters);
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ResponsiveWrap extends StatelessWidget {
  const _ResponsiveWrap({
    required this.isWide,
    required this.children,
  });

  final bool isWide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = 48.0; // matches sheet padding (24 + 24)
    final availableWidth = (maxWidth - horizontalPadding).clamp(240.0, maxWidth);
    final itemWidth = isWide ? (availableWidth - 16) / 2 : availableWidth;
    final constrainedWidth = itemWidth.clamp(240.0, availableWidth);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children
          .map(
            (child) => SizedBox(
              width: constrainedWidth,
              child: child,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'home.search.filter'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'home.search.filters.actions.cancel'.tr(),
          ),
        ],
      ),
    );
  }
}
