import 'dart:isolate';

import 'package:labcoin/labcoin.dart';

class WebserverModel {
  final SendPort sendPort;
  final int port;
  final StorageManager storageManager;

  WebserverModel(this.sendPort, this.port, this.storageManager);
}
