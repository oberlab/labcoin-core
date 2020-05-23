import 'package:labcoin/labcoin.dart';
import 'package:labcoin/src/blockchain/types/generic.dart';
import 'package:labcoin/src/utils/merkle_tree.dart';

BlockDataType getBlockDataType(String type, Map<String, dynamic> map) {
  if (type == Transaction.TYPE) {
    return Transaction.fromMap(map);
  } else if (type == Generic.TYPE) {
    return Generic.fromMap(map);
  }
  return null;
}

class BlockData {
  final List<BlockDataType> _entries = <BlockDataType>[];

  BlockData();

  BlockData.fromList(List<Map<String, dynamic>> list) {
    for (var entry in list) {
      var entryElement = getBlockDataType(entry['type'], entry);
      if (entryElement != null) _entries.add(entryElement);
    }
  }

  int get length => _entries.length;

  bool get isValid => invalidEntries.isEmpty;

  List<BlockDataType> get invalidEntries {
    var results = <BlockDataType>[];
    for (var trx in _entries) {
      if (!trx.isValid) results.add(trx);
    }
    return results;
  }

  void add(BlockDataType entry) => _entries.add(entry);

  String toHash() {
    var hashes = <String>[];
    _entries.sort((var a, var b) => a.timestamp.compareTo(b.timestamp));
    for (var entry in _entries) {
      hashes.add(entry.toHash());
    }
    return MerkleTree.getTreeRoot(hashes);
  }

  List<Map<String, dynamic>> toList() {
    var result = <Map<String, dynamic>>[];
    _entries.sort((var a, var b) => a.timestamp.compareTo(b.timestamp));
    for (var entry in _entries) {
      result.add(entry.toMap());
    }
    return result;
  }
}
