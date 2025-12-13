import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/faq/models/faq_item.dart';
import 'package:nav_care_offers_app/presentation/features/faq/viewmodel/faq_cubit.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => sl<FaqCubit>()..loadFaq(),
      child: BlocBuilder<FaqCubit, FaqState>(
        builder: (context, state) {
          final items = state.faqs;
          return Scaffold(
            appBar: AppBar(
              title: Text('faq.title'.tr()),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Text(
                  'faq.subtitle'.tr(),
                  style:
                      textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 18),
                if (state.isLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else if (state.error != null) ...[
                  Center(
                    child: Column(
                      children: [
                        Text(
                          state.error!.tr(),
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () =>
                              context.read<FaqCubit>().loadFaq(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text('faq.retry'.tr()),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ...List.generate(items.length, (index) {
                    final item = items[index];
                    final isExpanded = _expandedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FaqTile(
                        question: item.localizedQuestion(
                          context.locale.languageCode,
                        ),
                        answer: item.localizedAnswer(
                          context.locale.languageCode,
                        ),
                        isExpanded: isExpanded,
                        onToggle: () {
                          setState(() {
                            _expandedIndex = isExpanded ? null : index;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isExpanded
            ? colorScheme.primary.withOpacity(0.06)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withOpacity(isExpanded ? 0.28 : 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: isExpanded ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12, right: 4),
                    child: Text(
                      answer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.9),
                      ),
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
