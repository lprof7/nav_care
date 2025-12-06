import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_user_app/data/reviews/doctor_reviews/models/doctor_review_model.dart';
import 'package:nav_care_user_app/presentation/features/doctors/viewmodel/doctor_reviews_state.dart';
import 'package:nav_care_user_app/presentation/shared/ui/cards/doctor_review_card.dart';

class DoctorReviewsSection extends StatefulWidget {
  final List<DoctorReviewModel> reviews;
  final DoctorReviewsStatus status;
  final String? message;
  final bool hasMore;
  final bool isLoadingMore;
  final String baseUrl;
  final void Function(DoctorReviewModel) onTap;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final VoidCallback onAddReview;

  const DoctorReviewsSection({
    super.key,
    required this.reviews,
    required this.status,
    required this.message,
    required this.hasMore,
    required this.isLoadingMore,
    required this.baseUrl,
    required this.onTap,
    required this.onRetry,
    required this.onLoadMore,
    required this.onAddReview,
  });

  @override
  State<DoctorReviewsSection> createState() => _DoctorReviewsSectionState();
}

class _DoctorReviewsSectionState extends State<DoctorReviewsSection> {
  static const int _initialVisible = 3;
  bool _showAll = false;

  @override
  void didUpdateWidget(covariant DoctorReviewsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reviews.length <= _initialVisible && _showAll) {
      _showAll = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == DoctorReviewsStatus.loading &&
        widget.reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.status == DoctorReviewsStatus.failure &&
        widget.reviews.isEmpty) {
      final errorText =
          (widget.message ?? 'doctors.reviews.error').replaceFirst('Exception: ', '').tr();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: widget.onAddReview,
              icon: const Icon(Icons.rate_review_rounded),
              label: Text('doctors.reviews.add_button'.tr()),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            errorText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onRetry,
            child: Text('doctors.reviews.retry'.tr()),
          ),
        ],
      );
    }

    if (widget.reviews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: widget.onAddReview,
              icon: const Icon(Icons.rate_review_rounded),
              label: Text('doctors.reviews.add_button'.tr()),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'doctors.reviews.empty'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onRetry,
            child: Text('doctors.reviews.retry'.tr()),
          ),
        ],
      );
    }

    final visibleReviews = _showAll
        ? widget.reviews
        : widget.reviews.take(_initialVisible).toList();
    final canShowLess =
        _showAll && widget.reviews.length > _initialVisible;
    final canShowMore =
        !_showAll && widget.reviews.length > _initialVisible || widget.hasMore;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: widget.onAddReview,
            icon: const Icon(Icons.rate_review_rounded),
            label: Text('doctors.reviews.add_button'.tr()),
          ),
        ),
        const SizedBox(height: 4),
        ...visibleReviews
            .map(
              (review) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DoctorReviewCard(
                  review: review,
                  baseUrl: widget.baseUrl,
                  onTap: () => widget.onTap(review),
                ),
              ),
            )
            .toList(),
        if (canShowMore || widget.isLoadingMore) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: widget.isLoadingMore
                  ? null
                  : () {
                      setState(() => _showAll = true);
                      if (widget.hasMore) widget.onLoadMore();
                    },
              icon: widget.isLoadingMore
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more_rounded),
              label: Text('doctors.reviews.load_more'.tr()),
            ),
          ),
        ],
        if (canShowLess) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _showAll = false),
              icon: const Icon(Icons.expand_less_rounded),
              label: Text('doctors.reviews.show_less'.tr()),
            ),
          ),
        ],
      ],
    );
  }
}
