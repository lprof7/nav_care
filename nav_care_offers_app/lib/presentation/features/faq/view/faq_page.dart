import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
    final items = _faqItems;

    return Scaffold(
      appBar: AppBar(
        title: Text('faq.title'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            'faq.subtitle'.tr(),
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          ...List.generate(items.length, (index) {
            final item = items[index];
            final isExpanded = _expandedIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FaqTile(
                item: item,
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
      ),
    );
  }
}

class _FaqItem {
  final String questionKey;
  final String answerKey;
  final String? tagKey;
  final IconData icon;

  const _FaqItem({
    required this.questionKey,
    required this.answerKey,
    this.tagKey,
    this.icon = Icons.help_outline_rounded,
  });
}

class _FaqTile extends StatelessWidget {
  final _FaqItem item;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _FaqTile({
    required this.item,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tag = item.tagKey?.tr();

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
                        item.icon,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.questionKey.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (tag != null && tag.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
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
                      item.answerKey.tr(),
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

const List<_FaqItem> _faqItems = [
  _FaqItem(
    questionKey: 'faq.questions.about_app.question',
    answerKey: 'faq.questions.about_app.answer',
    tagKey: 'faq.tags.general',
  ),
  _FaqItem(
    questionKey: 'faq.questions.account_needed.question',
    answerKey: 'faq.questions.account_needed.answer',
    tagKey: 'faq.tags.accounts',
  ),
  _FaqItem(
    questionKey: 'faq.questions.book_appointment.question',
    answerKey: 'faq.questions.book_appointment.answer',
    tagKey: 'faq.tags.appointments',
    icon: Icons.calendar_month_rounded,
  ),
  _FaqItem(
    questionKey: 'faq.questions.manage_appointment.question',
    answerKey: 'faq.questions.manage_appointment.answer',
    tagKey: 'faq.tags.appointments',
    icon: Icons.event_available_rounded,
  ),
  _FaqItem(
    questionKey: 'faq.questions.search_services.question',
    answerKey: 'faq.questions.search_services.answer',
    tagKey: 'faq.tags.search',
    icon: Icons.search_rounded,
  ),
  _FaqItem(
    questionKey: 'faq.questions.profile_updates.question',
    answerKey: 'faq.questions.profile_updates.answer',
    tagKey: 'faq.tags.accounts',
    icon: Icons.person_outline_rounded,
  ),
  _FaqItem(
    questionKey: 'faq.questions.language_switch.question',
    answerKey: 'faq.questions.language_switch.answer',
    tagKey: 'faq.tags.app_settings',
    icon: Icons.translate_rounded,
  ),
  _FaqItem(
    questionKey: 'faq.questions.password_reset.question',
    answerKey: 'faq.questions.password_reset.answer',
    tagKey: 'faq.tags.accounts',
    icon: Icons.lock_reset_rounded,
  ),
  _FaqItem(
    questionKey: 'faq.questions.data_sync.question',
    answerKey: 'faq.questions.data_sync.answer',
    tagKey: 'faq.tags.support',
    icon: Icons.wifi_find_rounded,
  ),
];
