import 'package:labcoin/labcoin.dart';
import 'package:labcoin/src/utils/merkle_tree.dart';

class BlockData {
  final List<BlockDataType> _entries = <BlockDataType>[];

  BlockData();

  BlockData.fromList(List<Map<String, dynamic>> list) {
    for (var entry in list) {
      var entryElement = getBlockDataTypeFromMap(entry);
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

  int get generatedTransactions {
    var results = <BlockDataType>[];
    for (var trx in _entries) {
      if (trx.type == Transaction.TYPE &&
          trx.fromAddress == GENERATED_ADDRESS) {
        results.add(trx);
      }
    }
    return results.length;
  }

  bool isValidData(Block block) {
    if (generatedTransactions > 1) return false;
    for (var trx in _entries) {
      if (trx.type == Transaction.TYPE) {
        if (!isValidTransaction(block, trx)) return false;
      } else {
        if (!trx.isValid) return false;
      }
    }
    return true;
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
