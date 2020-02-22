import 'dart:io';
import 'dart:isolate';

import 'package:labcoin/labcoin.dart';

Future<void> runBlockchainValidator(ValidatorModel params) async {
  var wallet = params.wallet;
  var storageManager = params.storageManager;
  var broadcaster = params.broadcaster;
  var initOverNetwork = params.initOverNetwork;

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

void runWebServer(WebserverModel params) {
  var storageManager = params.storageManager;
  var port = params.port;
  var getFromMainThread = ReceivePort();
  params.sendPort.send(getFromMainThread.sendPort);
  getFromMainThread.listen((data) {
    print(data);
  });
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

  var receiveBlockchain = ReceivePort();
  var receiveWebserver = ReceivePort();

  var webServer = Isolate.spawn(
      runWebServer,
      WebserverModel(receiveWebserver.sendPort, port, storageManager));
  runBlockchainValidator(ValidatorModel(receiveBlockchain.sendPort,
       wallet, storageManager, broadcaster, arguments['init']));
}
