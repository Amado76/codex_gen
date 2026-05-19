import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<Uint8List?> pickImageFromDisk() async {
  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.click();

  await input.onChange.first;
  if (input.files == null || input.files!.isEmpty) return null;

  final reader = html.FileReader();
  reader.readAsArrayBuffer(input.files!.first);
  await reader.onLoad.first;

  final result = reader.result;
  if (result is! List<int>) return null;
  return Uint8List.fromList(result);
}
