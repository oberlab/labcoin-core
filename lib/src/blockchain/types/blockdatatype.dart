import 'package:crypton/crypton.dart';

abstract class BlockDataType {
  BlockDataType();

  BlockDataType.empty();

  BlockDataType.fromMap(Map<String, dynamic> unresolvedMap);

  /// Create a Entry from a Map
  void fromMap(Map<String, dynamic> unresolvedMap) => null;

  /// Get the Datatype of Entry
  static String get TYPE => null;

  /// Get the type for Entry
  String get type => null;

  /// Get the timestamp for Entry
  int get timestamp => null;

  /// Get the signature for Entry
  String get signature => null;

  /// Get the fromAddress for Entry
  String get fromAddress => null;

  /// Returns if the Entry is valid
  bool get isValid => null;

  /// Sign the Entry
  void sign(PrivateKey privateKey) => null;

  /// Generate a Hash for the Entry
  String toHash() => null;

  /// Return as Map
  Map<String, dynamic> toMap() => null;
}
