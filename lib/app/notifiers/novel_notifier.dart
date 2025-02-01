import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/chapter_book_mark_model.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/models/novel_data_model.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';

ValueNotifier<List<NovelModel>> novelListNotifier = ValueNotifier([]);
ValueNotifier<NovelModel?> currentNovelNotifier = ValueNotifier(null);
//chapter
ValueNotifier<List<ChapterModel>> chapterListNotifier = ValueNotifier([]);
ValueNotifier<ChapterModel?> currentChapterNotifier = ValueNotifier(null);
ValueNotifier<bool> chapterLoading = ValueNotifier(false);

//book mark
ValueNotifier<List<ChapterBookMarkModel>> chapterBookMarkListNotifier =
    ValueNotifier([]);

//pdf
ValueNotifier<List<PdfFileModel>> pdfListNotifier = ValueNotifier([]);

//pdf scanner
ValueNotifier<List<PdfFileModel>> pdfScannerListNotifier = ValueNotifier([]);
ValueNotifier<PdfFileModel?> currentPdfScannerNotifier = ValueNotifier(null);

//novel data
ValueNotifier<List<NovelDataModel>> novelDataListNotifier = ValueNotifier([]);
ValueNotifier<NovelDataModel?> currentNovelDataNotifier = ValueNotifier(null);

//novel bookmark list
ValueNotifier<List<NovelModel>> novelBookMarkListNotifier = ValueNotifier([]);
