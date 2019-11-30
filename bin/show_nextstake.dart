import 'package:labcoin/labcoin.dart';

void main() {
  StorageManager storageManager = StorageManager('./storage');
  String stakeManager = StakeManager.getValidator(storageManager.BlockchainBlocks);
  print(stakeManager);
}
