import 'package:args/args.dart';

ArgParser getArgParser() {
  ArgParser parser = ArgParser();
  parser.addFlag('quiet', abbr: 'q', defaultsTo: false);
  parser.addFlag('init', defaultsTo: false);
  parser.addOption('private-key', defaultsTo: null);
  parser.addOption('port', abbr: 'p', defaultsTo: '3000');

  return parser;
}
