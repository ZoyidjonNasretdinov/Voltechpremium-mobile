class DemoUser {
  final String phone;
  final String password;
  final String name;
  final int age;
  final String region;
  final int balance;

  DemoUser({
    required this.phone,
    required this.password,
    required this.name,
    this.age = 30,
    this.region = 'Toshkent sh.',
    this.balance = 5200,
  });
}

class DemoDB {
  // Boshlang'ich demo foydalanuvchilar
  static List<DemoUser> users = [
    DemoUser(
      phone: '+998901234567',
      password: 'password123',
      name: 'Aziz Qosimov',
      balance: 5200,
    ),
  ];
}
