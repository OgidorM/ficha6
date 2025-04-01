import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class DbManagementScreen extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<void> _showConfirmationDialog(BuildContext context, String title, String content, Function() onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestão de Banco de Dados'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Apagar Tabela de Utilizadores'),
              onPressed: () {
                _showConfirmationDialog(
                  context,
                  'Confirmar Exclusão',
                  'Tem certeza que deseja apagar a tabela de utilizadores?',
                      () async {
                    await dbHelper.dropTable();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tabela apagada com sucesso!')),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Criar Tabela de Utilizadores'),
              onPressed: () async {
                await dbHelper.createTable();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tabela criada com sucesso!')),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Listar Utilizadores'),
              onPressed: () async {
                final users = await dbHelper.queryAllUsers();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Utilizadores Registrados'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: users.map((user) =>
                            ListTile(
                              title: Text(user['name']),
                              subtitle: Text(user['email']),
                            )
                        ).toList(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text('Fechar'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}