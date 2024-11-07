import 'package:authenticate/views/bloc/authentication_bloc.dart';
import 'package:authenticate/views/login/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = false;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      debugPrint('Usuário desconectado com sucesso.');
    } catch (e) {
      debugPrint('Erro ao desconectar: $e');
    }
  }

  Future<void> deleteAccount() async {
    setState(() => loading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        await storage.deleteAll();
      } else {
        debugPrint('Nenhum usuário logado.');
      }
      setState(() => loading = false);
    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);
      debugPrint('Erro ao deletar a conta: ${e.message}');
    }
  }

  pop() {
    Navigator.pop(context);
  }

  navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  dynamic openDialog({
    required String title,
    required String cancelButtonLabel,
    required String confirmButtonLabel,
    required VoidCallback confirmButtonHandler,
    required IconData iconData,
  }) {
    showDialog(
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
            Icon(
              iconData,
              color: const Color(0xFF0D0D1B),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1B),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => openDialog(
              title: 'Sign Out?',
              cancelButtonLabel: 'Cancel',
              confirmButtonLabel: 'Ok',
              iconData: Icons.logout_outlined,
              confirmButtonHandler: () async {
                await signOut().then((value) => {
                      pop(),
                      navigateToLogin(),
                    });
              },
            ),
            icon: const Icon(
              Icons.logout_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SvgPicture.asset('lib/assets/logo_white.svg'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Home Page',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              BlocConsumer<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {},
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () {
                      openDialog(
                        title: 'Delete Account?',
                        cancelButtonLabel: 'Cancel',
                        confirmButtonLabel: 'Delete',
                        iconData: Icons.delete_outline_rounded,
                        confirmButtonHandler: () async {
                          pop();
                          BlocProvider.of<AuthenticationBloc>(context).add(
                              DeleteAccountEvent(
                                  FirebaseAuth.instance.currentUser));
                          await storage.deleteAll();
                          navigateToLogin();
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB272D),
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
                            'Delete Account',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
