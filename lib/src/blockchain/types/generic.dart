import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:crypton/crypton.dart';
import 'package:labcoin/labcoin.dart';

class Generic extends BlockDataType {
  String _message;
  String _fromAddress;
  String _signature;
  int _timestamp = DateTime.now().millisecondsSinceEpoch;

  Generic(this._message, this._fromAddress);

  Generic.empty();

  Generic.fromMap(Map<String, dynamic> unresolvedMap) {
    fromMap(unresolvedMap);
  }

  @override
  Generic fromMap(Map<String, dynamic> unresolvedMap) {
    if (containsKeys(
        unresolvedMap, ['message', 'fromAddress', 'signature', 'timestamp'])) {
      _fromAddress = unresolvedMap['fromAddress'];
      _message = unresolvedMap['message'];
      _signature = unresolvedMap['signature'];
      _timestamp = unresolvedMap['timestamp'];
    } else {
      throw ('Some Parameters are missing!');
    }
    return this;
  }

  static String get TYPE => 'GENERIC';

  @override
  int get timestamp => _timestamp;

  @override
  bool get isValid {
    var publicKey = ECPublicKey.fromString(_fromAddress);
    return publicKey.verifySignature(toHash(), _signature);
  }

  @override
  void sign(PrivateKey privateKey) {
    _signature = privateKey.createSignature(toHash());
  }

  @override
  String toHash() => sha256.convert(utf8.encode(toString())).toString();

  @override
  String toString() {
    return '$_message:$_fromAddress:${_timestamp.toString()}';
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'type': TYPE,
        'message': _message,
        'fromAddress': _fromAddress,
        'signature': _signature,
        'timestamp': _timestamp
      };
}
