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
const String WALLET_TRANSACTIONS = '/wallet/transactions';
const String TRANSACTION = '/transaction';
const String BLOCK = '/block';

class RestHandler {
  final StorageManager storageManager;
  final int port;
  final InternetAddress host = InternetAddress.anyIPv4;

  List _blockListToMap(List<Block> blcList) {
    var result = [];
    for (var blc in blcList) {
      result.add(blc.toMap());
    }
    return result;
  }

  RestHandler(this.storageManager, this.port);

  Future run() async {
    var webserver = Webserver(hostname: host, port: port, fCORS: true);
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
      var count = response.urlParams['count'];
      var blockList = storageManager.BlockchainBlocks;
      if (count.toLowerCase() == 'full') {
        response.write(jsonEncode(_blockListToMap(blockList)));
      } else if (count.startsWith('-')) {
        // Negative count means from last block counting
        try {
          var length = int.parse(count) * -1;
          response.write(jsonEncode(_blockListToMap(blockList.reversed
              .toList()
              .sublist(0, length)
              .reversed
              .toList())));
        } catch (exception) {
          response.statusCode = 400;
          response.write(
              jsonEncode({'message': 'Please specify the count as integer'}));
        }
      } else {
        try {
          var length = int.parse(count);
          response
              .write(jsonEncode(_blockListToMap(blockList.sublist(0, length))));
        } catch (exception) {
          response.statusCode = 400;
          response.write(
              jsonEncode({'message': 'Please specify the count as integer'}));
        }
      }
      response.send();
    });

    webserver.get(WALLET, (Response response) {
      var walletAddress = response.queryParameters['walletId'];
      response.write(jsonEncode(
          {'funds': getFundsOfAddress(storageManager, walletAddress)}));
      response.send();
    });

    webserver.get(WALLET_TRANSACTIONS, (Response response) {
      var walletAddress = response.queryParameters['walletId'];
      var trxList = <Map<String, dynamic>>[];
      getTransactionsOfAddress(
              storageManager.BlockchainBlocks, [], walletAddress)
          .forEach((var trx) {
        trxList.add(trx.toMap());
      });
      response.write(jsonEncode({'transactions': trxList}));
      response.send();
    });

    // Handle Posts
    webserver.post(TRANSACTION, (Response response) async {
      var content = await response.requestData;
      Map rawMap = jsonDecode(content);
      var trx = Transaction.fromMap(rawMap);
      if (trx.isValid) storageManager.storePendingTransaction(trx);
      response.write('You are connected to the labcoin chain!');
      response.send();
    });

    webserver.post(BLOCK, (Response response) async {
      var content = await response.requestData;
      Map rawMap = jsonDecode(content);
      var blc = Block.fromMap(rawMap);
      if (blc.isValid) storageManager.storePendingBlock(blc);
      response.write('You are connected to the labcoin chain!');
      response.send();
    });

    webserver.put(TRANSACTION, (Response response) async {
      var content = await response.requestData;
      Map rawMap = jsonDecode(content);
      var privateKey = ECPrivateKey.fromString(rawMap['secretKey']);
      var senderAddress = privateKey.publicKey.toString();
      if (!(getFundsOfAddress(storageManager, senderAddress) >=
          rawMap['amount'])) {
        response.originalRequest.response.statusCode = 401;
        response.write('You can\'t spend more than you have!');
        response.send();
        return;
      }
      var trx =
          Transaction(senderAddress, rawMap['toAddress'], rawMap['amount']);
      trx.sign(privateKey);
      storageManager.storePendingTransaction(trx);
      response.write('You are connected to the labcoin chain!');
      response.send();
    });

    webserver.run();
  }
}
