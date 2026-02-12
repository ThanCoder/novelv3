import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:t_widgets/t_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CounterCubit, int>(
      listener: (context, state) {
        if (state == 5) {
          showTSnackBar(context, 'count $state');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Bloc App')),
        body: Column(
          children: [
            BlocBuilder<CounterCubit, int>(
              builder: (context, state) => Text('Cubit Count: ${state}'),
            ),
            TextButton(
              onPressed: () {
                context.read<CounterCubit>().dec();
              },
              child: Text('Dec'),
            ),

            TextButton(
              onPressed: () {
                context.read<CounterCubit>().inc();
              },
              child: Text('Inc'),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // context.go('/content');
            context.push('/content');
          },
        ),
      ),
    );
  }
}

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void inc() => emit(state + 1);
  void dec() => emit(state - 1);
}
