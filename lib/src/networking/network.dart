import 'dart:convert';

import 'package:http/http.dart';

class Network {
  final Map<String, String> _receiverPeers = <String, String>{};
  final List<String> _requestPeers = <String>[];

  List<String> get requestNodes => _requestPeers;

  void registerRequestNode(String networkAddress) {
    _requestPeers.add(networkAddress);
  }

  void unregisterRequestNode(String walletAddress, String networkAddress) {
    _requestPeers.remove(walletAddress);
  }

  void registerReceiveNode(String walletAddress, String networkAddress) {
    _receiverPeers[walletAddress] = networkAddress;
  }

  void unregisterReceiveNode(String walletAddress, String networkAddress) {
    _receiverPeers.remove(walletAddress);
  }

  void broadcast(String path, Map message) {
    var broadcastMessage = jsonEncode(message);
    for (var node in _receiverPeers.values) {
      post(node + path,
              headers: {'Content-Type': 'application/json'},
              body: broadcastMessage)
          .timeout(Duration(seconds: 20))
          .catchError(print);
    }
    for (var node in requestNodes) {
      post(node + path,
          headers: {'Content-Type': 'application/json'},
          body: broadcastMessage)
          .timeout(Duration(seconds: 20))
          .catchError(print);
    }
  }

  Future<Map<String, dynamic>> request(String path) async {
    var results = <Map<String, dynamic>, int>{};
    for (var node in _requestPeers) {
      var response = await get(node + path)
          .timeout(Duration(seconds: 10))
          .catchError(print);
      var responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      results[responseBody] += 1;
    }
    var result = <String, dynamic>{};
    var votes = 0;
    results.forEach((key, value) {
      if (value > votes) {
        result = key;
        votes = value;
      }
    });
    return result;
  }
}
