import 'package:test/test.dart';

import 'package:labcoin/labcoin.dart';

void main() {
  group('A group of Util Tests', () {

    test('Test isIsinteger true', () {
      expect(isNumeric('100'), true);
    });

    test('Test isIsinteger false', () {
      expect(isNumeric('Test'), false);
    });

    test('Test isIsinteger null', () {
      expect(isNumeric(null), false);
    });

  });

  group('A group of Blockchain Tests', () {
    Blockchain blockchain;

    setUp(() {
      blockchain = Blockchain(Wallet.fromRandom());
    });

    test('Calculate the correct proof of work requirement', () {
      var requirement = blockchain.workRequirement;
      expect(requirement, '000');
    });

  });
}