import 'dart:html' as html;
import 'file_saver.dart';

class WebFileSaver implements FileSaver {
  @override
  Future<void> saveAndShare(String fileName, String content) async {
    final bytes = html.Blob([content], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(bytes);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

FileSaver getFileSaver() => WebFileSaver();
