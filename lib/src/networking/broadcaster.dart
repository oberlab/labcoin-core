import 'dart:convert';

import 'package:http/http.dart';

class Broadcaster {
  List<String> nodes = [];
  Broadcaster(this.nodes);
  void broadcast(String path, Map message) {
    var broadcastMessage = jsonEncode(message);
    for (var node in nodes) {
      post(node + path,
              headers: {'Content-Type': 'application/json'},
              body: broadcastMessage)
          .timeout(Duration(minutes: 1))
          .catchError(print);
    }
  }
}
