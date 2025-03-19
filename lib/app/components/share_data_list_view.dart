import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/share_data_model.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/utils/app_util.dart';

import '../widgets/index.dart';

class ShareDataListView extends StatelessWidget {
  List<ShareDataModel> shareDataList;
  void Function(ShareDataModel shareData)? onClick;
  void Function(ShareDataModel shareData)? onLongClick;
  void Function(ShareDataModel shareData)? onDownloadClick;
  ScrollController? controller;
  ShareDataListView({
    super.key,
    required this.shareDataList,
    this.onClick,
    this.onLongClick,
    this.controller,
    this.onDownloadClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) => _ListItem(
              shareData: shareDataList[index],
              onClick: (shareData) {
                if (onClick != null) {
                  onClick!(shareData);
                }
              },
              onLongClick: (shareData) {
                if (onLongClick != null) {
                  onLongClick!(shareData);
                }
              },
              onDownloadClick: (shareData) {
                if (onDownloadClick != null) {
                  onDownloadClick!(shareData);
                }
              },
            ),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: shareDataList.length);
  }
}

class _ListItem extends StatelessWidget {
  ShareDataModel shareData;
  void Function(ShareDataModel shareData) onClick;
  void Function(ShareDataModel shareData) onLongClick;
  void Function(ShareDataModel shareData) onDownloadClick;
  _ListItem({
    super.key,
    required this.shareData,
    required this.onClick,
    required this.onLongClick,
    required this.onDownloadClick,
  });

  Widget _getContent() {
    if (shareData.name.split('.').last == 'png') {
      String url =
          'http://${wififHostAddressNotifier.value}:$serverPort/download?path=${shareData.path}';
      return GestureDetector(
        onTap: () => onClick(shareData),
        onLongPress: () => onLongClick(shareData),
        child: Row(
          spacing: 10,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: MyImageUrl(
                url: url,
                borderRadius: 5,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shareData.name,
                    // overflow: TextOverflow.ellipsis,
                  ),
                  Text('size: ${AppUtil.instance.getParseFileSize(shareData.size.toDouble())}'),
                  Text('Date: ${AppUtil.instance.getParseDate(shareData.date)}'),
                ],
              ),
            ),
            IconButton(
              onPressed: () => onDownloadClick(shareData),
              icon: const Icon(Icons.download),
            ),
          ],
        ),
      );
    }
    //list tile
    return ListTile(
      // textColor: shareData.isExists ? Colors.red : null,
      onTap: () => onClick(shareData),
      onLongPress: () => onLongClick(shareData),
      title: Text(
          '${shareData.name}\nsize: ${AppUtil.instance.getParseFileSize(shareData.size.toDouble())}\nDate: ${AppUtil.instance.getParseDate(shareData.date)}'),
      trailing: IconButton(
        onPressed: () => onDownloadClick(shareData),
        icon: const Icon(Icons.download),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            shareData.isExists ? const Color.fromARGB(138, 196, 77, 68) : null,
        borderRadius: BorderRadius.circular(5),
      ),
      child: _getContent(),
    );
  }
}
