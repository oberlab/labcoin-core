import 'package:labcoin/labcoin.dart';

main() {
  Wallet wallet = Wallet.fromRandom();
  wallet.saveToFile('./wallet');
  print('Do not send the private_key file to anyone!');
}
