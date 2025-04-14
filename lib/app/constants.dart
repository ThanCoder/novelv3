import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//debug
const isDebugPrint = false;

const appBrowserProxyHostUrl = 'https://node-browser.vercel.app';
const appForwardProxyHostUrl = 'https://express-forward-proxy.vercel.app';

//assets
const defaultIconAssetsPath = 'assets/cover.png';
//version name
const appVersionName = 'beta-6';
const appName = 'novel_v3';
const appTitle = 'Novel V3';
const novelDataExtName = 'npz';
const androidRootPath = "/storage/emulated/0";
//config
const appConfigFileName = 'main.config.json';
const pdfConfigName = '-v3-config.json';
const pdfOldConfigName = '-config.json';
const pdfBookListName = '-book_list.json';
//book mark
const chapterBookMarkListName = 'fav_list2.json';
const novelBookListName = 'novel_book_list.json';
const novelRecentDBName = 'novel_recent_list.json';

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
