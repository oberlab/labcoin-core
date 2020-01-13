import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:crypton/crypton.dart';
import 'package:labcoin/labcoin.dart';

class Block {
  int depth = 0;
  TransactionList data;
  String previousHash = '0x0';
  String creator = '';
  String signature = '';
  int nuance = 0;
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  Block(this.data, this.creator);

  Block.fromMap(Map unresolvedBlock) {
    if (unresolvedBlock.containsKey('data') &&
        unresolvedBlock.containsKey('creator') &&
        unresolvedBlock.containsKey('signature') &&
        unresolvedBlock.containsKey('timestamp') &&
        unresolvedBlock.containsKey('previousHash') &&
        unresolvedBlock.containsKey('depth') &&
        unresolvedBlock.containsKey('nuance')) {
      data = TransactionList.fromList(unresolvedBlock['data']);
      creator = unresolvedBlock['creator'];
      signature = unresolvedBlock['signature'];
      timestamp = unresolvedBlock['timestamp'];
      depth = unresolvedBlock['depth'];
      previousHash = unresolvedBlock['previousHash'];
      nuance = unresolvedBlock['nuance'];
    } else {
      throw ('Some Parameter are missing!');
    }
  }

  bool get isValid {
    var publicKey = ECPublicKey.fromString(creator);
    var hasValidSignature = publicKey.verifySignature(toHash(), signature);
    return data.isValid && hasValidSignature;
  }

  void signBlock(PrivateKey privateKey) {
    signature = privateKey.createSignature(toHash());
  }

  String toHash() {
    var digest = crypto.sha256.convert(utf8.encode(toString()));
    return digest.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data.toList(),
      'creator': creator,
      'signature': signature,
      'timestamp': timestamp,
      'nuance': nuance,
      'depth': depth,
      'previousHash': previousHash
    };
  }

  @override
  String toString() {
    return depth.toString() +
        nuance.toString() +
        creator +
        data.toHash() +
        previousHash +
        timestamp.toString();
  }
}
