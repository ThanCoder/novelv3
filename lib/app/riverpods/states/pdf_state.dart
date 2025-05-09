// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../models/pdf_model.dart';

class PdfState {
  final List<PdfModel> list;
  bool isLoading;
  PdfState({
    required this.list,
    this.isLoading = false,
  });

  factory PdfState.init() => PdfState(list: []);

  PdfState copyWith({
    List<PdfModel>? list,
    bool? isLoading,
  }) {
    return PdfState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
