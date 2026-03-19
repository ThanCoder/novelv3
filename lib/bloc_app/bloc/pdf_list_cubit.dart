import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/core/extensions/pdf_file_extension.dart';
import 'package:novel_v3/core/models/pdf_file.dart';
import 'package:novel_v3/core/services/pdf_services.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:t_widgets/t_widgets.dart';

class PdfListCubit extends Cubit<PdfListCubitState> {
  final PdfServices pdfServices;
  final NovelDetailCubit novelDetailCubit;
  PdfListCubit(this.pdfServices, {required this.novelDetailCubit})
    : super(PdfListCubitState.create());

  static List<TSort> sortList = [
    TSort(id: 1, title: 'Title', ascTitle: 'A-Z', descTitle: 'Z-A'),
    TSort(id: 2, title: 'Size', ascTitle: 'Smallest', descTitle: 'Biggest'),
    TSort(id: 3, title: 'Added', ascTitle: 'Newest', descTitle: 'Oldest'),
  ];

  Future<void> fetchList() async {
    try {
      if (state.isLoading) return;

      emit(state.copyWith(isLoading: true, errorMessage: ''));

      final novelPath = PathUtil.getSourcePath(
        name: novelDetailCubit.state.currentNovel!.id,
      );
      final list = await pdfServices.getAll(novelPath);
      // sort
      if (state.sortId == 1) {
        list.sortTitle(aToZ: state.sortAsc);
      }
      if (state.sortId == 2) {
        list.sortSize(isSmallest: state.sortAsc);
      }
      if (state.sortId == 3) {
        list.sortDate(isNewest: state.sortAsc);
      }

      emit(state.copyWith(isLoading: false, list: list));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  void sort(int sortId, bool sortAsc) {
    final list = state.list;

    if (sortId == 1) {
      list.sortTitle(aToZ: sortAsc);
    }
    if (sortId == 2) {
      list.sortSize(isSmallest: sortAsc);
    }
    if (sortId == 3) {
      list.sortDate(isNewest: sortAsc);
    }

    emit(state.copyWith(sortAsc: sortAsc, sortId: sortId));
  }
}

class PdfListCubitState {
  final bool isLoading;
  final List<PdfFile> list;
  final int sortId;
  final bool sortAsc;
  final String errorMessage;

  const PdfListCubitState({
    required this.isLoading,
    required this.list,
    required this.sortId,
    required this.sortAsc,
    required this.errorMessage,
  });
  factory PdfListCubitState.create({bool isLoading = false}) {
    return PdfListCubitState(
      isLoading: isLoading,
      list: [],
      sortId: 1,
      sortAsc: true,
      errorMessage: '',
    );
  }

  PdfListCubitState copyWith({
    bool? isLoading,
    List<PdfFile>? list,
    int? sortId,
    bool? sortAsc,
    String? errorMessage,
  }) {
    return PdfListCubitState(
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      sortId: sortId ?? this.sortId,
      sortAsc: sortAsc ?? this.sortAsc,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
