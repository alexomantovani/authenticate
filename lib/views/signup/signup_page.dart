import 'package:authenticate/views/login/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool loading = false;
  bool obscure = true;

  clearFields() {
    nameController.text = '';
    emailController.text = '';
    passwordController.text = '';
    setState(() {});
  }

  Future<User?> signUp(String email, String password) async {
    setState(() => loading = true);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        showSnackBar(title: 'Account successfully created');
        pop();
      }
      setState(() => loading = false);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);
      debugPrint('code ${e.code}');
      if (e.code == 'invalid-email') {
        showSnackBar(title: '${e.message}');
      } else if (e.code == 'weak-password') {
        showSnackBar(title: '${e.message}');
      } else {
        showSnackBar(title: 'It was not possible to complete your request');
      }
      return null;
    }
  }

  pop() {
    Navigator.pop(context);
  }

  showSnackBar({required String title}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(milliseconds: 2500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1B),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(height: 32),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SvgPicture.asset('lib/assets/logo.svg'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Create account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        ),
                        child: const Text(
                          ' Login',
                          style: TextStyle(
                            color: Color(0xFF4D81E7),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            prefixIcon: SvgPicture.asset(
                              'lib/assets/user.svg',
                              fit: BoxFit.scaleDown,
                            ),
                            hintText: 'Full Name',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const Divider(),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            prefixIcon: SvgPicture.asset(
                              'lib/assets/email.svg',
                              fit: BoxFit.scaleDown,
                            ),
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const Divider(),
                        TextField(
                          obscureText: obscure,
                          controller: passwordController,
                          decoration: InputDecoration(
                            prefixIcon: SvgPicture.asset(
                              'lib/assets/password.svg',
                              fit: BoxFit.scaleDown,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => obscure = !obscure),
                              icon: obscure
                                  ? const Icon(
                                      Icons.visibility_off_outlined,
                                      color: Color(0xFFACB5BB),
                                    )
                                  : const Icon(
                                      Icons.visibility_outlined,
                                      color: Color(0xFFACB5BB),
                                    ),
                            ),
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      if (emailController.text.isNotEmpty &&
                          passwordController.text.isNotEmpty &&
                          nameController.text.isNotEmpty) {
                        await signUp(
                            emailController.text, passwordController.text);
                      } else {
                        showSnackBar(title: 'Please fill all form fields');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D61E7),
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: !loading
                        ? const Text(
                            'Register',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          )
                        : const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
