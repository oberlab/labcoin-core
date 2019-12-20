import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:crypton/crypton.dart';
import 'package:labcoin/labcoin.dart';

const String GENERATED_ADDRESS = '11111111111111111111111111111111111111111111';

class Transaction {
  String _fromAddress;
  String _toAddress;
  int _amount;
  int _timestamp = DateTime.now().millisecondsSinceEpoch;
  String _signature;

  String get toAddress => _toAddress;
  String get fromAddress => _fromAddress;
  int get amount => _amount;
  int get timestamp => _timestamp;

  /// Returns if the Transaction is valid
  bool get isValid {
    if (_fromAddress == StakeManager.ADDRESS) {
      return true;
    } // We assume it is a Stake repayment

    if (_fromAddress == GENERATED_ADDRESS) {
      return true;
    } // We assume it is a generated token

    if (_signature == StakeManager.ADDRESS || _signature.isEmpty) {
      throw ('No signature in this transaction');
    }

    var publicKey = ECPublicKey.fromString(_fromAddress);
    var hasValidSignature = publicKey.verifySignature(toHash(), _signature);

    return _fromAddress != _toAddress &&
        !_amount.isNegative &&
        hasValidSignature;
  }

  Transaction(this._fromAddress, this._toAddress, this._amount);
  Transaction.fromMap(Map unresolvedTransaction) {
    if (unresolvedTransaction.containsKey('fromAddress') &&
        unresolvedTransaction.containsKey('toAddress') &&
        unresolvedTransaction.containsKey('amount') &&
        unresolvedTransaction.containsKey('signature') &&
        unresolvedTransaction.containsKey('timestamp')) {
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
  }

  void signTransaction(PrivateKey privateKey) {
    _signature = privateKey.createSignature(toHash());
  }

  String toHash() {
    return sha256.convert(utf8.encode(toString())).toString();
  }

  @override
  String toString() {
    return _fromAddress.toString() +
        _toAddress.toString() +
        _amount.toString() +
        _timestamp.toString();
  }

  Map toMap() {
    return {
      'fromAddress': _fromAddress,
      'toAddress': _toAddress,
      'amount': _amount,
      'signature': _signature,
      'timestamp': _timestamp
    };
  }
}
