import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:crypton/crypton.dart';
import 'package:labcoin/labcoin.dart';

class Block {
  int depth = 0;
  BlockData data;
  String previousHash = '0x0';
  String creator = '';
  String signature = '';
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  Block(this.data, this.creator);

  Block.fromMap(Map<String, dynamic> unresolvedBlock) {
    if (containsKeys(unresolvedBlock, [
      'data',
      'creator',
      'signature',
      'timestamp',
      'previousHash',
      'depth'
    ])) {
      var unresolved = castProperly(unresolvedBlock['data']);
      data = BlockData.fromList(unresolved);
      creator = unresolvedBlock['creator'];
      signature = unresolvedBlock['signature'];
      timestamp = unresolvedBlock['timestamp'];
      depth = unresolvedBlock['depth'];
      previousHash = unresolvedBlock['previousHash'];
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
      'depth': depth,
      'previousHash': previousHash
    };
  }

  @override
  String toString() {
    var stringBuffer = StringBuffer();
    stringBuffer.write(depth);
    stringBuffer.write(creator);
    stringBuffer.write(data.toHash());
    stringBuffer.write(previousHash);
    stringBuffer.write(timestamp);
    return stringBuffer.toString();
  }
}
