// Helper class (can be in the same file or imported)
import 'dart:typed_data';

class UploadableFile {
  final String name;
  final Uint8List bytes;


  UploadableFile({required this.name, required this.bytes});
}