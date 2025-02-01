//linux
//sudo apt-get install poppler-utils

import 'dart:io';

import 'package:crypto/crypto.dart';

void getPdfCacheList() {}

Future<String> getPdfHash(String pdfPath) async {
  // Read the PDF file as bytes
  File file = File(pdfPath);
  List<int> fileBytes = await file.readAsBytes();

  // Create an MD5 hash of the file's bytes
  var digest = md5.convert(fileBytes);

  // Return the hash as a string
  return digest.toString();
}
