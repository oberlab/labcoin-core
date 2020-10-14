import 'dart:io';

import 'package:args/args.dart';
import 'package:labcoin/labcoin.dart';
import 'package:labcoin/src/utils/whitelist.dart';
import 'package:yaml/yaml.dart';

class Config {
  Wallet _creatorWallet;
  StorageManager _storageManager;

  BlockchainVariants _variant = BlockchainVariants.local;
  int _port = 3000;
  int _memPoolAge = 1000;
  Whitelist _whitelist = Whitelist.empty();
  String _hostname;
  bool _https = false;

  final Network _network = Network();

  BlockchainVariants get variant => _variant;

  Wallet get creatorWallet => _creatorWallet;

  Network get network => _network;

  StorageManager get storageManager => _storageManager;

  Whitelist get whitelist => _whitelist;

  String get hostname => _hostname;

  int get port => _port;

  int get memPoolAge => _memPoolAge;

  bool get isPersistent => storageManager != null;

  bool get hasWallet => creatorWallet != null;

  bool get hasHttps => _https;

  bool get canSubscribe => network.requestNodes.isNotEmpty && hostname != null;

  Config.fromArgResults(ArgResults argResults) {
    _variant = BlockchainVariants.values.firstWhere(
        (e) => e.toString() == 'BlockchainVariants.${argResults['variant']}');

    if (isNumeric(argResults['mempool-age'])) {
      _memPoolAge = int.parse(argResults['mempool-age']);
    }

    if (isNumeric(argResults['port'])) {
      _port = int.parse(argResults['port']);
    }

    if (argResults['storage'] != null) {
      _storageManager = StorageManager(argResults['storage']);
    }

    if (argResults['network'] != null) {
      var nodes = argResults['network'].toString().split(',');
      for (var node in nodes) {
        network.registerRequestNode(node);
      }
    }

    if (argResults['private-key'] != null) {
      _creatorWallet = Wallet(argResults['private-key']);
    }
  }

  Config.fromFile(File configFile) {
    var configDoc = loadYaml(configFile.readAsStringSync());

    _variant = BlockchainVariants.values.firstWhere(
        (e) => e.toString() == 'BlockchainVariants.${configDoc['variant']}');

    if (configDoc['mempool-age'] != null) {
      _memPoolAge = configDoc['mempool-age'];
    }

    if (configDoc['storage'] != null) {
      _storageManager = StorageManager(configDoc['storage']);
    }

    if (configDoc['network'] != null) {
      if (configDoc['network']['port'] != null) {
        _port = configDoc['network']['port'];
      }
      if (configDoc['network']['hostname'] != null) {
        _hostname = configDoc['network']['hostname'];
      }
      if (configDoc['network']['https'] != null) {
        _https = configDoc['network']['https'];
      }
      if (configDoc['network']['nodes'] != null) {
        var nodes = configDoc['network']['nodes'];
        for (var node in nodes) {
          network.registerRequestNode(node);
        }
      }
    }

    if (configDoc['whitelist'] != null) {
      var whitelist = configDoc['whitelist'].cast<String>();
      _whitelist = Whitelist(whitelist);
    }

    if (configDoc['private-key'] != null) {
      _creatorWallet = Wallet(configDoc['private-key']);
    }
  }
}
