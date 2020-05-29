import 'dart:math';

import 'package:crypton/crypton.dart';
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
      if (trx['type'] == Transaction.TYPE &&
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
    if (trx['type'] == Transaction.TYPE &&
        (trx['fromAddress'] == address || trx['toAddress'] == address)) {
      results.add(Transaction.fromMap(trx));
    }
  }

  return results;
}

int getBlockReward(int height) {
  return (100000 * pow(0.5, (height / 100000).floor())).round();
}

bool isValidTransaction(Block block, Transaction trx) {
  if (trx.fromAddress == GENERATED_ADDRESS &&
      trx.amount <= getBlockReward(block.height)) {
    var publicKey = ECPublicKey.fromString(block.creator);
    return publicKey.verifySignature(trx.toHash(), trx.signature);
  } else {
    return trx.isValid;
  }
}
