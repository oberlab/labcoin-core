import 'package:labcoin/labcoin.dart';
import 'package:labcoin/src/networking/network.dart';
import 'package:labcoin/src/networking/rest_service.dart';

class MemPool {
  final int _maxAgeMilliseconds;
  final Network _network;
  final List<BlockDataType> _unconfirmedTransactions = [];

  MemPool(this._maxAgeMilliseconds, this._network);

  /// Delete old Transaction
  void clean() {
    var cleanedUnconfirmedTransactions = <BlockDataType>[];
    for (var unconfirmedTransaction in _unconfirmedTransactions) {
      var now = DateTime.now().millisecondsSinceEpoch;
      if (unconfirmedTransaction.timestamp + _maxAgeMilliseconds > now) {
        cleanedUnconfirmedTransactions.add(unconfirmedTransaction);
      }
    }
  }

  /// Get a transaction based on its hash
  BlockDataType get(String hash) {
    for (var trx in _unconfirmedTransactions) {
      if (trx.toHash() == hash) {
        return trx;
      }
    }
    return null;
  }

  /// Check if the Mempool contains a specific transaction
  bool contains(String hash) => get(hash) != null;

  /// Add Transaction to MemPool if the Transaction is valid and not yet added
  bool add(BlockDataType trx) {
    if (trx.isValid && !contains(trx.toHash())) {
      _unconfirmedTransactions.add(trx);

      /// Propagate transaction in the Network
      _network.broadcast(RestUrl.TRANSACTION, trx.toMap());

      return true;
    } else {
      return false;
    }
  }

  /// Get the amount of unconfirmed Transactions
  int get length => _unconfirmedTransactions.length;

  List<BlockDataType> get unconfirmedTransactions => _unconfirmedTransactions;
}
