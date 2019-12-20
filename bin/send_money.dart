import 'dart:io';

import 'package:labcoin/labcoin.dart';

void main() {
  var storageManager = StorageManager('./storage');
  var wallet = Wallet.fromPem('./wallet/private_key');
  var myAddress = wallet.publicKey.toString();
  var yourCurrentFund = getFundsOfAddress(storageManager, myAddress);
  var spending = 0;

  print('Hello fellow Human');
  print('Your balance: ${yourCurrentFund}G');
  print('---------------------------------');
  print('How much money do you want to spend? ');
  var input = stdin.readLineSync();
  spending = int.parse(input);
  while (yourCurrentFund < spending) {
    print('You can\'t spend more than you have!');
    input = stdin.readLineSync();
    spending = int.parse(input);
  }
  print('Where do you want to send your money? ');
  var toAddress = stdin.readLineSync();

  var trx = Transaction(myAddress, toAddress, spending);
  trx.signTransaction(wallet.privateKey);

  storageManager.storePendingTransaction(trx);
  print('You successfly transferd Money');
}
