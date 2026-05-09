import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'dart:developer' as developer;

part 'sig_up_event.dart';
part 'sig_up_state.dart';

class SigUpBloc extends Bloc<SigUpEvent, SigUpState> {
  SigUpBloc() : super(SigUpInitial()) {
    on<SignUpSubmitted>((event, emit) async {
      emit(SignUpLoading());
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        
        developer.log("✅ Firebase Sign Up Success. UID: ${credential.user?.uid}", name: "SignUp");
        
        // Save additional details to Firestore
        if (credential.user != null) {
          await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
            'name': event.name,
            'email': event.email,
            'phone': event.phone,
            'createdAt': FieldValue.serverTimestamp(),
          });
          developer.log("✅ User details saved to Firestore", name: "SignUp");
        }
        
        emit(SignUpSuccess(uid: credential.user?.uid ?? ""));
      } on FirebaseAuthException catch (e) {
        developer.log("❌ Firebase Sign Up Failed. Error: ${e.message}", name: "SignUp", error: e);
        emit(SignUpFailure(error: e.message ?? "An error occurred"));
      } catch (e) {
        developer.log("❌ Firebase Sign Up Failed. Error: $e", name: "SignUp", error: e);
        emit(SignUpFailure(error: e.toString()));
      }
    });

    ////// ADD LOGIN 

    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        
        developer.log("✅ Firebase Login Success. UID: ${credential.user?.uid}", name: "Login");
        
        emit(LoginSuccess(uid: credential.user?.uid ?? ""));
      } on FirebaseAuthException catch (e) {
        developer.log("❌ Firebase Login Failed. Error: ${e.message}", name: "Login", error: e);
        emit(LoginFailure(error: e.message ?? "An error occurred"));
      } catch (e) {
        developer.log("❌ Firebase Login Failed. Error: $e", name: "Login", error: e);
        emit(LoginFailure(error: e.toString()));
      }
    });

    on<GoogleSignInSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        await gsi.GoogleSignIn.instance.initialize(
          serverClientId: '498732420936-egufo448a6cq5k653aa8mmo1droshmdg.apps.googleusercontent.com',
        );
        final gsi.GoogleSignInAccount? googleUser = await gsi.GoogleSignIn.instance.authenticate();
        if (googleUser == null) {
          emit(LoginFailure(error: "Sign in aborted by user"));
          return;
        }
        final gsi.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        
        developer.log("✅ Firebase Google Login Success. UID: ${userCredential.user?.uid}", name: "Login");
        
        // Save user details to Firestore
        if (userCredential.user != null) {
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'name': userCredential.user!.displayName ?? "Google User",
            'email': userCredential.user!.email ?? "",
            'phone': userCredential.user!.phoneNumber ?? "",
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          developer.log("✅ User details saved to Firestore (Google)", name: "Login");
        }
        
        emit(LoginSuccess(uid: userCredential.user?.uid ?? ""));
      } catch (e) {
        developer.log("❌ Firebase Google Login Failed. Error: $e", name: "Login", error: e);
        emit(LoginFailure(error: e.toString()));
      }
    });
  }












}



