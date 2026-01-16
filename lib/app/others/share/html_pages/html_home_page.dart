import 'package:dart_html_dsl/dart_html_dsl.dart';
import 'package:novel_v3/app/core/models/novel.dart';

class HtmlHomePage extends Html5Page {
  final List<Novel> list;
  HtmlHomePage(this.list)
    : super(
        pageProps: PageProps(
          title: 'Novel Share',
          cssStyles: [CssStyle.fromSource(cssStyleSource)],
        ),
      );
  @override
  HtmlWidget build() {
    return ColumnWidget(
      className: 'novel-list',
      children: List.generate(
        list.length,
        (index) => _getListItem(list[index]),
      ),
    );
  }

  HtmlWidget _getListItem(Novel novel) {
    return Div(
      className: 'novel',
      child: Link(
        href: "/view/novel/${novel.id}",
        child: ColumnWidget(
          children: [
            Img(src: "/cover/id/${novel.id}"),
            Text(novel.meta.title),
            ColumnWidget(
              className: 'top',
              children: [
                if (novel.meta.isAdult)
                  Div(className: 'top-left', child: Text('IsAdult'))
                else
                  EmptyWidget(),
                Div(
                  className: 'top-right',
                  child: Text(novel.meta.isCompleted ? 'OnGoing' : 'Completed'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const cssStyleSource = '''a {
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
    }''';
