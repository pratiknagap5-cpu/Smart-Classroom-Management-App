import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'file_saver.dart';

class MobileFileSaver implements FileSaver {
  @override
  Future<void> saveAndShare(String fileName, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Data Backup',
    );
  }
}

FileSaver getFileSaver() => MobileFileSaver();
