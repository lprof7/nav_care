import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/faq/faq_repository.dart';
import 'package:nav_care_user_app/data/faq/models/faq_item.dart';

part 'faq_state.dart';

class FaqCubit extends Cubit<FaqState> {
  FaqCubit(this._repository) : super(const FaqState.loading());

  final FaqRepository _repository;

  Future<void> loadFaq() async {
    emit(const FaqState.loading());
    final result = await _repository.fetchFaq();
    result.fold(
      onSuccess: (faqs) => emit(FaqState.success(faqs)),
      onFailure: (failure) => emit(FaqState.failure(
        failure.message ?? 'unknown_error',
      )),
    );
  }
}
