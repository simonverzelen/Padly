import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:padly/route/screen_export.dart';

class AuthService {
  Future<void> signup(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      /*final supabase = Supabase.instance.client;
      await supabase.auth.signUp(
        email: email,
        password: password,
      );*/

      Navigator.pushNamed(context, logInScreenRoute);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else {
        message = e.message ?? "Something went wrong";
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> signin(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = FirebaseAuth.instance.currentUser!;

      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          firstName: user.displayName ?? user.email,
          id: user.uid,
        ),
      );

      if (user.emailVerified == false) {
        Fluttertoast.showToast(
          msg: "Please check your mailbox",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        entryPointScreenRoute,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "Something went wrong";
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> resetPassword({required String email}) async {
    FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    Fluttertoast.showToast(
      msg: "Please check your mailbox",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamed(
      context,
      onbordingScreenRoute,
    );
  }
}
