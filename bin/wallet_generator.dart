import 'dart:io';

import 'package:labcoin/labcoin.dart';

void main() {
  if (!File('./wallet/private_key').existsSync()) {
    var wallet = Wallet.fromRandom();
    wallet.saveToFile('./wallet');
    print('Do not send the private_key file to anyone!');
  } else {
    print(
        'A Wallet already exists. Do not send the private_key file to anyone!');
  }
}
