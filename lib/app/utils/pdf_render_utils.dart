Future<void> savePdfPageAsImage(String pdfPath, String coverPath) async {
  // final coverFile = File(coverPath);
  // if (!await coverFile.exists()) {
  //   final doc = await PdfDocument.openFile(pdfPath);
  //   final page = await doc.getPage(1); // First page (0-based index)

  //   // Render the page into an image with width and height defined
  //   final img = await page.render(width: 150, height: 150);

  //   // print(img);

  //   // Save the rendered image as a PNG file

  //   await coverFile.writeAsBytes(img.pixels);

  //   // Dispose resources
  //   await doc.dispose();
  // }
}
