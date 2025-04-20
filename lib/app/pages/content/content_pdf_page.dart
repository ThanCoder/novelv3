import 'package:flutter/material.dart';
import 'package:novel_v3/app/action_buttons/novel_content_pdf_action_button.dart';
import 'package:novel_v3/app/components/pdf_list_item.dart';
import 'package:novel_v3/app/dialogs/core/confirm_dialog.dart';
import 'package:novel_v3/app/dialogs/pdf_config_edit_dialog.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/provider/pdf_provider.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:novel_v3/app/widgets/index.dart';
import 'package:provider/provider.dart';

import '../../components/core/index.dart';

class ContentPdfPage extends StatefulWidget {
  const ContentPdfPage({super.key});

  @override
  State<ContentPdfPage> createState() => _ContentPdfPageState();
}

class _ContentPdfPageState extends State<ContentPdfPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    if (!mounted) return;
    context.read<PdfProvider>().initList(novelPath: novel.path, isReset: true);
  }

  void _deleteConfirm(PdfModel pdf) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: '`${pdf.title}` ကိုဖျက်ချင်တာ သေချာပြီလား?`',
        submitText: 'Delete',
        onCancel: () {},
        onSubmit: () async {
          try {
            //ui
            context.read<PdfProvider>().delete(pdf);
          } catch (e) {
            if (!mounted) return;
            showDialogMessage(context, e.toString());
          }
        },
      ),
    );
  }

  void _restorePath(PdfModel pdf) {
    try {
      context.read<PdfProvider>().restore(pdf);
    } catch (e) {
      if (!mounted) return;
      showDialogMessage(context, e.toString());
    }
  }

  void _editConfig(PdfModel pdf) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PdfConfigEditDialog(
        config: pdf.getConfig(),
        onApply: (config) {
          pdf.setConfig(config);
        },
      ),
    );
  }

  void _showContextMenu(PdfModel pdf) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 100,
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.copy_all),
                title: const Text('Copy Name'),
                onTap: () {
                  Navigator.pop(context);
                  copyText(pdf.title);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_document),
                title: const Text('Edit Config'),
                onTap: () {
                  Navigator.pop(context);
                  _editConfig(pdf);
                },
              ),
              ListTile(
                iconColor: Colors.yellow,
                leading: const Icon(Icons.restore),
                title: const Text('အပြင်ထုတ်'),
                onTap: () {
                  Navigator.pop(context);
                  _restorePath(pdf);
                },
              ),
              //delete
              ListTile(
                iconColor: Colors.red,
                leading: const Icon(Icons.delete_forever_rounded),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteConfirm(pdf);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PdfProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    return MyScaffold(
      contentPadding: 0,
      appBar: AppBar(
        title: const Text('PDF'),
        actions: [
          NovelContentPdfActionButton(),
        ],
      ),
      body: isLoading
          ? TLoader()
          : RefreshIndicator(
              onRefresh: init,
              child: ListView.builder(
                itemBuilder: (context, index) => PdfListItem(
                  pdf: list[index],
                  onClicked: (pdf) {
                    goPdfReader(context, pdf);
                  },
                  onLongClicked: _showContextMenu,
                ),
                itemCount: list.length,
              ),
            ),
    );
  }
}
