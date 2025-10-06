import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_widgets/widgets/t_search_field.dart';

import '../../core/models/novel.dart';
import '../components/wrap_list_tile.dart';

class NovelSearchScreen extends StatefulWidget {
  List<Novel> list;
  void Function(String title, List<Novel> list) onClicked;
  Widget? Function(BuildContext context, Novel novel) listItemBuilder;
  NovelSearchScreen({
    super.key,
    required this.list,
    required this.listItemBuilder,
    required this.onClicked,
  });

  @override
  State<NovelSearchScreen> createState() => _NovelSearchScreenState();
}

class _NovelSearchScreenState extends State<NovelSearchScreen> {
  List<Novel> resultList = [];
  bool isSearched = false;
  bool isSearching = false;
  Timer? _delaySearchTimer;

  @override
  void dispose() {
    _delaySearchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _getAppbar(), body: _searchChanged());
  }

  AppBar _getAppbar() {
    return AppBar(
      title: TSearchField(
        autofocus: false,
        onChanged: (text) {
          if (!isSearching) {
            setState(() {
              isSearching = true;
            });
          }
          if (_delaySearchTimer?.isActive ?? false) {
            _delaySearchTimer?.cancel();
          }
          _delaySearchTimer = Timer(Duration(milliseconds: 1200), () {
            if (isSearching) {
              setState(() {
                isSearching = false;
              });
            }
            _onSearch(text);
          });
        },
        onSubmitted: (text) {
          if (!isSearching) {
            setState(() {
              isSearching = true;
            });
          }
          _onSearch(text);
        },
        onCleared: () {
          setState(() {
            isSearched = false;
          });
        },
      ),
    );
  }

  Widget _getSliverResultList() {
    return CustomScrollView(
      slivers: [
        // is searching
        SliverToBoxAdapter(
          child: isSearching ? LinearProgressIndicator() : null,
        ),
        SliverList.separated(
          itemCount: resultList.length,
          itemBuilder: (context, index) =>
              widget.listItemBuilder(context, resultList[index]),
          separatorBuilder: (context, index) => Divider(),
        ),
      ],
    );
  }

  Widget _getSliverHomeList() {
    final authorList = widget.list.map((e) => e.author).toSet().toList();
    final transList = widget.list.map((e) => e.translator).toSet().toList();
    final mcList = widget.list.map((e) => e.mc).toSet().toList();
    final tagsList = widget.list.expand((e) => e.getTags).toSet().toList();
    authorList.sort((a, b) => a.compareTo(b));
    transList.sort((a, b) => a.compareTo(b));
    mcList.sort((a, b) => a.compareTo(b));
    tagsList.sort((a, b) => a.compareTo(b));

    return CustomScrollView(
      slivers: [
        // is searching
        SliverToBoxAdapter(
          child: isSearching ? LinearProgressIndicator() : null,
        ),
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
      return _getSliverResultList();
    }
    return _getSliverHomeList();
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
      final searchText = text.toLowerCase().trim();
      final title = e.title.toLowerCase().trim();
      final author = e.author.toLowerCase().trim();
      final translator = e.translator.toLowerCase().trim();
      final mc = e.mc.toLowerCase().trim();

      if (title.contains(searchText)) {
        return true;
      }
      // search author
      if (author.contains(searchText)) {
        return true;
      }
      // translator
      if (translator.contains(searchText)) {
        return true;
      }
      // search mc
      if (mc.contains(searchText)) {
        return true;
      }
      return false;
    }).toList();
    setState(() {
      isSearched = true;
      isSearching = false;
    });
  }
}
