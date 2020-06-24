class Whitelist {
  final List<String> whitelist;

  Whitelist(this.whitelist);

  Whitelist.empty() : whitelist = [];

  bool isOnWhitelist(String address) =>
      whitelist.isEmpty || whitelist.contains(address);
}
