import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<FetchUserProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          if (doc.exists) {
            final data = doc.data();
            final name = data?['name'] ?? 'No Name';
            final email = data?['email'] ?? 'No Email';
            emit(ProfileLoaded(name: name, email: email));
          } else {
            emit(ProfileError(error: 'User document not found'));
          }
        } else {
          emit(ProfileError(error: 'User not logged in'));
        }
      } catch (e) {
        emit(ProfileError(error: e.toString()));
      }
    });
  }
}
