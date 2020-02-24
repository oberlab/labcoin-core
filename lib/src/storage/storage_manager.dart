import 'dart:convert';
import 'dart:io';

import 'package:labcoin/labcoin.dart';

/// HowTo Read Blockchain from File
/// StorageManager storageManager = StorageManager('./storage/');
/// storageManager.BlockchainBlocks

class StorageManager {
  final String folderPath;
  Directory _pendingTransactions;
  Directory _pendingBlocks;
  Directory blockchain;
  List<File> selectedPendingTransactions = [];
  List<File> selectedPendingBlocks = [];

  StorageManager(this.folderPath) {
    var directory = Directory(folderPath);
    if (!directory.existsSync()) directory.createSync(recursive: true);

    _pendingTransactions = Directory('${directory.path}/pendingTransactions');
    _pendingBlocks = Directory('${directory.path}/pendingBlocks');
    blockchain = Directory('${directory.path}/blockchain');

    if (!_pendingTransactions.existsSync()) _pendingTransactions.createSync();
    if (!_pendingBlocks.existsSync()) _pendingBlocks.createSync();
    if (!blockchain.existsSync()) blockchain.createSync();
  }

  /// Initialize a fresh new storage
  void init() {
    var directory = Directory(folderPath);
    directory.deleteSync(recursive: true);
    directory.createSync();

    _pendingTransactions = Directory('${directory.path}/pendingTransactions');
    _pendingBlocks = Directory('${directory.path}/pendingBlocks');
    blockchain = Directory('${directory.path}/blockchain');

    _pendingTransactions.createSync();
    _pendingBlocks.createSync();
    blockchain.createSync();
  }

  void deletePendingTransactions() {
    for (var file in selectedPendingTransactions) {
      file.delete();
    }
  }

  void deletePendingTransaction(List<Transaction> listToDelete) {
    for (var trx in listToDelete) {
      var filename = '${trx.toHash()}.trx';
      var file = File('${_pendingTransactions.path}/$filename');
      if (file.existsSync()) file.delete();
    }
  }

  BlockData get pendingTransactions {
    var results = BlockData();
    var files = _pendingTransactions.listSync();
    for (var file in files) {
      var ptrx = File(file.path);
      selectedPendingTransactions.add(ptrx);
      results.add(Transaction.fromMap(
          jsonDecode(ptrx.readAsStringSync()) as Map<String, dynamic>));
    }
    return results;
  }

  void storePendingTransaction(Transaction trx) {
    var filename = '${trx.toHash()}.trx';
    var file = File('${_pendingTransactions.path}/$filename');
    if (!file.existsSync()) file.createSync();
    file.writeAsStringSync(jsonEncode(trx.toMap()));
  }

  void deletePendingBlocks() {
    for (var file in selectedPendingBlocks) {
      file.delete();
    }
  }

  void deletePendingBlock(List<Transaction> listToDelete) {
    for (var trx in listToDelete) {
      var filename = '${trx.toHash()}.trx';
      var file = File('${_pendingBlocks.path}/$filename');
      if (file.existsSync()) file.delete();
    }
  }

  List<Block> get pendingBlocks {
    var results = <Block>[];
    var files = _pendingBlocks.listSync();
    for (var file in files) {
      var ptrx = File(file.path);
      selectedPendingBlocks.add(ptrx);
      results.add(Block.fromMap(jsonDecode(ptrx.readAsStringSync())));
    }
    return results;
  }

  void storePendingBlock(Block blc) {
    var filename = '${blc.depth}.blc';
    var file = File('${_pendingBlocks.path}/$filename');
    if (!file.existsSync()) file.createSync();
    file.writeAsStringSync(jsonEncode(blc.toMap()));
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
      var filename = '${blc.depth}.blc';
      var file = File('${blockchain.path}/$filename');
      if (!file.existsSync()) {
        file.createSync();
        file.writeAsStringSync(jsonEncode(blc.toMap()));
      }
    }
  }
}
