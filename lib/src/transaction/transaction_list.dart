import 'package:labcoin/labcoin.dart';

class TransactionList {
  final List<Transaction> _trx = [];

  TransactionList();

  TransactionList.fromList(List unresolvedTrxList) {
    for (Map trx in unresolvedTrxList) {
      _trx.add(Transaction.fromMap(trx));
    }
  }

  int get length => _trx.length;

  void add(Transaction trx) => _trx.add(trx);

  List<Transaction> get invalidTransactions {
    var results = [];
    for (var trx in _trx) {
      if (!trx.isValid) results.add(trx);
    }
    return results;
  }

  bool get isValid {
    return invalidTransactions.isEmpty;
  }

  List<Map> toList() {
    var result = [];
    for (var trx in _trx) {
      result.add(trx.toMap());
    }
    return result;
  }

  @override
  String toString() {
    var result = '';
    for (var trx in _trx) {
      result += trx.toString();
    }
    return result;
  }
}
