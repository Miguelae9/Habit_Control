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
            "",
            style: TextStyle(color: Color.fromARGB(255, 255, 230, 2)),
          ),
          accountEmail: Text(
            "HABIT CONTROL",
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),

        Ink(
          color: const Color.fromARGB(255, 68, 93, 122),
          child: ListTile(
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
        ),

        const SizedBox(height: 3),

        Ink(
          color: const Color.fromARGB(255, 68, 93, 122),
          child: ListTile(
            title: const Text("Data Logging"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/data_logging');
            },
          ),
        ),

        const SizedBox(height: 3),

        Ink(
          color: const Color.fromARGB(255, 68, 93, 122),
          child: ListTile(
            title: const Text("Analytics"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/analytics');
            },
          ),
        ),

        const SizedBox(height: 3),

        Ink(
          color: const Color.fromARGB(255, 68, 93, 122),
          child: ListTile(
            title: const Text("About"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/credits');
            },
          ),
        ),
      ],
    );
  }
}
