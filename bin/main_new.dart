
import 'package:labcoin/labcoin.dart';
import 'package:labcoin/src/networking/network.dart';
import 'package:labcoin/src/networking/rest_service.dart';

void main() {
  var blockchain = Blockchain.newGenesis(Wallet.fromRandom());
  var network = Network();
  var memPool = MemPool(10000, network);
  var restService = RestService(blockchain, memPool, network);

  restService.run();
}