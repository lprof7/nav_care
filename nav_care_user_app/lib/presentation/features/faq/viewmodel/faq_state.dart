part of 'faq_cubit.dart';

class FaqState {
  final bool isLoading;
  final List<FaqItem> faqs;
  final String? error;

  const FaqState._({
    required this.isLoading,
    required this.faqs,
    this.error,
  });

  const FaqState.loading() : this._(isLoading: true, faqs: const []);

  const FaqState.success(List<FaqItem> faqs)
      : this._(isLoading: false, faqs: faqs);

  const FaqState.failure(String message)
      : this._(isLoading: false, faqs: const [], error: message);
}
