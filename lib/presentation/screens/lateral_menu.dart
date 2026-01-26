import 'package:flutter/material.dart';

class LateralMenu extends StatelessWidget {
  const LateralMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const UserAccountsDrawerHeader(
          accountName: Text(
            "Miguel Ángel Pérez García",
            style: TextStyle(color: Color.fromARGB(255, 255, 230, 2)),
          ),
          accountEmail: Text(
            "Relación de Ejercicios Tema 1",
            style: TextStyle(color: Color.fromARGB(255, 255, 230, 2)),
          ),
        ),

        Ink(
          color: const Color.fromARGB(255, 247, 114, 180),
          child: ListTile(
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ),
      ],
    );
  }
}