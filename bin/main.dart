import 'dart:io';
import 'dart:isolate';

import 'package:args/args.dart';
import 'package:labcoin/labcoin.dart';

void runBlockchainValidator(List params) {
  Wallet wallet = params[0];
  StorageManager storageManager = params[1];
  Broadcaster broadcaster = params[2];

  Blockchain blockchain =
      Blockchain(wallet, storageManager, broadcaster: broadcaster);
  if (storageManager.BlockchainBlocks.length >= 1) {
    print('Loading existing Blockchain');
    blockchain = storageManager.storedBlockchain;
    blockchain.creatorWallet = wallet;
    blockchain.broadcaster = broadcaster;
    if (!blockchain.isValid) {
      print('The Blockchain is invalid!');
      return;
    }
  }
  while (true) {
    if (storageManager.pendingTransactions.length > 2) {
      print('Start mining a Block');
      final stopwatch = Stopwatch()..start();
      blockchain.createBlock();
      StakeManager.getValidator(storageManager.BlockchainBlocks);
      print('The mining Process was completed in ${stopwatch.elapsed}');
    } else {
      sleep(Duration(seconds: 10));
    }
  }
}

void runWebServer(List params) {
  StorageManager storageManager = params[0];
  int port = params[1];
  RestHandler restHandler = RestHandler(storageManager, port);
  restHandler.run();
}

void main(List<String> args) {
  ArgResults arguments = getArgParser().parse(args);

  Broadcaster broadcaster = Broadcaster([]);

  int port = int.parse(arguments['port']);
  StorageManager storageManager = StorageManager(arguments['storage']);
  Wallet wallet = Wallet(arguments['private-key']);

  if (arguments['init']) storageManager.init();

  Future<Isolate> webServer =
      Isolate.spawn(runWebServer, [storageManager, port]);
  runBlockchainValidator([wallet, storageManager, broadcaster]);
}
