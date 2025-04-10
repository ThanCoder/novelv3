import 'package:flutter/material.dart';

import '../../models/core/genres_model.dart';

class GenresListView extends StatelessWidget {
  List<GenresModel> genresList;
  void Function(GenresModel genres) onClick;
  void Function(GenresModel genres)? onLongClick;
  void Function(GenresModel genres, bool isSelected) onSelectChanged;
  void Function(GenresModel genres) onDeleted;
  GenresListView({
    super.key,
    required this.genresList,
    required this.onClick,
    required this.onSelectChanged,
    required this.onDeleted,
    this.onLongClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => _ListItem(
        genres: genresList[index],
        onClick: onClick,
        onLongClick: (genres) {
          if (onLongClick != null) {
            onLongClick!(genres);
          }
        },
        onSelectChanged: onSelectChanged,
        onDeleted: onDeleted,
      ),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: genresList.length,
    );
  }
}

class _ListItem extends StatelessWidget {
  GenresModel genres;
  void Function(GenresModel genres) onClick;
  void Function(GenresModel genres) onLongClick;
  void Function(GenresModel genres, bool isSelected) onSelectChanged;
  void Function(GenresModel genres) onDeleted;
  _ListItem({
    required this.genres,
    required this.onClick,
    required this.onLongClick,
    required this.onSelectChanged,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: genres.isSelected,
          onChanged: (val) => onSelectChanged(genres, val!),
        ),
        Text(genres.title),
        const Spacer(),
        IconButton(
          color: Colors.red[900],
          onPressed: () => onDeleted(genres),
          icon: const Icon(Icons.delete_forever),
        ),
      ],
    );
  }
}
