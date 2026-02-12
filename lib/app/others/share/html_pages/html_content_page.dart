import 'package:dart_html_dsl/dart_html_dsl.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/app/others/share/libs/novel_file.dart';
import 'package:than_pkg/than_pkg.dart';


class HtmlContentPage extends Html5Page {
  final Novel novel;
  final List<NovelFile> files;
  HtmlContentPage({required this.novel, required this.files})
    : super(
        pageProps: PageProps(
          title: novel.meta.title,
          cssStyles: [CssStyle.fromSource(_styleSource)],
        ),
      );

  @override
  HtmlWidget build() {
    return ColumnWidget(
      children: [
        Text(novel.meta.desc.replaceAll('\n', '<br/>')),
        // HtmlSizedBox(height: 20.px),
        ColumnWidget(
          className: 'file-list',
          children: List.generate(
            files.length,
            (index) => _getItem(files[index]),
          ),
        ),
      ],
    );
  }

  HtmlWidget _getItem(NovelFile file) {
    return ColumnWidget(
      className: 'file',
      children: [
        Div(className: 'title', child: Text(file.name)),
        Div(
          className: 'size',
          child: Text('Size: ${file.size.getSizeLabel()}'),
        ),
        file.mime.isNotEmpty
            ? Div(className: 'type', child: Text(file.mime))
            : EmptyWidget(),
        Div(className: 'date', child: Text('Date: ${file.date.toParseTime()}')),

        ColumnWidget(
          className: 'download',
          children: [
            Link(
              href: "/download/id/${novel.id}/name/${file.name}",
              child: Text('Download')
            ),
          ],
        ),
      ],
    );
  }
}

//     <div>${novel.meta.desc.replaceAll('\n', '<br/>')}</div>
//   <div class="file-list">
//     ${files.map((file) {
//           final data = '''
//   <div class="file">
//   <div class="title">${file.name}</div>
//   <div class="size">Size: ${file.size.toFileSizeLabel()}</div>
//  ${file.mime.isNotEmpty ? ' <div class="type">Type: ${file.mime}</div>' : ''}
//   <div class="date">Date: ${file.date.toParseTime()}</div>
//   <div class="download">
//     <a href="/download/id/${novel.id}/name/${file.name}">Download</a>
//   </div>
//   </div>
//       ''';
//           return data;
//         }).join('\n')}
//   </div>

const _styleSource = '''body {
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
    ''';
