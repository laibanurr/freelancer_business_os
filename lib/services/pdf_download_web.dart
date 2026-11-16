import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

void downloadPdfBytes(Uint8List bytes, String filename) {
  final blobDataFileBlob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final stringLinkUrlToken = web.URL.createObjectURL(blobDataFileBlob);

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = stringLinkUrlToken;
  anchor.download = filename;

  web.document.body?.appendChild(anchor);
  anchor.click();

  web.document.body?.removeChild(anchor);
  web.URL.revokeObjectURL(stringLinkUrlToken);
}
