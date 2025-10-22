import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/example/repository.dart';
import '../../../../core/responses/pagination.dart';
import '../../../../core/responses/result.dart';
import '../../../../data/example/model.dart';

class ExampleState {
  final bool loading;
  final String? error;
  final List<Example> items;
  final int page;
  final bool canLoadMore;
  final String query;

  ExampleState({
    required this.loading,
    required this.error,
    required this.items,
    required this.page,
    required this.canLoadMore,
    required this.query,
  });

  factory ExampleState.initial() => ExampleState(
        loading: false,
        error: null,
        items: const [],
        page: 1,
        canLoadMore: true,
        query: '',
      );

  ExampleState copyWith({
    bool? loading,
    String? error,
    List<Example>? items,
    int? page,
    bool? canLoadMore,
    String? query,
  }) =>
      ExampleState(
        loading: loading ?? this.loading,
        error: error,
        items: items ?? this.items,
        page: page ?? this.page,
        canLoadMore: canLoadMore ?? this.canLoadMore,
        query: query ?? this.query,
      );
}

class ExampleCubit extends Cubit<ExampleState> {
  final ExampleRepository repo;
  ExampleCubit(this.repo) : super(ExampleState.initial());

  Future<void> refresh({String? q}) async {
    emit(state.copyWith(
        loading: true,
        error: null,
        items: [],
        page: 1,
        canLoadMore: true,
        query: q ?? ''));
    await _load(page: 1);
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.loading) return;
    emit(state.copyWith(loading: true, error: null));
    await _load(page: state.page + 1);
  }

  Future<void> _load({required int page}) async {
    final r = await repo.list(
        page: page, pageSize: 20, q: state.query.isEmpty ? null : state.query);
    r.fold(
      onFailure: (f) => emit(state.copyWith(loading: false, error: f.message)),
      onSuccess: (Paged<Example> paged) {
        final newItems = [...state.items, ...paged.items];
        final totalPages = paged.meta?.totalPages ?? page;
        emit(state.copyWith(
          loading: false,
          items: newItems,
          page: page,
          canLoadMore: page < totalPages,
        ));
      },
    );
  }
}
