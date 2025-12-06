import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/presentation/features/hospitals/viewmodel/hospital_reviews_cubit.dart';
import 'package:nav_care_user_app/presentation/features/hospitals/viewmodel/hospital_reviews_state.dart';

class HospitalAddReviewPage extends StatefulWidget {
  const HospitalAddReviewPage({super.key});

  @override
  State<HospitalAddReviewPage> createState() => _HospitalAddReviewPageState();
}

class _HospitalAddReviewPageState extends State<HospitalAddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _setRating(double value) {
    setState(() => _rating = value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context
        .read<HospitalReviewsCubit>()
        .submitReview(rating: _rating, comment: _commentController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<HospitalReviewsCubit, HospitalReviewsState>(
      listenWhen: (p, c) =>
          p.isSubmittingReview != c.isSubmittingReview ||
          p.submitSuccess != c.submitSuccess ||
          p.submitMessage != c.submitMessage,
      listener: (context, state) {
        if (!state.isSubmittingReview && state.submitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('hospitals.reviews.submit_success'.tr()),
            ),
          );
          Navigator.of(context).pop(true);
        } else if (!state.isSubmittingReview &&
            state.submitMessage != null &&
            state.submitMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.submitMessage!.tr()),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.isSubmittingReview;

        return Scaffold(
          appBar: AppBar(
            title: Text('hospitals.reviews.add_title'.tr()),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'hospitals.reviews.rating_label'.tr(),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      5,
                      (index) {
                        final starValue = index + 1;
                        final isActive = _rating >= starValue;
                        return IconButton(
                          iconSize: 32,
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _setRating(starValue.toDouble()),
                          icon: Icon(
                            isActive
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                          ),
                        );
                      },
                    ),
                  ),
                  if (_rating == 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: Text(
                        'hospitals.reviews.validation.rating'.tr(),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'hospitals.reviews.comment_label'.tr(),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentController,
                    maxLines: 5,
                    minLines: 3,
                    decoration: InputDecoration(
                      hintText: 'hospitals.reviews.comment_hint'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'hospitals.reviews.validation.comment'.tr();
                      }
                      if (_rating == 0) {
                        return 'hospitals.reviews.validation.rating'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).maybePop(false),
                          child: Text('hospitals.reviews.cancel'.tr()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Text('hospitals.reviews.submit'.tr()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
