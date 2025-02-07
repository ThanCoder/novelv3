import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//debug
const isDebugPrint = false;

//assets
const defaultIconAssetsPath = 'assets/online.webp';
//version name
const appVersionName = 'online-test-1';
const appName = 'novel_v3';
const appTitle = 'Novel V3';
const novelDataExtName = 'npz';
const androidRootPath = "/storage/emulated/0";
//config
const appConfigFileName = 'main.config.json';
const chapterBookMarkListName = 'fav_list2.json';
const pdfConfigName = '-v3-config.json';
const pdfBookListName = '-book_list.json';
const novelBookListName = 'novel_book_list.json';
const textReaderConfigName = 'reader.config.json';
//novel status color
final novelStatusOnGoingColor = Colors.teal[900];
final novelStatusCompletedColor = Colors.blue[900];
const novelStatusAdultColor = Colors.red;

final activeColor = Colors.teal[600];
const dangerColor = Colors.red;
final disableColor = Colors.grey[200];

const androidPlatform = MethodChannel('than.pkg');
//server
const serverPort = 3300;
