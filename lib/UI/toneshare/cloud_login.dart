import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/modules/cloud/cloudManager.dart';
import 'package:pocketbase/pocketbase.dart';

import 'toneshare_main.dart';

class SignInForm extends StatefulWidget {
  final void Function() onSignUpTap;
  const SignInForm({super.key, required this.onSignUpTap});

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _errorMessage = '';

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form?.validate() ?? false) {
      form?.save();
      return true;
    }
    return false;
  }

  void _signInWithEmailAndPassword() async {
    if (_validateAndSaveForm()) {
      setState(() {
        _errorMessage = "";
      });

      try {
        ToneShare.startLoading(context);
        var result = await CloudManager.instance.signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());
        print(result);
      } on ClientException catch (e) {
        if (e.isAbort) {
          _errorMessage = "No internet connection";
        } else {
          _errorMessage = e.response["message"];
          //"Wrong credentials or account not verified";
        }
        setState(() {});
      } finally {
        ToneShare.stopLoading(context);
      }
    }
  }

  void _signInWithGoogle() async {
    // try {
    //   // Trigger the authentication flow
    //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    //   // Obtain the auth details from the request
    //   final GoogleSignInAuthentication? googleAuth =
    //       await googleUser?.authentication;

    //   // Create a new credential
    //   final AuthCredential credential = GoogleAuthProvider.credential(
    //     idToken: googleAuth?.idToken,
    //     accessToken: googleAuth?.accessToken,
    //   );
    //   await FirebaseAuth.instance.signInWithCredential(credential);
    // } on FirebaseAuthException catch (e) {
    //   setState(() {
    //     _errorMessage = e.message ?? "Unknown Error";
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _signInWithEmailAndPassword,
            child: const Text('Sign In'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _signInWithGoogle,
            child: const Text('Sign in with Google'),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: widget.onSignUpTap,
            child: const Text('Don\'t have an account? Sign up'),
          ),
        ],
      ),
    );
  }
}
