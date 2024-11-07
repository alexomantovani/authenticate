import 'package:authenticate/views/bloc/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();

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

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1B),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 120),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SvgPicture.asset('lib/assets/logo.svg'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter your registered email to get a reset password link',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  BlocListener<AuthenticationBloc, AuthenticationState>(
                    listener: (context, state) {
                      if (state is ForgotPasswordSent) {
                        showSnackBar(
                            title:
                                'Password reset request sent to ${emailController.text}');
                      } else if (state is AuthenticationError) {
                        showSnackBar(title: state.message);
                      }
                    },
                    child: ElevatedButton(
                      onPressed: () async {
                        if (emailController.text.isEmpty) {
                          showSnackBar(
                              title: 'Please fill the required email field');
                        } else {
                          BlocProvider.of<AuthenticationBloc>(context)
                              .add(ResetPasswordEvent(emailController.text));
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
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
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
