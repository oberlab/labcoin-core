import 'dart:io';

import 'package:crypton/crypton.dart';
import 'package:labcoin/labcoin.dart';

class Wallet {
  ECPrivateKey _privateKey;

  ECPublicKey get publicKey => _privateKey.publicKey;
  ECPrivateKey get privateKey => _privateKey;

  Wallet(String privateKey) {
    this._privateKey = ECPrivateKey.fromString(privateKey);
  }

  Wallet.fromRandom() {
    ECKeypair keypair = ECKeypair.fromRandom();
    this._privateKey = keypair.privateKey;
  }

  Wallet.fromPem(String privateKeyFilePath) {
    File privateKeyFile = File(privateKeyFilePath);

    if (!privateKeyFile.existsSync())
      throw ('\"$privateKeyFilePath\" does not exist or is not a valid path');

    this._privateKey =
        ECPrivateKey.fromString(decodePEM(privateKeyFile.readAsStringSync()));
  }

  void saveToFile(String folderPath) {
    Directory directory = Directory(folderPath);
    if (!directory.existsSync()) directory.createSync(recursive: true);

    File privateKeyFile = File('${directory.path}/private_key');
    File publicKeyFile = File('${directory.path}/public_key.pub');
    if (!privateKeyFile.existsSync()) privateKeyFile.createSync();
    if (!publicKeyFile.existsSync()) publicKeyFile.createSync();

    privateKeyFile.writeAsString(encodePrivateKeyToPem(this.privateKey));
    publicKeyFile.writeAsString(encodePublicKeyToPem(this.publicKey));
  }
}
