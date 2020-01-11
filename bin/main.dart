import 'dart:io';
import 'dart:isolate';

import 'package:labcoin/labcoin.dart';

Future<void> runBlockchainValidator(List params) async {
  Wallet wallet = params[0];
  StorageManager storageManager = params[1];
  Broadcaster broadcaster = params[2];
  bool initOverNetwork = params[3];

  var blockchain = Blockchain(wallet, storageManager, broadcaster: broadcaster);
  if (initOverNetwork) {
    print('Loading Blockchain from the Network');
    blockchain =
        await Blockchain.fromNetwork(broadcaster.nodes, wallet, storageManager);
  } else if (storageManager.BlockchainBlocks.isNotEmpty) {
    print('Loading existing Blockchain');
    blockchain = storageManager.storedBlockchain;
    blockchain.creatorWallet = wallet;
    blockchain.broadcaster = broadcaster;
  }

  if (!blockchain.isValid) {
    print('The Blockchain is invalid!');
    return;
  }

  while (true) {
    if (storageManager.pendingTransactions.length > 2) {
      print('Start mining a Block');
      final stopwatch = Stopwatch()..start();
      blockchain.createBlock();
      print('The mining Process was completed in ${stopwatch.elapsed}');
    } else {
      sleep(Duration(seconds: 10));
    }
  }
}

void runWebServer(List params) {
  StorageManager storageManager = params[0];
  int port = params[1];
  var restHandler = RestHandler(storageManager, port);
  restHandler.run();
}

void main(List<String> args) {
  var arguments = getArgParser().parse(args);

  var networkList = <String>[];
  if (arguments['network'] != null) {
    networkList = arguments['network'].split(',');
  }
  var broadcaster = Broadcaster(networkList);

  var port = int.parse(arguments['port']);
  var storageManager = StorageManager(arguments['storage']);
  var wallet = Wallet(arguments['private-key']);

  if (arguments['init']) storageManager.init();

  var webServer = Isolate.spawn(runWebServer, [storageManager, port]);
  runBlockchainValidator(
      [wallet, storageManager, broadcaster, arguments['init']]);
}
