import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart';
import 'package:labcoin/labcoin.dart';
import 'package:labcoin/src/blockchain/types/generic.dart';
import 'package:labcoin/src/networking/network.dart';

class Blockchain {
  Wallet creatorWallet;
  Broadcaster broadcaster;
  Network network;
  StorageManager storageManager;
  List<Block> chain = [];
  int difficulty = 0;
  final String proofOfWorkChar = '0';

  /// Return the proof of work requirement
  String get workRequirement {
    var requirement = StringBuffer();
    for (var i = 0; i < difficulty; i++) {
      requirement.write(proofOfWorkChar);
    }
    return requirement.toString();
  }

  /// if the Blockchain should be persistent
  bool get isPersistent => storageManager != null;

  /// Returns the Hash of the last Block of the Blockchain
  String get _previousHash => chain.last.toHash();

  /// Returns the number of objects in this list.
  /// The valid indices for a list are `0` through `length - 1`.
  int get length => chain.length;

  /// Returns if the Blockchain is valid
  bool get isValid {
    var last_block = chain.first;
    for (var i = 1; i < chain.length; i++) {
      var block = chain[i];
      if (block.previousHash != last_block.toHash() ||
          !block.isValid ||
          !block.toHash().startsWith(workRequirement)) {
        return false;
      }
      last_block = block;
    }
    return true;
  }

  Blockchain(this.creatorWallet,
      {this.storageManager, this.broadcaster, this.difficulty = 3});

  /// Create a new Blockchain with a Genesis Block
  Blockchain.newGenesis(this.creatorWallet,
      {this.storageManager, this.broadcaster, this.difficulty = 3}) {
    var message = Generic('Genesis', creatorWallet.publicKey.toString());
    message.sign(creatorWallet.privateKey);

    var blockData = BlockData();
    blockData.add(message);

    var block = Block(blockData, creatorWallet.publicKey.toString());
    block.signBlock(creatorWallet.privateKey);

    chain.add(block);
    save();
  }

  Blockchain.fromList(List<Map<String, dynamic>> unresolvedBlockchain) {
    unresolvedBlockchain.forEach((block) {
      chain.add(Block.fromMap(block));
    });
    chain.sort((Block a, Block b) => a.height.compareTo(b.height));
  }

  /// Initial a Blockchain from a network
  static Future<Blockchain> fromNetwork(List<String> networkList,
      Wallet createWallet, StorageManager storageManager) async {
    var currentBlockchain = <Map<String, dynamic>>[];
    for (var node in networkList) {
      var url = node + '/blockchain/full';
      var response = await get(url);
      var receivedChain = jsonDecode(response.body) as List;
      if (receivedChain.length > currentBlockchain.length) {
        currentBlockchain = <Map<String, dynamic>>[];
        receivedChain.forEach((var e) {
          currentBlockchain.add(e as Map<String, dynamic>);
        });
      }
    }
    var blockchain = Blockchain.fromList(currentBlockchain);
    blockchain.creatorWallet = createWallet;
    blockchain.storageManager = storageManager;
    blockchain.broadcaster = Broadcaster(networkList);
    storageManager.storeBlockchain(blockchain);
    return blockchain;
  }

  Future updateFromNetwork() async {
    for (var node in broadcaster.nodes) {
      var url = node + '/blockchain/-5';
      var response = await get(url);
      if (response.statusCode == 200) {
        var receivedChain = castProperly(jsonDecode(response.body));
        var blc = Blockchain.fromList(receivedChain);
        if (blc.length > length && blc.isValid) {
          chain = blc.chain;
        }
      }
    }
  }

  void save() {
    if (isPersistent) {
      storageManager.storeBlockchain(this);
    }
  }

  /// Add a Block to the Blockchain and inform other Nodes about the Update
  /// to reach Consensus
  @deprecated
  void _addBlock(Block block) {
    chain.add(block);
    save();
    if (broadcaster != null) {
      broadcaster.broadcast('/block', block.toMap());
    }
  }

  /// Add a valid Block to the Blockchain
  void addBlock(Block block) {
    if (block.isValid &&
        block.toHash().startsWith(workRequirement) &&
        chain.last.toHash() == block.previousHash) {
      chain.add(block);
      network.broadcast('/block', block.toMap());
    }
  }

  /// Create a Block and add it to the ever growing Blockchain
  @deprecated
  void createBlock() {
    var creator = creatorWallet.publicKey.toString();
    if (!(StakeManager.getValidator(chain, validator: creator) == creator)) {
      throw ('You are not the next Creator');
    }
    var pendingTransactions = storageManager.pendingTransactions;
    if (!pendingTransactions.isValid) {
      storageManager
          .deletePendingTransaction(pendingTransactions.invalidEntries);
      return createBlock();
    }
    var block = Block(pendingTransactions, creator);
    block.previousHash = _previousHash;
    block.height = length;
    block.signBlock(creatorWallet.privateKey);
    _addBlock(block);
    storageManager.deletePendingTransactions();
  }

  /// Resolve Conflicts occurred in any other process
  bool resolveConflicts(List<Blockchain> chains) {
    var newChain = this;
    var isThisChain = true;
    for (var blockchain in chains) {
      if (blockchain.isValid && (blockchain.length > newChain.length)) {
        newChain = blockchain;
        isThisChain = false;
      }
    }
    return isThisChain;
  }

  /// Get a Block based on the Blockheight
  Block getBlockByHeight(int height) {
    if (height < length) {
      height -= 1;
      return chain[height];
    }
    return null;
  }

  /// Get a Block based on the Blockhash
  Block getBlockByHash(String hash) {
    for (var block in chain) {
      if (block.toHash() == hash) {
        return block;
      }
    }
    return null;
  }

  /// Return the Blockchain as a List
  List<Map<String, dynamic>> toList() {
    var result = <Map<String, dynamic>>[];
    chain.forEach((block) {
      result.add(block.toMap());
    });
    return result;
  }

  /// Return the Blockchain as Valid JSON String
  @override
  String toString() {
    return jsonEncode(toList());
  }
}
