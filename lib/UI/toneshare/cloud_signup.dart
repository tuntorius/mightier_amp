import 'package:flutter/material.dart';

import 'toneshare_main.dart';

class SignUpForm extends StatefulWidget {
  final void Function() onSignInTap;
  const SignUpForm({super.key, required this.onSignInTap});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
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

  void _signUpWithEmailAndPassword() async {
    if (_validateAndSaveForm()) {
      setState(() {
        _errorMessage = "";
      });

      /*try {
        ToneShare.startLoading(context);
        var result = await Supabase.instance.client.auth.signUp(
            password: _passwordController.text.trim(),
            email: _emailController.text.trim());

        //if succeeded, proceed to login screen with the provided email
      } on AuthException catch (e) {
        setState(() {
          _errorMessage = "You must provide email and password";
        });
      } catch (e) {
        setState(() {
          _errorMessage = "No internet connection";
        });
      } finally {
        ToneShare.stopLoading(context);
      }*/
    }
  }

  void _SignUpWithGoogle() async {
    // try {
    //   // Trigger the authentication flow
    //   final GoogleSignUpAccount? googleUser = await GoogleSignUp().SignUp();

    //   // Obtain the auth details from the request
    //   final GoogleSignUpAuthentication? googleAuth =
    //       await googleUser?.authentication;

    //   // Create a new credential
    //   final AuthCredential credential = GoogleAuthProvider.credential(
    //     idToken: googleAuth?.idToken,
    //     accessToken: googleAuth?.accessToken,
    //   );
    //   await FirebaseAuth.instance.SignUpWithCredential(credential);
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
            onPressed: _signUpWithEmailAndPassword,
            child: const Text('Sign In'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _SignUpWithGoogle,
            child: const Text('Sign in with Google'),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: widget.onSignInTap,
            child: const Text('Already have an account? Sign in'),
          ),
        ],
      ),
    );
  }
}
