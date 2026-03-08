import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_type_tabbar_cubit.dart';

enum NovelTypes {
  latest('Latest'),
  bookmark('Book Mark'),
  completed('Completed'),
  onGoing('OnGoing'),
  notAdult('Not Adult'),
  adult('Adult');

  final String value;
  const NovelTypes(this.value);
}

class NovelTypeTabbar extends StatefulWidget {
  const NovelTypeTabbar({super.key});

  @override
  State<NovelTypeTabbar> createState() => _NovelTypeTabbarState();
}

class _NovelTypeTabbarState extends State<NovelTypeTabbar> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: BlocBuilder<NovelTypeTabbarCubit, NovelTypes>(
        builder: (context, state) => Row(
          spacing: 3,
          children: NovelTypes.values.map((e) => _item(e, state)).toList(),
        ),
      ),
    );
  }

  Widget _item(NovelTypes type, NovelTypes current) {
    return GestureDetector(
      onTap: () => context.read<NovelTypeTabbarCubit>().setCurrent(type),
      child: Chip(
        mouseCursor: SystemMouseCursors.click,
        avatar: current == type ? Icon(Icons.check) : null,
        label: Text(type.name.toCaptalize),
      ),
    );
  }
}
