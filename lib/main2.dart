import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizza App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container
        ( color: Colors.cyan,
        child: Column(
        children: <Widget>[
          TextField(
            controller: userIdController,
            decoration: InputDecoration(labelText: 'User ID'),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Confirm Password'),
          ),
          ElevatedButton(
            child: Text('REGISTER'),
            onPressed: () => _register(context),
          ),
        ],
      ),)
    );
  }

  void _register(BuildContext context) async {
    String userId = userIdController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword || userId.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Passwords do not match or fields are empty');
      return;
    }

    var db = await DatabaseHelper.instance.database;
    var res = await db.insert('users', {
      'userId': userId,
      'password': password,
    });

    if (res > 0) {
      _showSnackBar(context, 'User registered successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      _showSnackBar(context, 'Registration failed');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container
        ( color: Colors.cyan,
        child:Column(
        children: <Widget>[
          Image.asset('assets/images/pizza.png'),
          TextField(
            controller: userIdController,
            decoration: InputDecoration(labelText: 'User ID'),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          ElevatedButton(
            child: Text('LOGIN'),
            onPressed: () => _login(context),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => RegistrationScreen()),
              );
            },
            child: Text('Register'),
          ),
        ],
      ),)
    );
  }

  void _login(BuildContext context) async {
    String userId = userIdController.text;
    String password = passwordController.text;

    var db = await DatabaseHelper.instance.database;
    var res = await db.query('users', where: 'userId = ? AND password = ?', whereArgs: [userId, password]);

    if (res.isNotEmpty) {
      _showSnackBar(context, 'Login successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userId: userId,)),
      );
    } else {
      _showSnackBar(context, 'Invalid user ID or password');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class HomeScreen extends StatelessWidget {
  final String userId;

  HomeScreen({required this.userId});

  final List<Pizza> pizzas = [
    Pizza(name: 'Margherita', image: 'assets/images/pizza.png'),
    Pizza(name: 'Pepperoni', image: 'assets/images/pizza.png'),
    Pizza(name: 'Veggie', image: 'assets/images/pizza.png'),
    // Add more pizzas as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text(userId)), // Displaying the User ID
          ),
        ],
      ),
      body: Container
        ( color: Colors.cyan,
        child:

        GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: pizzas.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PizzaDetailScreen(pizza: pizzas[index], userId: userId,)),
              );
            },
            child: GridTile(
              header: GridTileBar(
                backgroundColor: Colors.black45,
                title: Text(pizzas[index].name),
              ),
              child: Image.asset(pizzas[index].image, fit: BoxFit.cover),
              footer: GridTileBar(
                backgroundColor: Colors.black45,
                title: Text('Click for details'),
              ),
            ),
          );
        },
      ),)
    );
  }
}


class DatabaseHelper {
  static final _databaseName = "PizzaApp.db";
  static final _databaseVersion = 1;
  static final table = 'users';
  static final columnId = 'id';
  static final columnUserId = 'userId';
  static final columnPassword = 'password';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnUserId TEXT NOT NULL,
            $columnPassword TEXT NOT NULL
          )
          ''');
  }
}


class Pizza {
  final String name;
  final String image;

  Pizza({required this.name, required this.image});
}


List<Pizza> pizzas = [
  Pizza(name: 'Margherita', image: 'assets/pizza.png'),
  Pizza(name: 'Pepperoni', image: 'assets/pizza.png'),
  Pizza(name: 'Veggie', image: 'assets/pizza.png'),
  // Add more pizzas as needed
];

// PizzaDetailScreen
class PizzaDetailScreen extends StatefulWidget {
  final Pizza pizza;
  final String userId;

  PizzaDetailScreen({required this.pizza, required this.userId});

  @override
  _PizzaDetailScreenState createState() => _PizzaDetailScreenState();
}

class _PizzaDetailScreenState extends State<PizzaDetailScreen> {
  Map<String, int> quantities = {'Small': 0, 'Medium': 0, 'Large': 0};
  Map<String, int> toppings = {'Small': 0, 'Medium': 0, 'Large': 0};
  Map<String, double> basePrices = {'Small': 10.0, 'Medium': 20.0, 'Large': 30.0};
  Map<String, double> toppingPrices = {'Small': 2.0, 'Medium': 3.0, 'Large': 5.0};
  double totalPrice = 0.0;

  void _updateTotalPrice() {
    totalPrice = quantities.entries.fold(0.0, (previousValue, element) {
      String size = element.key;
      int quantity = element.value;
      int toppingCount = toppings[size]!;
      double basePrice = basePrices[size]! * quantity;
      double toppingPrice = toppingPrices[size]! * toppingCount * quantity;
      return previousValue + basePrice + toppingPrice;
    });
  }

  Widget _buildSizeAndToppingSelector(String size) {
    return Column(
      children: [
        Text(size, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (quantities[size]! > 0) {
                    quantities[size] = quantities[size]! - 1;
                    _updateTotalPrice();
                  }
                });
              },
            ),
            Text(quantities[size].toString()),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  quantities[size] = quantities[size]! + 1;
                  _updateTotalPrice();
                });
              },
            ),
            Text('${basePrices[size]} CAD'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (toppings[size]! > 0) {
                    toppings[size] = toppings[size]! - 1;
                    _updateTotalPrice();
                  }
                });
              },
            ),
            Text('${toppings[size]} Toppings'),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  toppings[size] = toppings[size]! + 1;
                  _updateTotalPrice();
                });
              },
            ),
            Text('+${toppingPrices[size]} CAD each'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pizza.name),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container
        ( color: Colors.cyan,
        child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.asset(widget.pizza.image, fit: BoxFit.cover), // Placeholder image for pizza
            Text(
              'Pizza is very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very good!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            _buildSizeAndToppingSelector('Small'),
            _buildSizeAndToppingSelector('Medium'),
            _buildSizeAndToppingSelector('Large'),
            Text('Total cost: \$${totalPrice.toStringAsFixed(2)} CAD'),
            ElevatedButton(
              onPressed: () {
                // Navigate to order confirmation screen with the total price and user ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderConfirmationScreen(
                      userId: widget.userId, // Pass the actual user ID
                      totalPrice: totalPrice,
                    ),
                  ),
                );
              },
              child: Text('ORDER'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF6200EE),
              ),
            ),
          ],
        ),
      ),)
    );
  }
}
// OrderConfirmationScreen
class OrderConfirmationScreen extends StatelessWidget {
  final String userId;
  final double totalPrice;

  OrderConfirmationScreen({required this.userId, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Confirmation'),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Container
        ( color: Colors.cyan,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Color(0xFF6200EE), // Or any other color that fits the design
            padding: EdgeInsets.all(16),
            child: Text(
              'user ID: $userId', // Display the user ID
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Your order has been processed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Please pay \$${totalPrice.toStringAsFixed(2)} for confirmation',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    child: Text('HOME'),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen(userId: userId)),
                            (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF6200EE),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),)
    );
  }
}
