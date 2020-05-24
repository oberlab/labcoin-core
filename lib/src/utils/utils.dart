import 'package:labcoin/labcoin.dart';

bool containsKeys(Map<String, dynamic> map, List<String> keys) {
  for (var key in keys) {
    if (!map.containsKey(key)) {
      return false;
    }
  }
  return true;
}

List<Map<String, dynamic>> castProperly(List unresolved) {
  var resolved = <Map<String, dynamic>>[];
  for (var entry in unresolved) {
    resolved.add(entry as Map<String, dynamic>);
  }
  return resolved;
}

bool isNumeric(String s) {
  if(s == null) {
    return false;
  }
  try {
    double.parse(s);
    return true;
  } catch (e) {
    return false;
  }
}

BlockDataType getBlockDataTypeFromMap(Map<String, dynamic> map) {
  if (map['type'] == Transaction.TYPE) {
    return Transaction.fromMap(map);
  } else if (map['type'] == Generic.TYPE) {
    return Generic.fromMap(map);
  }
  return null;
}

enum BlockchainVariants {
  network,
  genesis,
  local
}
