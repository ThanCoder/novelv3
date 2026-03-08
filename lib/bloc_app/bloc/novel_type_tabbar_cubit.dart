import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/bloc_app/ui/main/novel_type_tabbar.dart';

class NovelTypeTabbarCubit extends Cubit<NovelTypes> {
  final NovelListCubit novelListCubit;
  NovelTypeTabbarCubit(this.novelListCubit) : super(NovelTypes.latest);

  void setCurrent(NovelTypes type) async {
    if (type == state) return;

    emit(type);

    if (type == NovelTypes.latest) {
      await novelListCubit.fetchNovel();
      return;
    } else {
      await novelListCubit.fetchNovel();
    }

    final list = novelListCubit.state.list;
    if (type == NovelTypes.adult) {
      novelListCubit.setList(list.where((e) => e.meta.isAdult).toList());
      return;
    }
    if (type == NovelTypes.notAdult) {
      novelListCubit.setList(list.where((e) => !e.meta.isAdult).toList());
      return;
    }
    if (type == NovelTypes.onGoing) {
      novelListCubit.setList(list.where((e) => !e.meta.isCompleted).toList());
      return;
    }
    if (type == NovelTypes.completed) {
      novelListCubit.setList(list.where((e) => e.meta.isCompleted).toList());
      return;
    }
  }
}
