import 'dart:typed_data';

/// Representasi file yang dipilih user, disimpan sebagai bytes
/// supaya kompatibel dengan Flutter Web (blob URL) maupun native (dart:io File).
class PickedAttachment {
  final Uint8List bytes;
  final String fileName;

  const PickedAttachment({
    required this.bytes,
    required this.fileName,
  });
}