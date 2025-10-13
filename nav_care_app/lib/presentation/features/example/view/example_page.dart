import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_app/data/example/repository.dart';
import 'package:nav_care_app/presentation/features/example/viewmodel/example_cubit.dart';

import '../../../../core/di/di.dart';

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExampleCubit(sl<ExampleRepository>())..refresh(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Example'),
        ),
        body: BlocBuilder<ExampleCubit, ExampleState>(
          builder: (context, state) {
            if (state.loading && state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            }
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.description ?? ''),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
