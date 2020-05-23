import 'package:args/args.dart';

ArgParser getArgParser() {
  var parser = ArgParser();

  parser.addFlag('help', abbr: 'h', defaultsTo: false, help: 'Show this help message.');
  parser.addOption('variant', defaultsTo: 'local', help: 'Select a blockchain variant. local, network or genesis');
  parser.addOption('private-key', defaultsTo: null, help: 'Set a private key to sign the genensis block.');
  parser.addOption('network', abbr: 'n', defaultsTo: null);
  parser.addOption('storage', abbr: 's', defaultsTo: null, help: 'Sets the storage path to persist the blockchain.');
  parser.addOption('port', abbr: 'p', defaultsTo: '3000', help: 'Define the port where the webserver should listen to.');
  parser.addOption('mempool-age', defaultsTo: '10000', help: 'Define the maximal age of a Transction in the Mempool before it gets deleted in miliseconds.');

  return parser;
}
