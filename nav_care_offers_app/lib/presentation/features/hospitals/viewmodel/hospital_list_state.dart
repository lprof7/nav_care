part of 'hospital_list_cubit.dart';

abstract class HospitalListState extends Equatable {
  const HospitalListState();

  @override
  List<Object?> get props => [];
}

class HospitalListInitial extends HospitalListState {
  const HospitalListInitial();
}

class HospitalListLoading extends HospitalListState {
  const HospitalListLoading();
}

class HospitalListSuccess extends HospitalListState {
  final List<Hospital> hospitals;
  final Pagination? pagination;

  const HospitalListSuccess({
    required this.hospitals,
    this.pagination,
  });

  HospitalListSuccess copyWith({
    List<Hospital>? hospitals,
    Pagination? pagination,
  }) {
    return HospitalListSuccess(
      hospitals: hospitals ?? this.hospitals,
      pagination: pagination ?? this.pagination,
    );
  }

  @override
  List<Object?> get props => [hospitals, pagination];
}

class HospitalListEmpty extends HospitalListState {
  final String messageKey;

  const HospitalListEmpty({required this.messageKey});

  @override
  List<Object?> get props => [messageKey];
}

class HospitalListFailure extends HospitalListState {
  final String message;

  const HospitalListFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
