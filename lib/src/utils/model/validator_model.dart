import 'dart:isolate';

import 'package:labcoin/labcoin.dart';

class ValidatorModel {
  final SendPort sendPort;
  final Wallet wallet;
  final StorageManager storageManager;
  final Broadcaster broadcaster;
  final bool initOverNetwork;

  ValidatorModel(this.sendPort, this.wallet, this.storageManager,
      this.broadcaster, this.initOverNetwork);
}
