import 'package:labcoin/labcoin.dart';

class StakeManager {
  static String ADDRESS = '00000000000000000000000000000000000000000000';
  static String getValidator(List<Block> blockList) {
    Map<String, int> stakeHolders = {};
    List<Transaction> trxList =
        getTransactionsOfAddress(blockList, [], ADDRESS);
    for (Transaction trx in trxList) {
      if (trx.toAddress == ADDRESS) {
        if (stakeHolders[trx.fromAddress] == null)
          stakeHolders[trx.fromAddress] = 0;
        stakeHolders[trx.fromAddress] += trx.amount;
      } else if (trx.fromAddress == ADDRESS) {
        if (stakeHolders[trx.toAddress] == null)
          stakeHolders[trx.toAddress] = 0;
        stakeHolders[trx.toAddress] -= trx.amount;
      }
    }

    Map<String, dynamic> stake = {'name': '', 'amount': 0};
    stakeHolders.forEach((String stakeHolder, int amount) {
      if (stake['amount'] < amount)
        stake = {'name': stakeHolder, 'amount': amount};
    });
    return stake['name'];
  }
}
