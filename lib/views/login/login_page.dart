import 'package:authenticate/views/bloc/authentication_bloc.dart';
import 'package:authenticate/views/home/home_page.dart';
import 'package:authenticate/views/password/reset_password_page.dart';
import 'package:authenticate/views/signup/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool loading = false;
  bool obscure = true;
  Map<String, String?>? persistedUser;
  late UserCredential userCredential;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  pop() {
    Navigator.pop(context);
  }

  Future<dynamic> openDialog(
      {required String title,
      required String cancelButtonLabel,
      required String confirmButtonLabel,
      required VoidCallback confirmButtonHandler}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.symmetric(vertical: 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0D0D1B),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.fingerprint_outlined,
              color: Color(0xFF0D0D1B),
              size: 48,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D0D1B),
              foregroundColor: Colors.transparent,
              fixedSize: const Size.fromWidth(132),
            ),
            child: Text(
              cancelButtonLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: confirmButtonHandler,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D0D1B),
              foregroundColor: Colors.transparent,
              fixedSize: const Size.fromWidth(132),
            ),
            child: Text(
              confirmButtonLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _authenticate() async {
    bool? isLocalyAuthenticated;
    bool isBioChecked = false;
    if (await auth.isDeviceSupported()) {
      isBioChecked = await auth.canCheckBiometrics;
    }
    try {
      if (isBioChecked) {
        isLocalyAuthenticated = await auth.authenticate(
          localizedReason: 'Use your biometric to sign in',
          options: const AuthenticationOptions(biometricOnly: true),
        );
      }
    } catch (e) {
      isLocalyAuthenticated = false;
    }
    return isLocalyAuthenticated!;
  }

  Future<void> signInWithEmail(String email, String password) async {
    setState(() => loading = true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      validateUserAfterSignIn(userCredential);
      setState(() => loading = false);
    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);
      if (e.code == 'user-not-found') {
        showSnackBar(title: 'User not Found');
      } else if (e.code == 'wrong-password') {
        showSnackBar(title: 'Wrong Password');
      } else if (e.code == 'invalid-credential') {
        showSnackBar(title: 'Invalid Credentials');
      }
    }
  }

  validateUserAfterSignIn(UserCredential userCredential) async {
    if (userCredential.user != null) {
      if (persistedUser == null) {
        await openDialog(
          title: 'Enable Biometric Sign In',
          cancelButtonLabel: 'Cancel',
          confirmButtonLabel: 'Enable',
          confirmButtonHandler: () async =>
              await saveUser().whenComplete(() => pop()),
        ).whenComplete(() {
          goToHome();
        });
      } else {
        goToHome();
      }
    }
  }

  goToHome() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
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
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> saveUser() async {
    await storage.write(key: 'email', value: emailController.text);
    await storage.write(key: 'password', value: passwordController.text);
  }

  getUser() async {
    final String? email = await storage.read(key: 'email');
    final String? password = await storage.read(key: 'password');
    if (email != null && password != null) {
      setState(() {
        persistedUser = {
          'email': email,
          'password': password,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1B),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SvgPicture.asset('lib/assets/logo.svg'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sign in to your Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      ' Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4D81E7),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFFFFFFF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscure = !obscure),
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
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ResetPasswordPage(),
                )),
                child: const Text(
                  'Forgot Your Password?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              BlocConsumer<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  if (state is SignedIn) {
                    validateUserAfterSignIn(state.userCredential);
                  }
                },
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () {
                      getUser();
                      if (emailController.text.isNotEmpty &&
                          passwordController.text.isNotEmpty) {
                        BlocProvider.of<AuthenticationBloc>(context).add(
                          SignInEvent(
                              email: emailController.text,
                              password: passwordController.text),
                        );
                      } else {
                        showSnackBar(
                            title: 'Please enter a valid email and password');
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
                    child: state is AuthenticationLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Log In',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  );
                },
              ),
              const SizedBox(height: 24),
              persistedUser != null && persistedUser!['email'] != null
                  ? IconButton(
                      onPressed: () async {
                        bool isLocalyAuthenticated = await _authenticate();
                        if (isLocalyAuthenticated) {
                          BlocProvider.of<AuthenticationBloc>(context).add(
                            SignInEvent(
                              email: persistedUser!['email']!,
                              password: persistedUser!['password']!,
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.fingerprint_outlined,
                        color: Colors.white,
                        size: 48,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
