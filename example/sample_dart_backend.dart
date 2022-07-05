import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:stream_cipher/stream_cipher.dart';

import 'http_request_cipher_example.dart';

Future<HttpServer> dartBackEnd() async {
  final webServer = Router()
    ..post(
      '/decoded_echo',
      (Request request) async {
        final decrypter = AESByteDataDecrypter.empty();
        final deStream = decrypter.alterDecryptStream(
          request.read().asyncMap(Uint8List.fromList),
          streamMeta: const EncryptStreamMeta(
            ending: '#ENDING#',
            separator: '#SEPARATOR#',
          ),
        );
        final buffer = <int>[];
        await deStream.forEach(buffer.addAll);
        return Response(200, body: String.fromCharCodes(buffer));
      },
    )
    ..post(
      '/raw_echo',
      (Request request) async {
        return Response(200, body: request.read());
      },
    );
  final server = await serve(webServer, '0.0.0.0', kServerPort);
  print('awaiting for request on port $kServerPort');
  return server;
}
