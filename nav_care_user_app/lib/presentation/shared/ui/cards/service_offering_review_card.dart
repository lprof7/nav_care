import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_user_app/data/reviews/service_offering_reviews/models/service_offering_review_model.dart';

class ServiceOfferingReviewCard extends StatelessWidget {
  final ServiceOfferingReviewModel review;
  final String baseUrl;
  final VoidCallback? onTap;

  const ServiceOfferingReviewCard({
    super.key,
    required this.review,
    required this.baseUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = review.reviewer.avatarUrl(baseUrl);
    final date = review.createdAt;
    final locale = context.locale.toLanguageTag();
    final formattedDate = date != null
        ? DateFormat.yMMMd(locale).add_jm().format(date.toLocal())
        : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(
                theme.brightness == Brightness.dark ? 0.08 : 0.12,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  backgroundImage:
                      avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewer.name.isNotEmpty
                            ? review.reviewer.name
                            : 'service_offerings.reviews.anonymous'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (review.reviewer.email.isNotEmpty)
                        Text(
                          review.reviewer.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.comment.isNotEmpty
                  ? review.comment
                  : 'service_offerings.reviews.no_comment'.tr(),
              style: theme.textTheme.bodyMedium,
            ),
            if (formattedDate.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
