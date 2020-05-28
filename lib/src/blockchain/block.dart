import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:crypton/crypton.dart';
import 'package:labcoin/labcoin.dart';

class Block {
  int height = 0;
  int nonce = 0;
  BlockData data;
  String previousHash = '0x0';
  String creator = '';
  String signature = '';
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  /// Create a Block
  Block(this.data, this.creator);

  /// Create a new Block from a Map
  Block.fromMap(Map<String, dynamic> unresolvedBlock) {
    if (containsKeys(unresolvedBlock, [
      'data',
      'creator',
      'signature',
      'timestamp',
      'previousHash',
      'height',
      'nonce'
    ])) {
      var unresolved = castProperly(unresolvedBlock['data']);
      data = BlockData.fromList(unresolved);
      creator = unresolvedBlock['creator'];
      signature = unresolvedBlock['signature'];
      timestamp = unresolvedBlock['timestamp'];
      height = unresolvedBlock['height'];
      nonce = unresolvedBlock['nonce'];
      previousHash = unresolvedBlock['previousHash'];
    } else {
      throw ('Some Parameter are missing!');
    }
  }

  /// Returns if the Block is valid
  bool get isValid {
    var publicKey = ECPublicKey.fromString(creator);
    var hasValidSignature = publicKey.verifySignature(toHash(), signature);
    return data.isValidData(this) && hasValidSignature;
  }

  /// Sign the Block
  void signBlock(PrivateKey privateKey) {
    signature = privateKey.createSignature(toHash());
  }

  /// Calculate hash
  String toHash() => crypto.sha256.convert(utf8.encode(toString())).toString();

  /// Return the Block as a Map
  Map<String, dynamic> toMap() {
    return {
      'data': data.toList(),
      'creator': creator,
      'signature': signature,
      'timestamp': timestamp,
      'height': height,
      'nonce': nonce,
      'previousHash': previousHash
    };
  }

  /// Return the Block as Valid JSON String
  String toJsonString() => jsonEncode(toMap());

  /// Return the Block as "height:creator:dataHash:nonce:previousHash:timestamp"
  @override
  String toString() {
    return '$height:$creator:${data.toHash()}:$nonce:$previousHash:$timestamp';
  }
}
