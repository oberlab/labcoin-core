import 'package:labcoin/labcoin.dart';

void main() {
  var storageManager = StorageManager('./storage');
  var stakeManager = StakeManager.getValidator(storageManager.BlockchainBlocks);
  print(stakeManager);
}
