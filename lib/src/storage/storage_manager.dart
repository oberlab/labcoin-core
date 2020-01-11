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

    _pendingTransactions = Directory('${directory.path}/pendingTransactions');
    blockchain = Directory('${directory.path}/blockchain');

    if (!_pendingTransactions.existsSync()) _pendingTransactions.createSync();
    if (!blockchain.existsSync()) blockchain.createSync();
  }

  /// Initialize a fresh new storage
  void init() {
    var directory = Directory(folderPath);
    directory.deleteSync(recursive: true);
    directory.createSync();

    _pendingTransactions = Directory('${directory.path}/pendingTransactions');
    blockchain = Directory('${directory.path}/blockchain');

    _pendingTransactions.createSync();
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

  TransactionList get pendingTransactions {
    var results = TransactionList();
    var files = _pendingTransactions.listSync();
    for (var file in files) {
      var ptrx = File(file.path);
      selectedPendingTransactions.add(ptrx);
      results.add(Transaction.fromMap(jsonDecode(ptrx.readAsStringSync())));
    }
    return results;
  }

  void storePendingTransaction(Transaction trx) {
    var filename = '${trx.toHash()}.trx';
    var file = File('${_pendingTransactions.path}/$filename');
    if (!file.existsSync()) file.createSync();
    file.writeAsStringSync(jsonEncode(trx.toMap()));
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
      results.add(Block.fromMap(jsonDecode(pblc.readAsStringSync())));
    }
    return results;
  }

  Blockchain get storedBlockchain {
    var results = <Map>[];
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
      results.add(jsonDecode(pblc.readAsStringSync()));
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
