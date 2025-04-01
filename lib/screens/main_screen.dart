import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'db_management_screen.dart';
import 'create_user_screen.dart';
import '../database/database_helper.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<String, dynamic>? loggedInUser;

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    final user = await DatabaseHelper.instance.getLoggedInUser();
    setState(() {
      loggedInUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela Principal'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Tela Principal'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // No método que navega para a tela de login (no MainScreen)
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Login'),
              onTap: () async {
                Navigator.pop(context); // Fecha o drawer
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );

                if (result == true) {
                  // Atualiza o estado se o login foi bem-sucedido
                  final user = await DatabaseHelper.instance.getLoggedInUser();
                  setState(() {
                    loggedInUser = user;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.manage_accounts),
              title: Text('Gestão de BD'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DbManagementScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Criar Utilizador'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateUserScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Status de Login:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              loggedInUser != null
                  ? 'Logado como: ${loggedInUser!['name']}'
                  : 'Não logado',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: loggedInUser != null ? Colors.green : Colors.red,
              ),
            ),
            if (loggedInUser != null) ...[
              SizedBox(height: 30),
              ElevatedButton(
                child: Text('Logout'),
                onPressed: () async {
                  await DatabaseHelper.instance.logoutAllUsers();
                  await _checkLoggedInUser();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}