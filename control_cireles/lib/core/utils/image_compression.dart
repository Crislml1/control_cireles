import 'dart:typed_data';

import 'package:image/image.dart' as img;

Future<Uint8List> compressImageForUpload(Uint8List bytes) async {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    return bytes;
  }

  final resized = decoded.width > 1280
      ? img.copyResize(decoded, width: 1280)
      : decoded;

  return Uint8List.fromList(
    img.encodeJpg(resized, quality: 78),
  );
}
