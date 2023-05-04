import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // TODO: Add Login
  final _loginSnackBar = const SnackBar(
    content: Text("TODO: Add Login"),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            Text(
              "Haven",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 80,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              "Business Login",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const CustomTextField(
              keyboardType: TextInputType.emailAddress,
              hintText: 'Email',
            ),
            const CustomTextField(
              keyboardType: TextInputType.visiblePassword,
              hintText: 'Password',
            ),
            const Spacer(
              flex: 2,
            ),
            Card(
              elevation: 5.0,
              color: Theme.of(context).primaryColor,
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text(
                  "Login with Email",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(_loginSnackBar);
                },
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 5.0,
              child: ListTile(
                leading: Image.asset(
                  'images/g_logo.png',
                  width: 22,
                  height: 22,
                ),
                title: const Text("Login with Google"),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(_loginSnackBar);
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
