import 'dart:io';

import 'package:labcoin/labcoin.dart';

Future<void> main(List<String> args) async {
  var difficulty = 3;
  var blockchain = Blockchain();

  var argResults = getArgParser().parse(args);

  if (argResults['help']) {
    print('Labcoin Full Node Help\n\$ labcoin\n\nOptions:');
    print(getArgParser().usage);
    exit(0);
  }

  var config;

  if (argResults['config'] != null) {
    var configFile = File(argResults['config']);
    if (configFile.existsSync()) {
      try {
        config = Config.fromFile(configFile);
      } catch (e) {
        print('The Config-File seems to be broken :(');
        exit(1);
      }
    } else {
      print('The File does not exist!');
      exit(1);
    }
  } else {
    config = Config.fromArgResults(argResults);
  }

  var memPool = MemPool(config.memPoolAge, config.network);

  if (config.variant == BlockchainVariants.genesis) {
    if (config.hasWallet) {
      config.storageManager.init();
      blockchain = Blockchain.newGenesis(config.creatorWallet,
          difficulty: difficulty,
          storageManager: config.storageManager,
          network: config.network);
    } else {
      print('You need a private key to create the genesis Block!');
      exit(1);
    }
  } else if (config.variant == BlockchainVariants.network) {
    if (config.network.requestNodes.isNotEmpty) {
      if (config.isPersistent) config.storageManager.init();
      blockchain = await Blockchain.fromNetwork(config.network,
          storageManager: config.storageManager, difficulty: difficulty);
      memPool = await MemPool.fromNetwork(config.network, config.memPoolAge);
    } else {
      print('You need at least one Node in the Network!');
      exit(1);
    }
  } else if (config.variant == BlockchainVariants.local) {
    if (config.isPersistent) {
      blockchain = Blockchain(
          storageManager: config.storageManager,
          difficulty: difficulty,
          network: config.network);
      blockchain.chain = config.storageManager.storedBlockchain.chain;
    } else {
      print('You need to provide a path to the saved blockchain.');
      exit(1);
    }
  }

  var restService =
      RestService(blockchain, memPool, config.network, port: config.port);

  restService.run();
}
