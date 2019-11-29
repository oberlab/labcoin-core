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
      this.data = TransactionList.fromList(unresolvedBlock['data']);
      this.creator = unresolvedBlock['creator'];
      this.signature = unresolvedBlock['signature'];
      this.timestamp = unresolvedBlock['timestamp'];
      this.depth = unresolvedBlock['depth'];
      this.previousHash = unresolvedBlock['previousHash'];
      this.nuance = unresolvedBlock['nuance'];
    } else {
      throw ('Some Parameter are missing!');
    }
  }

  bool get isValid {
    ECPublicKey publicKey = ECPublicKey.fromString(this.creator);
    bool hasValidSignature =
        publicKey.verifySignature(this.toHash(), this.signature);
    return this.data.isValid && hasValidSignature;
  }

  void signBlock(PrivateKey privateKey) {
    signature = privateKey.createSignature(this.toHash());
  }

  String toHash() {
    crypto.Digest digest = crypto.sha256.convert(utf8.encode(this.toString()));
    return digest.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'data': this.data.toList(),
      'creator': this.creator,
      'signature': this.signature,
      'timestamp': this.timestamp,
      'nuance': this.nuance,
      'depth': this.depth,
      'previousHash': this.previousHash
    };
  }

  String toString() {
    return this.depth.toString() +
        this.nuance.toString() +
        this.creator +
        this.data.toString() +
        this.previousHash +
        this.timestamp.toString();
  }
}
