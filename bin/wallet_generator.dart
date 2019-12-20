import 'package:labcoin/labcoin.dart';

void main() {
  var wallet = Wallet.fromRandom();
  wallet.saveToFile('./wallet');
  print('Do not send the private_key file to anyone!');
}
