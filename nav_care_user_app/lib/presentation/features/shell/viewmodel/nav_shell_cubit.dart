import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavShellState extends Equatable {
  final int currentIndex;
  const NavShellState({this.currentIndex = 0});

  NavShellState copyWith({int? currentIndex}) {
    return NavShellState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object> get props => [currentIndex];
}

class NavShellCubit extends Cubit<NavShellState> {
  NavShellCubit({int initialIndex = 0})
      : super(NavShellState(currentIndex: initialIndex));

  void setTab(int index) {
    if (index == state.currentIndex) return;
    emit(state.copyWith(currentIndex: index));
  }
}
