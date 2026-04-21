import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class PdfSingleReaderSettingDialogResponse {
  final double zoomRange;
  const PdfSingleReaderSettingDialogResponse({required this.zoomRange});
}

class PdfSingleReaderSettingDialog extends StatefulWidget {
  final void Function(PdfSingleReaderSettingDialogResponse result)? onClosed;
  const PdfSingleReaderSettingDialog({super.key, this.onClosed});

  static double get getPdfRange =>
      TRecentDB.getInstance.getDouble('pdf-single-reader-zoom-range', def: 0.1);

  @override
  State<PdfSingleReaderSettingDialog> createState() =>
      _PdfSingleReaderSettingDialogState();
}

class _PdfSingleReaderSettingDialogState
    extends State<PdfSingleReaderSettingDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    zoomRangeController.dispose();
    super.dispose();
  }

  final zoomRangeController = TextEditingController();
  void init() {
    zoomRangeController.text = PdfSingleReaderSettingDialog.getPdfRange
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      content: TScrollableColumn(
        children: [
          TTextField(
            label: Text('Zoom Range'),
            maxLines: 1,
            controller: zoomRangeController,
            // inputFormatters: [FilteringTextInputFormatter.],
            textInputType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              if (value.isEmpty) return;
              TRecentDB.getInstance.putDouble(
                'pdf-single-reader-zoom-range',
                double.tryParse(value) ?? 0.1,
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onClosed?.call(
              PdfSingleReaderSettingDialogResponse(
                zoomRange: double.tryParse(zoomRangeController.text) ?? 0.1,
              ),
            );
            context.closeNavigator();
          },
          child: Text('သိမ်းမယ်'),
        ),
      ],
    );
  }
}
