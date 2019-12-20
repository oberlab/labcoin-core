import 'package:args/args.dart';

ArgParser getArgParser() {
  var parser = ArgParser();
  parser.addFlag('init', defaultsTo: false);
  parser.addOption('private-key', defaultsTo: null);
  parser.addOption('network', abbr: 'n', defaultsTo: null);
  parser.addOption('storage', abbr: 's', defaultsTo: './storage');
  parser.addOption('port', abbr: 'p', defaultsTo: '3000');

  return parser;
}
