import 'dart:convert';

abstract class FileSaver {
  Future<void> saveAndShare(String fileName, String content);
}

FileSaver getFileSaver() => throw UnsupportedError('Cannot create a saver');
