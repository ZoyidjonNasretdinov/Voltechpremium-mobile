// Production build - no embedded demo credentials.
class DemoUser {
  final String phone;
  final String name;
  final int balance;

  DemoUser({
    required this.phone,
    required this.name,
    this.balance = 0,
  });
}

class DemoDB {
  static List<DemoUser> users = const [];
}
