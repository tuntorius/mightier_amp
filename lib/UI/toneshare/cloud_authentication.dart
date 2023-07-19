import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/toneshare/cloud_login.dart';
import 'package:mighty_plug_manager/UI/toneshare/cloud_signup.dart';

enum AuthPage { signIn, signUp }

class CloudAuthentication extends StatefulWidget {
  const CloudAuthentication({super.key});

  @override
  State<CloudAuthentication> createState() => _CloudAuthenticationState();
}

class _CloudAuthenticationState extends State<CloudAuthentication> {
  AuthPage _pageMode = AuthPage.signIn;

  void _showSignup() {
    setState(() {
      _pageMode = AuthPage.signUp;
    });
  }

  void _showSignIn() {
    setState(() {
      _pageMode = AuthPage.signIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pageMode == AuthPage.signIn) {
      return SignInForm(onSignUpTap: _showSignup);
    } else {
      return SignUpForm(onSignInTap: _showSignIn);
    }
  }
}
