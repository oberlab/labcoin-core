import 'dart:io';

import 'package:crypton/crypton.dart';
import 'package:labcoin/labcoin.dart';

class Wallet {
  ECPrivateKey _privateKey;

  ECPublicKey get publicKey => _privateKey.publicKey;
  ECPrivateKey get privateKey => _privateKey;

  Wallet(String privateKey) {
    _privateKey = ECPrivateKey.fromString(privateKey);
  }

  Wallet.fromRandom() {
    var keypair = ECKeypair.fromRandom();
    _privateKey = keypair.privateKey;
  }

  Wallet.fromPem(String privateKeyFilePath) {
    var privateKeyFile = File(privateKeyFilePath);

    if (!privateKeyFile.existsSync()) {
      throw ('\"$privateKeyFilePath\" does not exist or is not a valid path');
    }

    _privateKey =
        ECPrivateKey.fromString(decodePEM(privateKeyFile.readAsStringSync()));
  }

  void saveToFile(String folderPath) {
    var directory = Directory(folderPath);
    if (!directory.existsSync()) directory.createSync(recursive: true);

    var privateKeyFile = File('${directory.path}/private_key');
    var publicKeyFile = File('${directory.path}/public_key.pub');
    if (!privateKeyFile.existsSync()) privateKeyFile.createSync();
    if (!publicKeyFile.existsSync()) publicKeyFile.createSync();

    privateKeyFile.writeAsString(encodePrivateKeyToPem(privateKey));
    publicKeyFile.writeAsString(encodePublicKeyToPem(publicKey));
  }
}
