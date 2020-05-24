
import 'dart:io';

import 'package:labcoin/labcoin.dart';

// --private-key, -pK
// --network, -n
// --port, -p
// --init-storage
// --storage -s
// --mempool-age, -mA
// --variant

Future<void> main(List<String> args) async {
  var memPoolAge = 10000;
  var port = 3000;
  var difficulty = 3;
  var network = Network();
  var storage;
  var blockchain = Blockchain();

  var arguments = getArgParser().parse(args);

  if (arguments['help']) {
    print('Labcoin Full Node Help\n\$ labcoin\n\nOptions:');
    print(getArgParser().usage);
    exit(0);
  }

  if (isNumeric(arguments['mempool-age'])) {
    memPoolAge = int.parse(arguments['mempool-age']);
  }

  if (isNumeric(arguments['port'])) {
    port = int.parse(arguments['port']);
  }

  if (arguments['storage'] != null) {
    storage = StorageManager(arguments['storage']);
  }

  if (arguments['network'] != null) {
    var nodes = arguments['network'].toString().split(',');
    for (var node in nodes) {
      network.registerRequestNode(node);
    }
  }

  var memPool = MemPool(memPoolAge, network);

  var variant = BlockchainVariants.values.firstWhere((e) => e.toString() == 'BlockchainVariants.' + arguments['variant']);

  if (variant == BlockchainVariants.genesis){
    if (arguments['private-key'] != null) {
      storage.init();
      blockchain = Blockchain.newGenesis(Wallet(arguments['private-key']),
          difficulty: difficulty, storageManager: storage);
    } else {
      print('You need a private key to create the genesis Block!');
      exit(1);
    }
  } else if(variant == BlockchainVariants.network) {
    if (network.requestNodes.isNotEmpty) {
      storage.init();
      blockchain = await Blockchain.fromNetwork(network, storageManager: storage,
          difficulty: difficulty);
      memPool = await MemPool.fromNetwork(network, memPoolAge);
    } else {
      print('You need at least one Node in the Network!');
      exit(1);
    }
  } else if (variant == BlockchainVariants.local) {
    if (storage != null) {
      blockchain = Blockchain(storageManager: storage, difficulty: difficulty);
      blockchain.chain = storage.storedBlockchain.chain;
    } else {
      print('You need to provide a path to the saved blockchain.');
      exit(1);
    }
  } else {
    print('${arguments['variant']} is not valid. Please select a valid variant of genesis, network, local');
    exit(1);
  }
  
  var restService = RestService(blockchain, memPool, network, port: port);

  restService.run();
}