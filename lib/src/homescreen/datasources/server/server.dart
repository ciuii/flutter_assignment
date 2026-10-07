import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

List<Map<String, dynamic>> entries = [];
List<WebSocketChannel> clients = [];

void _broadcastChange(String type, Map<String, dynamic> entry) {
  final message = jsonEncode({'type': type, 'entry': entry});
  for (final client in clients) {
    client.sink.add(message);
  }
}
void main() async {
  final router = Router();


  router.get('/ws', webSocketHandler((WebSocketChannel webSocket, String? protocol) {
    clients.add(webSocket);
    print('[SERVER] New WebSocket connection. Total clients: ${clients.length}');
    webSocket.stream.listen((message) {
      print('[SERVER] Received WS message: $message');
    }, onDone: () {
      clients.remove(webSocket);
      print('[SERVER] WebSocket disconnected. Total clients: ${clients.length}');
    });
  }));

  router.get('/entries', (Request request) {
    print('[SERVER] GET /entries');
    return Response.ok(jsonEncode(entries), headers: {'Content-Type': 'application/json'});
  });

  router.post('/entries', (Request request) async {
    final payload = await request.readAsString();
    final entry = jsonDecode(payload) as Map<String, dynamic>;
    entry['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    entries.add(entry);
    print('[SERVER] POST /entries: ${entry['id']}');
    _broadcastChange('create', entry);
    return Response.ok(jsonEncode(entry), headers: {'Content-Type': 'application/json'});
  });

  router.put('/entries/<id>', (Request request, String id) async {
    final payload = await request.readAsString();
    final entry = jsonDecode(payload) as Map<String, dynamic>;
    final index = entries.indexWhere((e) => e['id'] == id);
    if(index != -1) {
      entry['id'] = id;
      entries[index] = entry;
      print('[SERVER] PUT /entries/$id: $entry - Updated');
      _broadcastChange('update', entry);
      return Response.ok(jsonEncode(entry), headers: {'Content-Type': 'application/json'});
    }
    return Response.notFound('Entry not found');
    });
  router.delete('/entries/<id>', (Request request, String id) async {
    final index = entries.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      entries.removeAt(index);
      print('[SERVER] DELETE /entries/$id: Removed');
      _broadcastChange('delete', {'id': id});

      return Response.ok('Entry deleted');
    }
    return Response.notFound('Entry not found');
  });
  final server = await shelf_io.serve(router.call, InternetAddress.anyIPv4, 8080);
  print('[SERVER] Listening on http://${server.address.host}:${server.port}');


}