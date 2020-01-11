import 'package:labcoin/labcoin.dart';

bool findInBlockList(
    List<Block> blocklist, String query_name, String query_value) {
  for (var blc in blocklist) {
    Map blc_map = blc.toMap();
    List<Map> transactions = blc_map['data'];
    for (var transaction in transactions) {
      if (transaction[query_name] == query_value) return true;
    }
  }
  return false;
}

int getFundsOfAddress(StorageManager storageManager, String address) {
  var blockList = storageManager.BlockchainBlocks;
  var pendingTrx = storageManager.pendingTransactions.toList();
  var balance = 0;
  var transactions = getTransactionsOfAddress(blockList, pendingTrx, address);
  for (var trx in transactions) {
    if (trx.fromAddress == address) {
      balance -= trx.amount;
    } else if (trx.toAddress == address) {
      balance += trx.amount;
    }
  }
  return balance;
}

int getFundsOfAddressInChain(List<Block> blockList, String address) {
  var balance = 0;
  var transactions = getTransactionsOfAddress(blockList, [], address);
  for (var trx in transactions) {
    if (trx.fromAddress == address) {
      balance -= trx.amount;
    } else if (trx.toAddress == address) {
      balance += trx.amount;
    }
  }
  return balance;
}

List<Transaction> getTransactionsOfAddress(
    List<Block> blockList, List<Map> pendingTrx, String address) {
  var results = <Transaction>[];

  for (var blc in blockList) {
    for (var trx in blc.data.toList()) {
      if (trx['fromAddress'] == address || trx['toAddress'] == address) {
        results.add(Transaction.fromMap(trx));
      }
    }
  }
  for (var trx in pendingTrx) {
    if (trx['fromAddress'] == address || trx['toAddress'] == address) {
      results.add(Transaction.fromMap(trx));
    }
  }

  return results;
}
