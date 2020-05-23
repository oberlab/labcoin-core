import 'package:labcoin/labcoin.dart';

int getFundsOfAddress(Blockchain blockchain, MemPool memPool, String address) {
  var balance = 0;
  var transactions = getTransactionsOfAddress(blockchain, address);
  var memPoolTransactions = getMemPoolTransactionsOfAddress(memPool, address);
  for (var trx in transactions) {
    if (trx.fromAddress == address) {
      balance -= trx.amount;
    } else if (trx.toAddress == address) {
      balance += trx.amount;
    }
  }
  for (var trx in memPoolTransactions) {
    if (trx.fromAddress == address) {
      balance -= trx.amount;
    }
  }
  return balance;
}

List<Transaction> getTransactionsOfAddress(
    Blockchain blockchain, String address) {
  var results = <Transaction>[];

  for (var blc in blockchain.chain) {
    for (var trx in blc.data.toList()) {
      if (trx['type'] == 'TRANSACTION' &&
          (trx['fromAddress'] == address || trx['toAddress'] == address)) {
        results.add(Transaction.fromMap(trx));
      }
    }
  }

  return results;
}

List<Transaction> getMemPoolTransactionsOfAddress(
    MemPool memPool, String address) {
  var results = <Transaction>[];

  for (var uTrx in memPool.unconfirmedTransactions) {
    var trx = uTrx.toMap();
    if (trx['type'] == 'TRANSACTION' &&
        (trx['fromAddress'] == address || trx['toAddress'] == address)) {
      results.add(Transaction.fromMap(trx));
    }
  }

  return results;
}
