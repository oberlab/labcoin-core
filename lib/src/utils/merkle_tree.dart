import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;

class MerkleTree {
  static List<String> _concatHashes(List<String> hashes) {
    var results = <String>[];
    for (var i = 0; i < hashes.length; i++) {
      if (hashes.length.isOdd && i == 0) {
        var digest = crypto.sha256.convert(utf8.encode(hashes[i]));
        results.add(digest.toString());
      } else {
        var digest =
            crypto.sha256.convert(utf8.encode(hashes[i] + hashes[i + 1]));
        results.add(digest.toString());
        i++;
      }
    }
    return results;
  }

  static String getTreeRoot(List<String> leaves) {
    var hashList = leaves;
    while (hashList.length > 1) {
      hashList = _concatHashes(hashList);
    }
    return hashList[0];
  }
}
