import 'package:flutter/material.dart';
import 'package:flutter_application_1/LoginForms/Signup.dart';
import 'package:hive/hive.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  runApp(PetPalApp());

}

class PetPalApp extends StatelessWidget {
  
  
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetPal',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SignInScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInScreen({super.key});
void loginUser(BuildContext context) async {
    var userBox = await Hive.openBox('usersBox');

    String email = emailController.text;
    String password = passwordController.text;

   if(userBox.containsKey(email)) {
      var userData = userBox.get(email);
      if(userData['password'] == password) {
        print("Login successful");
        // Navigate to main app screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        print("Incorrect password");
      }
    } else {
      print("User not found");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PetPal", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, color: Colors.blue[900]),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(
              "Sign In",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),

            // Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => loginUser(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.blue,
                ),
                child: Text("Sign In", style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 20),

            // Register Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don’t have an account? "),
                GestureDetector(
                  onTap: (
                  ) {
                    Navigator.push(context, MaterialPageRoute(builder:(context) => SignUpScreen())  );
            
                    // Navigate to Register
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Bottom Navigation
      
    );
  }
}
