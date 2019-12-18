import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:http/http.dart';
import 'package:labcoin/labcoin.dart';

class Blockchain {
  int difficulty = 3;
  int maxNonce = pow(2, 32);
  Wallet creatorWallet;
  Broadcaster broadcaster;
  StorageManager storageManager;
  List<Block> chain = [];

  /// Returns the Hash of the last Block of the Blockchain
  String get _previousHash => this.chain.last.toHash();

  /// Returns the number of objects in this list.
  ///
  /// The valid indices for a list are `0` through `length - 1`.
  int get length => chain.length;

  /// Returns if the Blockchain is valid
  bool get isValid {
    Block last_block = this.chain.first;
    for (int i = 1; i < this.chain.length; i++) {
      Block block = this.chain[i];
      String currentValidator =
          StakeManager.getValidator(chain.sublist(0, i + 1));
      if (block.previousHash != last_block.toHash() ||
          !block.isValid ||
          !(currentValidator.length == 0 ||
              currentValidator == block.creator)) {
        return false;
      }
      last_block = block;
    }
    return true;
  }

  Blockchain(this.creatorWallet, this.storageManager,
      {this.broadcaster = null}) {
    this.chain.add(Block(TransactionList(), ''));
  }

  Blockchain.fromList(List<Map> unresolvedQuery) {
    unresolvedQuery.forEach((block) {
      chain.add(Block.fromMap(block));
    });
    chain.sort((Block a, Block b) => a.depth.compareTo(b.depth));
  }

  /// Initial a Blockchain from a network
  static Future<Blockchain> fromNetwork(List<String> networkList,
      Wallet createWallet, StorageManager storageManager) async {
    List<Map> currentBlockchain = [];
    for (String node in networkList) {
      String url = node + '/blockchain/full';
      Response response = await get(url);
      var receivedChain = jsonDecode(response.body) as List;
      if (receivedChain.length > currentBlockchain.length) {
        currentBlockchain = [];
        receivedChain.forEach((var e) {
          currentBlockchain.add(e as Map);
        });
      }
    }
    Blockchain blockchain = Blockchain.fromList(currentBlockchain);
    blockchain.creatorWallet = createWallet;
    blockchain.storageManager = storageManager;
    blockchain.broadcaster = Broadcaster(networkList);
    storageManager.storeBlockchain(blockchain);
    return blockchain;
  }

  /// Add a Block to the Blockchain and inform other Nodes about the Update
  /// to reach Consensus
  void _addBlock(Block block) {
    chain.add(block);
    storageManager.storeBlockchain(this);
    if (this.broadcaster != null) {
      this.broadcaster.broadcast('/block', block.toMap());
    }
  }

  /// Add a Block to the Blockchain
  void addBlock(Block block) {
    if (block.isValid &&
        block.creator == StakeManager.getValidator(chain) &&
        chain.last.toHash() == block.previousHash) {
      chain.add(block);
    }
  }

  /// Create a Block and add it to the ever growing Blockchain
  void createBlock() {
    String creator = this.creatorWallet.publicKey.toString();
    if (!(StakeManager.getValidator(this.chain) == creator)) {
      throw ("You are not the next Creator");
    }
    TransactionList pendingTransactions = storageManager.pendingTransactions;
    if (!pendingTransactions.isValid) {
      storageManager
          .deletePendingTransaction(pendingTransactions.invalidTransactions);
      return createBlock();
    }
    Block block = Block(pendingTransactions, creator);
    block.previousHash = this._previousHash;
    block.depth = this.length;
    block.signBlock(this.creatorWallet.privateKey);
    this._addBlock(block);
    storageManager.deletePendingTransactions();
  }

  /// Resolve Conflicts occurred in any other process
  bool resolveConflicts(List<Blockchain> chains) {
    Blockchain newChain = this;
    bool isThisChain = true;
    for (Blockchain blockchain in chains) {
      if (blockchain.isValid && (blockchain.length > newChain.length)) {
        newChain = blockchain;
        isThisChain = false;
      }
    }
    return isThisChain;
  }

  /// Return the Blockchain as a List
  List<Map<String, dynamic>> toList() {
    List<Map<String, dynamic>> result = [];
    chain.forEach((block) {
      result.add(block.toMap());
    });
    return result;
  }

  /// Return the Blockchain as Valid JSON String
  @override
  String toString() {
    String result = '[';
    int index = 0;
    chain.forEach((block) {
      if (index + 1 == chain.length) {
        result += '${block.toString()}';
      } else {
        result += '${block.toString()},';
      }
      index++;
    });
    result += ']';
    return result;
  }
}
