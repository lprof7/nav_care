part of 'doctor_services_cubit.dart';

abstract class DoctorServicesState extends Equatable {
  const DoctorServicesState();

  @override
  List<Object?> get props => const [];
}

class DoctorServicesInitial extends DoctorServicesState {
  const DoctorServicesInitial();
}

class DoctorServicesLoading extends DoctorServicesState {
  const DoctorServicesLoading();
}

class DoctorServicesSuccess extends DoctorServicesState {
  final List<DoctorService> services;
  final Pagination? pagination;

  const DoctorServicesSuccess({
    required this.services,
    this.pagination,
  });

  @override
  List<Object?> get props => [services, pagination];
}

class DoctorServicesFailure extends DoctorServicesState {
  final String message;

  const DoctorServicesFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
