import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:crypton/crypton.dart';
import 'package:labcoin/labcoin.dart';

const String GENERATED_ADDRESS = '11111111111111111111111111111111111111111111';

class Transaction extends BlockDataType {
  String _fromAddress;
  String _toAddress;
  int _amount;
  int _timestamp = DateTime.now().millisecondsSinceEpoch;
  String _signature;

  String get toAddress => _toAddress;
  int get amount => _amount;

  static String get TYPE => 'TRANSACTION';

  @override
  String get type => Transaction.TYPE;

  @override
  String get fromAddress => _fromAddress;

  @override
  String get signature => _signature;

  @override
  int get timestamp => _timestamp;

  /// Returns if the Transaction is valid
  @override
  bool get isValid {
    if (_signature.isEmpty) {
      throw ('No signature in this transaction');
    }

    var publicKey = ECPublicKey.fromString(_fromAddress);
    var hasValidSignature = publicKey.verifySignature(toHash(), _signature);

    return _fromAddress != _toAddress &&
        !_amount.isNegative &&
        hasValidSignature;
  }

  Transaction(this._fromAddress, this._toAddress, this._amount);

  Transaction.empty();

  Transaction.fromMap(Map<String, dynamic> unresolvedTransaction) {
    fromMap(unresolvedTransaction);
  }

  @override
  Transaction fromMap(Map<String, dynamic> unresolvedTransaction) {
    if (containsKeys(unresolvedTransaction,
        ['fromAddress', 'toAddress', 'amount', 'signature', 'timestamp'])) {
      _fromAddress = unresolvedTransaction['fromAddress'];
      if (_fromAddress == 'null') {
        _fromAddress = null;
      }
      _toAddress = unresolvedTransaction['toAddress'];
      if (_toAddress == 'null') {
        _toAddress = null;
      }
      _amount = unresolvedTransaction['amount'];
      _signature = unresolvedTransaction['signature'];
      _timestamp = unresolvedTransaction['timestamp'];
    } else {
      throw ('Some Parameters are missing!');
    }
    return this;
  }

  @override
  void sign(PrivateKey privateKey) {
    _signature = privateKey.createSignature(toHash());
  }

  @override
  String toHash() => sha256.convert(utf8.encode(toString())).toString();

  @override
  String toString() {
    return '$_fromAddress:$_toAddress:${_amount.toString()}:${_timestamp.toString()}';
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'type': TYPE,
        'fromAddress': _fromAddress,
        'toAddress': _toAddress,
        'amount': _amount,
        'signature': _signature,
        'timestamp': _timestamp
      };
}
