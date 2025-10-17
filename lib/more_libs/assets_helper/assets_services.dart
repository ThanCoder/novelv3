import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/assets_helper/assets_file.dart';

class AssetsServices {
  static List<AssetsFile> getList() {
    List<AssetsFile> list = [];
    try {
      list.add(
        AssetsFile.create(
          id: '1',
          title: 'Static Server ကအနေ data သွင်းနည်း',
          assetsRootPath: 'assets/how_to_install_n3_data_form_static_server',
          assetFilesNumberCount: 15,
          desc:
              'Server ကနေ N3 Data File ကို download လုပ်ပြီးတော့ သွင်းပုံအဆင့်ဆင့်',
        ),
      );
      // n3 data
      list.add(
        AssetsFile.create(
          id: '2',
          title: 'N3 Data Files ကို Manager ကနေသွင်းနည်း',
          assetsRootPath: 'assets/how_to_install_n3_data_manager',
          assetFilesNumberCount: 4,
          desc: 'N3 Data Files သွင်းပုံအဆင့်ဆင့်',
        ),
      );
      list.add(
        AssetsFile.create(
          id: '3',
          title: 'N3 Data Files ထုတ်နည်း',
          assetsRootPath: 'assets/how_to_export_n3_data',
          assetFilesNumberCount: 6,
          desc: 'N3 Data Files ထုတ်ယူပုံအဆင့်ဆင့်',
        ),
      );
      // share
      list.add(
        AssetsFile.create(
          id: '4',
          title: 'Novel ပေးပို့နည်း',
          assetsRootPath: 'assets/how_to_share_data',
          assetFilesNumberCount: 3,
          desc: 'ကိုယ့်မှာ ရှိတဲ့ Novel တွေကိုအခြားသူကို ပေးပို့နည်း',
        ),
      );
      list.add(
        AssetsFile.create(
          id: '5',
          title: 'Novel ရယူနည်း',
          assetsRootPath: 'assets/how_to_receive_data',
          assetFilesNumberCount: 5,
          desc: 'အခြားသူပေးပို့လာတဲ့ Novel တွေကိုလက်ခံရယူနည်း',
        ),
      );
      //pdf reader
      list.add(
        AssetsFile.create(
          id: '6',
          title: 'PDF Reader တစ်ခုလိုမျိုး အသုံးပြုနည်း',
          assetsRootPath: 'assets/show_to_use_pdf_reader',
          assetFilesNumberCount: 4,
        ),
      );
    } catch (e) {
      debugPrint('[AssetsServices:getList]: ${e.toString()}');
    }
    return list;
  }
}
