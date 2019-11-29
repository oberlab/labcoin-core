import 'package:labcoin/labcoin.dart';

bool findInBlockList(
    List<Block> blocklist, String query_name, String query_value) {
  for (Block blc in blocklist) {
    Map blc_map = blc.toMap();
    List<Map> transactions = blc_map['data'];
    for (Map transaction in transactions) {
      if (transaction[query_name] == query_value) return true;
    }
  }
  return false;
}

int getFundsOfAddress(StorageManager storageManager, String address) {
  List<Block> blockList = storageManager.BlockchainBlocks;
  List<Map> pendingTrx = storageManager.pendingTransactions.toList();
  int balance = 0;
  List<Transaction> transactions =
      getTransactionsOfAddress(blockList, pendingTrx, address);
  for (Transaction trx in transactions) {
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
  List<Transaction> results = [];

  for (Block blc in blockList) {
    for (Map trx in blc.data.toList()) {
      if (trx['fromAddress'] == address || trx['toAddress'] == address) {
        results.add(Transaction.fromMap(trx));
      }
    }
  }
  for (Map trx in pendingTrx) {
    if (trx['fromAddress'] == address || trx['toAddress'] == address) {
      results.add(Transaction.fromMap(trx));
    }
  }

  return results;
}
