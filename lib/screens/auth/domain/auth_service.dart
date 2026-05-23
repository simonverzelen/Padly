import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:padly/route/screen_export.dart';
import 'package:padly/screens/games/src/data/recent_clubs_cache.dart';
import 'package:padly/screens/games/src/data/recent_players_cache.dart';
import 'package:padly/screens/games/src/data/user_preferences_cache.dart';
import 'package:padly/services/supabase_firebase_auth_bridge.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

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

      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          id: user.uid,
        ),
      );
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

      if (!user.emailVerified) {
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

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      final hasProfile = data != null &&
          (data['firstName'] as String?)?.isNotEmpty == true &&
          (data['lastName'] as String?)?.isNotEmpty == true;

      final bridge = SupabaseFirebaseAuthBridge(Supabase.instance.client);
      await bridge.signInToSupabaseWithFirebase();

      if (hasProfile) {
        final existsInSupabase =
            await bridge.profileExistsInSupabase(user.uid);
        if (!existsInSupabase) {
          await bridge.syncProfileFromFirestore(data, user.uid);
        }
      }

      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        hasProfile ? entryPointScreenRoute : userInfoScreenRoute,
        (route) => false,
        arguments: hasProfile ? null : false,
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

  Future<bool> isLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(
        msg: "Please check your mailbox",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: e.message ?? "Something went wrong",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Future<void> signout({required BuildContext context}) async {
    await UserPreferencesCache().clear();
    await RecentPlayersCache().clear();
    await RecentClubsCache().clear();
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushNamed(
      context,
      onbordingScreenRoute,
    );
  }

  User? getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    return user;
  }
}
