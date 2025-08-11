import 'package:flutter/material.dart';
import 'package:t_widgets/widgets/t_search_field.dart';

import '../components/wrap_list_tile.dart';
import '../models/uploader_novel.dart';

class UploaderNovelSearchScreen extends StatefulWidget {
  List<UploaderNovel> list;
  void Function(String title, List<UploaderNovel> list) onClicked;
  Widget? Function(BuildContext context, UploaderNovel novel) listItemBuilder;
  UploaderNovelSearchScreen({
    super.key,
    required this.list,
    required this.listItemBuilder,
    required this.onClicked,
  });

  @override
  State<UploaderNovelSearchScreen> createState() =>
      _UploaderNovelSearchScreenState();
}

class _UploaderNovelSearchScreenState extends State<UploaderNovelSearchScreen> {
  List<UploaderNovel> resultList = [];
  bool isSearched = false;

  Widget _getResultList() {
    return ListView.separated(
      itemBuilder: (context, index) =>
          widget.listItemBuilder(context, resultList[index]),
      separatorBuilder: (context, index) => Divider(),
      itemCount: resultList.length,
    );
  }

  Widget _getHomeList() {
    final authorList = widget.list.map((e) => e.author).toSet().toList();
    final transList = widget.list.map((e) => e.translator).toSet().toList();
    final mcList = widget.list.map((e) => e.mc).toSet().toList();
    final tagsList = widget.list
        .expand((e) => e.getTags)
        .toSet()
        .toList();
    return CustomScrollView(
      slivers: [
        // author
        SliverToBoxAdapter(
          child: WrapListTile(
            title: Text('Author'),
            list: authorList,
            onClicked: (name) {
              final res = widget.list.where((e) => e.author == name).toList();
              widget.onClicked(name, res);
            },
          ),
        ),
        // translator
        SliverToBoxAdapter(
          child: WrapListTile(
            title: Text('Translator'),
            list: transList,
            onClicked: (name) {
              final res = widget.list
                  .where((e) => e.translator == name)
                  .toList();
              widget.onClicked(name, res);
            },
          ),
        ),
        // tags
        SliverToBoxAdapter(
          child: WrapListTile(
            title: Text('Tags'),
            list: tagsList,
            onClicked: (name) {
              final res = widget.list
                  .where((e) => e.getTags.contains(name))
                  .toList();
              widget.onClicked(name, res);
            },
          ),
        ),

        // mc
        SliverToBoxAdapter(
          child: WrapListTile(
            title: Text('MC'),
            list: mcList,
            onClicked: (name) {
              final res = widget.list.where((e) => e.mc == name).toList();
              widget.onClicked(name, res);
            },
          ),
        ),
      ],
    );
  }

  Widget _searchChanged() {
    if (isSearched) {
      if (resultList.isEmpty) {
        return Center(child: Text('မတွေ့ပါ....'));
      }
      return _getResultList();
    }
    return _getHomeList();
  }

  void _onSearch(String text) {
    if (text.isEmpty) {
      setState(() {
        isSearched = false;
      });
      return;
    }
    // search
    resultList = widget.list.where((e) {
      // search title
      if (e.title.toLowerCase().contains(text.toLowerCase())) {
        return true;
      }
      // search author
      if (e.author.toLowerCase().contains(text.toLowerCase())) {
        return true;
      }
      // search mc
      if (e.mc.toLowerCase().contains(text.toLowerCase())) {
        return true;
      }
      return false;
    }).toList();
    setState(() {
      isSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TSearchField(
          onChanged: _onSearch,
          onCleared: () {
            setState(() {
              isSearched = false;
            });
          },
        ),
      ),
      body: _searchChanged(),
    );
  }
}
