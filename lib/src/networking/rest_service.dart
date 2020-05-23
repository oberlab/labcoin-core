import 'dart:convert';
import 'dart:io';

import 'package:crypton/crypton.dart';
import 'package:labcoin/labcoin.dart';
import 'package:labcoin/src/networking/network.dart';
import 'package:webservant/webservant.dart';

class RestUrl {
  static final NODE = '/node';

  static final BLOCKCHAIN = '/blockchain';
  static final FULL_BLOCKCHAIN = '/blockchain/:count';
  static final WALLET = '/wallet/:address';
  // static final TRANSACTION_GET_HASH = '/transaction/:hash';

  static final MEMPOOL_TRANSACTIONS = '/mempool/transactions';
  static final TRANSACTION = '/transaction';
  static final BLOCK = '/block';
  static final BLOCK_GET = '/block/:identifier';
}

class RestService {
  final Blockchain blockchain;
  final MemPool memPool;
  final int port;
  final Network network;
  final InternetAddress host = InternetAddress.anyIPv4;

  RestService(this.blockchain, this.memPool, this.network, {this.port = 3000});

  void run() {
    var webServer = Webserver(hostname: host, port: port, fCORS: true);

    webServer.post(RestUrl.TRANSACTION, handleAddToMemPool);
    webServer.get(RestUrl.MEMPOOL_TRANSACTIONS, handleGetMemPoolTransactions);
    webServer.post(RestUrl.NODE, handleRegisterNode);

    webServer.post(RestUrl.BLOCK, handleAddBlock);
    webServer.get(RestUrl.BLOCK_GET, handleGetBlock);

    webServer.get(RestUrl.WALLET, handleGetWallet);

    webServer.get(RestUrl.BLOCKCHAIN, handleGetBlockchainInfo);
    webServer.get(RestUrl.FULL_BLOCKCHAIN, handleGetFullBlockchain);

    webServer.run();
  }

  /// Required Header
  /// - walletAddress
  /// - walletSig (remoteAddress:remotePort:walletAddress)
  void handleRegisterNode(Response response) async {
    var header = response.originalRequest.headers;
    if (header.value('walletAddress') != null &&
        header.value('walletSig') != null &&
        response.originalRequest.connectionInfo != null) {
      var walletAddress = header.value('walletAddress');
      var remoteAddress = response.originalRequest.connectionInfo.remoteAddress;
      var remotePort = response.originalRequest.connectionInfo.remotePort;

      var publicKey = ECPublicKey.fromString(walletAddress);
      var sigString = '$remoteAddress:$remotePort:${walletAddress}';
      var hasValidSig =
          publicKey.verifySignature(sigString, header.value('walletSig'));

      if (hasValidSig) {
        network.registerReceiveNode(walletAddress, '$remoteAddress:$remotePort');
        response.write('Node registerd successfully.');
      }
    }

    response.send();
  }

  void handleGetMemPoolTransactions(Response response) {
    var memPoolTrx = <Map<String, dynamic>>[];
    for (var trx in memPool.unconfirmedTransactions) {
      memPoolTrx.add(trx.toMap());
    }
    response.write(memPoolTrx);
    response.send();
  }

  void handleAddToMemPool(Response response) async {
    var content = await response.requestData;
    Map rawMap = jsonDecode(content);
    var trx = Transaction.fromMap(rawMap);
    if (!memPool.contains(trx.toHash())) {
      if (memPool.add(trx)) {
        response.write(
            'Your transaction has been added to the MemPool. Awaiting to be mined.');
      } else {
        response.write(
            'Your transaction is invalid. Please try it again with a valid transcation.');
      }
    }
    response.send();
  }

  void handleAddBlock(Response response) async {
    var content = await response.requestData;
    Map rawMap = jsonDecode(content);
    var block = Block.fromMap(rawMap);
    blockchain.addBlock(block);
    response.send();
  }

  void handleGetBlock(Response response) async {
    var identifier = response.urlParams['identifier'];
    Block block;
    if (isNumeric(identifier)) {
      block = blockchain.getBlockByHeight(int.parse(identifier));
    } else {
      block = blockchain.getBlockByHash(identifier);
    }
    response.write(block.toMap());
    response.send();
  }

  void handleGetWallet(Response response) async {
    var address = response.urlParams['address'];
    var funds = getFundsOfAddress(blockchain, memPool, address);
    var transactions = getTransactionsOfAddress(blockchain, address)
        .map((var trx) => trx.toMap()).toList();
    var memPoolTransactions = getMemPoolTransactionsOfAddress(memPool, address)
        .map((var trx) => trx.toMap()).toList();
    response.write(jsonEncode({
      'address': address,
      'funds': funds,
      'transactions': transactions,
      'memPoolTransactions': memPoolTransactions
    }));
    response.send();
  }

  void handleGetFullBlockchain(Response response) {
    var count = response.urlParams['count'];
    if (count.toLowerCase() == 'full') {
      response.write(jsonEncode(blockchain.toList()));
    } else if (count.startsWith('-')) {
      // Negative count means from last block counting
      if (isNumeric(count) && int.parse(count) >= (blockchain.length * -1)) {
        var length = int.parse(count) * -1;
        response.write(jsonEncode(blockchain.toList().reversed
            .toList()
            .sublist(0, length)
            .reversed
            .toList()));
      } else {
        response.statusCode = 400;
        response.write({'message': 'Please specify the count as integer'});
      }
    } else {
      if (isNumeric(count) && int.parse(count) <= blockchain.length) {
        var length = int.parse(count);
        response.write(jsonEncode(blockchain.toList().sublist(0, length)));
      } else {
        response.statusCode = 400;
        response.write(
            jsonEncode({'message': 'Please specify the count as integer'})
        );
      }
    }
    response.send();
  }

  void handleGetBlockchainInfo(Response response) {
    var firstBlock = blockchain.chain.first;
    var lastBlock = blockchain.last;

    response.write(jsonEncode({
      'firstBlock': firstBlock.toMap(),
      'lastBlock': lastBlock.toMap(),
      'proofOfWorkChar': blockchain.proofOfWorkChar,
      'difficulty': blockchain.difficulty
    }));
  }
}
