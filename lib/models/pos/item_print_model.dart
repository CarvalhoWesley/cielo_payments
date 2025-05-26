import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cielo_payments/enums/pos/align_mode_enum.dart';
import 'package:cielo_payments/enums/pos/type_face_enum.dart';
import 'package:path_provider/path_provider.dart';

class ItemPrintModel {
  final String type;
  final AlignModeEnum? align;
  final TypeFaceEnum? typeFace;
  final String? content;
  final int? height;
  final int? lines;

  ItemPrintModel.text({
    required this.content,
    this.align = AlignModeEnum.left,
    this.typeFace = TypeFaceEnum.normal,
  })  : type = "text",
        height = null,
        lines = null;

  ItemPrintModel.qrcode({
    required this.content,
    this.align = AlignModeEnum.center,
    this.height = 200,
  })  : type = "qrcode",
        typeFace = null,
        lines = null;

  ItemPrintModel.barcode({
    required this.content,
    this.align = AlignModeEnum.center,
  })  : type = "barcode",
        typeFace = null,
        height = null,
        lines = null;

  ItemPrintModel.image({
    required this.content,
  })  : type = "image",
        typeFace = null,
        lines = null,
        height = null,
        align = null;

  ItemPrintModel.linewrap({this.lines = 1})
      : type = "linewrap",
        align = null,
        typeFace = null,
        content = null,
        height = null;

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "align": align?.value, // Pega o value do enum Align
      "fontFormat": typeFace?.value, // Pega o value do enum FontFormat
      "content": content,
      "height": height,
      "lines": lines,
    };
  }

  Future<Object> toPrint() async {
    if (type == 'image') {
      final filePath = await _saveImageFile();
      return {
        "operation": "PRINT_IMAGE",
        "styles": [{}],
        "value": [filePath],
      };
    } else if (type == 'linewrap') {
      return {
        "operation": "PRINT_TEXT",
        "styles": [{}],
        "value": List.filled(lines ?? 0, " \n"),
      };
    } else {
      return {
        "operation": "PRINT_TEXT",
        "styles": [
          {
            "key_attributes_align": align?.value,
            "key_attributes_typeface": typeFace?.value,
          }
        ],
        "value": [content],
      };
    }
  }

  Future<String> _saveImageFile() async {
    final directory = await getExternalStorageDirectory();
    final filePath =
        '${directory?.path}/${DateTime.now().millisecondsSinceEpoch}.png';

    // Decodifica a string base64 para bytes
    Uint8List bytes = base64Decode(content!);

    // Salva os bytes como arquivo
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }
}
