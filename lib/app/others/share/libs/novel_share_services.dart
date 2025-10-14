import 'dart:convert';

import 'package:novel_v3/app/ui/novel_dir_app.dart';
import 'package:novel_v3/app/others/share/libs/share_dir_file.dart';
import 'package:novel_v3/app/others/share/libs/share_novel.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelShareServices {
  static String getJson(List<Novel> list) {
    final jsonList = list
        .map(
          (e) => ShareNovel(
            title: e.title,
            path: e.path,
            isAdult: e.isAdult,
            isCompleted: e.isCompleted,
            date: e.date,
          ),
        )
        .toList();
    return JsonEncoder.withIndent(' ').convert(jsonList);
  }

  static String getDirJson(List<ShareDirFile> files) {
    final jsonList = files.map((e) => e.toMap()).toList();
    return JsonEncoder.withIndent(' ').convert(jsonList);
  }

  static String getHomeHtml(List<Novel> list) {
    final html =
        '''
  ${_getHtmlTopTag(styleTag: _getHomeStyleTag)}
  <div class="novel-list">
    ${list.map((e) {
          final data = ''' 
  <div class="novel">
  <a href="/dir?path=${e.path}">
   <img alt="cover" src="/cover?path=${e.getCoverPath}" />
  <div class="title">${e.title}</div>
  <div class="top">
    ${e.isAdult ? '<div class="top-left">IsAdult</div>' : ''}
    <div class="top-right">${e.isCompleted ? 'OnGoing' : 'Completed'}</div>
  </div>
  </a>
  </div>
      ''';
          return data;
        }).join('\n')}
  </div>
  $_getHtmlBottomTag
 ''';
    // File('res.html').writeAsStringSync(html);
    return html;
  }

  static String getDirListHtml(List<ShareDirFile> files) {
    final html =
        '''
  ${_getHtmlTopTag(styleTag: _getDirStyleTag)}
  <div class="file-list">
    ${files.map((file) {
          final data = ''' 
  <div class="file">
  <div class="title">${file.name}</div>
  <div class="size">Size: ${file.size}</div>
 ${file.mime.isNotEmpty ? ' <div class="type">Type: ${file.mime}</div>' : ''}
  <div class="date">Date: ${file.date.toParseTime()}</div>
  <div class="download">
    <a href="/download?path=${file.path}">Download</a>
  </div>
  </div>
      ''';
          return data;
        }).join('\n')}
  </div>
  $_getHtmlBottomTag
 ''';
    // File('res.html').writeAsStringSync(html);
    return html;
  }

  static String _getHtmlTopTag({String styleTag = ''}) {
    return '''<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Share Novel</title>
    $styleTag
  </head>
  <body>''';
  }

  static String get _getHtmlBottomTag {
    return '''  </body>
</html>
''';
  }

  // style
  static String get _getHomeStyleTag {
    return '''<style>
     a {
        text-decoration: none;
      }
    body {
      font-family: "Segoe UI", sans-serif;
      background: #f4f4f9;
      margin: 0;
      padding: 20px;
    }
    .novel-list {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
      gap: 20px;
    }
    .novel {
      background: #fff;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 4px 10px rgba(0,0,0,0.1);
      transition: transform 0.2s ease-in-out;
    }
    .novel:hover {
      transform: translateY(-5px);
    }
    .novel img {
      width: 100%;
      height: 280px;
      object-fit: cover;
    }
    .title {
      font-size: 16px;
      font-weight: bold;
      margin: 10px;
      color: #333;
      line-height: 1.3em;
    }
    .top {
      display: flex;
      justify-content: space-between;
      padding: 8px 12px 12px;
      font-size: 13px;
      color: #666;
    }
    .top-left, .top-right {
      background: #f0f0f0;
      padding: 4px 8px;
      border-radius: 8px;
    }
  </style>''';
  }

  static String get _getDirStyleTag {
    return '''
 <style>
    body {
      font-family: "Segoe UI", sans-serif;
      background: #f4f6fa;
      margin: 0;
      padding: 20px;
    }
    .file {
      background: #fff;
      border-radius: 12px;
      padding: 16px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.08);
      margin-bottom: 20px;
      transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
    }
    .file:hover {
      transform: translateY(-5px);
      box-shadow: 0 6px 16px rgba(0,0,0,0.15);
    }
    .title {
      font-size: 16px;
      font-weight: bold;
      margin-bottom: 8px;
      color: #2c3e50;
      word-break: break-word;
    }
    .size, .date, .type {
      font-size: 14px;
      color: #555;
      margin-bottom: 6px;
    }
    .size::before {
      content: "📦 ";
    }
    .type::before {
      content: "📄 ";
      color: #27ae60;
      font-weight: bold;
    }
    .type {
      color: #27ae60; /* အစိမ်းလေး */
    }
    .date::before {
      content: "📅 ";
    }
    .download {
      margin-top: 12px;
    }
    .download a {
      display: inline-block;
      background: #3498db;
      color: #fff;
      text-decoration: none;
      padding: 10px 16px;
      border-radius: 8px;
      font-size: 14px;
      font-weight: bold;
      transition: background 0.2s ease-in-out;
    }
    .download a:hover {
      background: #2980b9;
    }
    .download a::before {
      content: "⬇️ ";
    }
  </style>
''';
  }
}
