import 'dart:convert';
import 'dart:io';

import 'package:labcoin/labcoin.dart';

/// HowTo Read Blockchain from File
/// StorageManager storageManager = StorageManager('./storage/');
/// storageManager.BlockchainBlocks

class StorageManager {
  final String folderPath;
  Directory _pendingTransactions;
  Directory blockchain;
  List<File> selectedPendingTransactions = [];
  List<File> selectedPendingBlocks = [];

  StorageManager(this.folderPath) {
    var directory = Directory(folderPath);
    if (!directory.existsSync()) directory.createSync(recursive: true);

    blockchain = Directory('${directory.path}/blockchain');

    if (!blockchain.existsSync()) blockchain.createSync();
  }

  /// Initialize a fresh new storage
  void init() {
    var directory = Directory(folderPath);
    directory.deleteSync(recursive: true);
    directory.createSync();

    blockchain = Directory('${directory.path}/blockchain');

    _pendingTransactions.createSync();
    blockchain.createSync();
  }

  List<Block> get BlockchainBlocks {
    var results = <Block>[];
    var files = blockchain.listSync();
    files.sort((a, b) {
      var aName = a.path.split('\\').last.replaceAll('.blc', '');
      var bName = b.path.split('\\').last.replaceAll('.blc', '');
      if (int.parse(aName) > int.parse(bName)) {
        return 1;
      } else if (int.parse(aName) < int.parse(bName)) return -1;
      return 0;
    });
    for (var file in files) {
      var pblc = File(file.path);
      var unresolved =
          jsonDecode(pblc.readAsStringSync()) as Map<String, dynamic>;
      results.add(Block.fromMap(unresolved));
    }
    return results;
  }

  Blockchain get storedBlockchain {
    var results = <Map<String, dynamic>>[];
    var files = blockchain.listSync();
    files.sort((a, b) {
      var aName = a.path.split('\\').last.replaceAll('.blc', '');
      var bName = b.path.split('\\').last.replaceAll('.blc', '');
      if (int.parse(aName) > int.parse(bName)) {
        return 1;
      } else if (int.parse(aName) < int.parse(bName)) return -1;
      return 0;
    });
    for (var file in files) {
      var pblc = File(file.path);
      results.add(jsonDecode(pblc.readAsStringSync()) as Map<String, dynamic>);
    }
    var blc = Blockchain.fromList(results);
    blc.storageManager = this;
    return blc;
  }

  void storeBlockchain(Blockchain blc_chn) {
    for (var blc in blc_chn.chain) {
      var filename = '${blc.height}.blc';
      var file = File('${blockchain.path}/$filename');
      if (!file.existsSync()) {
        file.createSync();
        file.writeAsStringSync(jsonEncode(blc.toMap()));
      }
    }
  }
}
