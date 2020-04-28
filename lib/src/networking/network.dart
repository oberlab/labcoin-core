import 'dart:convert';

import 'package:http/http.dart';

class Network {
  Map<String, String> _peers;

  void registerNode(String walletAddress, String networkAddress) {
    _peers[walletAddress] = networkAddress;
  }

  void unregisterNode(String walletAddress, String networkAddress) {
    _peers.remove(walletAddress);
  }

  void broadcast(String path, Map message) {
    var broadcastMessage = jsonEncode(message);
    for (var node in _peers.values) {
      post(node + path,
              headers: {'Content-Type': 'application/json'},
              body: broadcastMessage)
          .timeout(Duration(seconds: 20))
          .catchError(print);
    }
  }
}
