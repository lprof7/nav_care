import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/reviews/hospital_reviews/models/hospital_review_model.dart';

class HospitalReviewDetailPage extends StatelessWidget {
  final HospitalReviewModel review;

  const HospitalReviewDetailPage({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final avatarUrl = review.reviewer.avatarUrl(baseUrl);
    final locale = context.locale.toLanguageTag();
    final formattedDate = review.createdAt != null
        ? DateFormat.yMMMMd(locale).add_jm().format(review.createdAt!.toLocal())
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('hospitals.review_detail.title'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
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
                            : 'hospitals.reviews.anonymous'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (review.reviewer.email.isNotEmpty)
                        Text(
                          review.reviewer.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.7),
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
                    const Icon(Icons.star_rounded, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (formattedDate.isNotEmpty)
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'hospitals.review_detail.comment_title'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              review.comment.isNotEmpty
                  ? review.comment
                  : 'hospitals.reviews.no_comment'.tr(),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
