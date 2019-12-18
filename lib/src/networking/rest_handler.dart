import 'dart:convert';
import 'dart:io';

import 'package:crypton/crypton.dart';
import 'package:labcoin/labcoin.dart';
import 'package:webservant/webservant.dart';

/// GET  '/blockchain/full'         => get full Blockchain as Array
/// GET  '/wallet?walletId=walletid'=> get current funds of walletId
/// POST '/transaction'             => receive broadcasted Transactions
/// PUT  '/transaction'             => create new Transactions
/// POST '/block'                   => receive broadcasted Blocks

const String FULL_BLOCKCHAIN = '/blockchain/:count';
const String WALLET = '/wallet';
const String TRANSACTION = '/transaction';

class RestHandler {
  final StorageManager storageManager;
  final int port;
  final InternetAddress host = InternetAddress.anyIPv4;

  List _blockListToMap(List<Block> blcList) {
    List<Map> result = [];
    for (Block blc in blcList) {
      result.add(blc.toMap());
    }
    return result;
  }

  RestHandler(this.storageManager, this.port);

  Future run() async {
    Webserver webserver = Webserver(hostname: host, port: port, fCORS: true);
    void defaultResponse(Response res) {
      res.write('You are connected to the Labcoin Chain');
      res.send();
    }

    // Fuck CORS
    webserver.options(FULL_BLOCKCHAIN, defaultResponse);
    webserver.options(WALLET, defaultResponse);
    webserver.options(TRANSACTION, defaultResponse);

    // Handle Gets
    webserver.get(FULL_BLOCKCHAIN, (Response response) {
      List<Block> blockList = storageManager.BlockchainBlocks;
      response.write(jsonEncode(this._blockListToMap(blockList)));
      response.send();
    });

    webserver.get(WALLET, (Response response) {
      String walletAddress = response.queryParameters['walletId'];
      response.write(jsonEncode(
          {'funds': getFundsOfAddress(storageManager, walletAddress)}));
      response.send();
    });

    // Handle Posts
    webserver.post(TRANSACTION, (Response response) async {
      String content = await response.requestData;
      Map rawMap = jsonDecode(content);
      Transaction trx = Transaction.fromMap(rawMap);
      if (trx.isValid) storageManager.storePendingTransaction(trx);
      response.write('You are connected to the gitcoin chain!');
      response.send();
    });

    webserver.put(TRANSACTION, (Response response) async {
      String content = await response.requestData;
      Map rawMap = jsonDecode(content);
      ECPrivateKey privateKey = ECPrivateKey.fromString(rawMap['secretKey']);
      String senderAddress = privateKey.publicKey.toString();
      if (!(getFundsOfAddress(storageManager, senderAddress) >=
          rawMap['amount'])) {
        response.originalRequest.response.statusCode = 401;
        response.write('You can\'t spend more than you have!');
        response.send();
        return;
      }
      Transaction trx =
          Transaction(senderAddress, rawMap['toAddress'], rawMap['amount']);
      trx.signTransaction(privateKey);
      storageManager.storePendingTransaction(trx);
      response.write('You are connected to the gitcoin chain!');
      response.send();
    });

    webserver.run();
  }
}
