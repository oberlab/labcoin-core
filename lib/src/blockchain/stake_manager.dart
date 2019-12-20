import 'package:labcoin/labcoin.dart';

class StakeManager {
  static String ADDRESS = '00000000000000000000000000000000000000000000';
  static String getValidator(List<Block> blockList) {
    var stakeHolders = {};
    var trxList = getTransactionsOfAddress(blockList, [], ADDRESS);
    for (var trx in trxList) {
      if (trx.toAddress == ADDRESS) {
        if (stakeHolders[trx.fromAddress] == null) {
          stakeHolders[trx.fromAddress] = 0;
        }
        stakeHolders[trx.fromAddress] += trx.amount;
      } else if (trx.fromAddress == ADDRESS) {
        if (stakeHolders[trx.toAddress] == null) {
          stakeHolders[trx.toAddress] = 0;
        }
        stakeHolders[trx.toAddress] -= trx.amount;
      }
    }
    var stake = {'name': '', 'amount': 0};
    stakeHolders.forEach((var stakeHolder, var amount) {
      if (stake['amount'] as int < amount) {
        stake = {'name': stakeHolder, 'amount': amount};
      }
    });
    return stake['name'];
  }
}
