import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:blogapplictions/Api/ConnectivityService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blogapplictions/Api/shared_preference.dart';

part 'logout_event.dart';
part 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final Dio _dio = Dio();

  LogoutBloc() : super(LogoutInitial()) {
    on<PerformLogout>((event, emit) async {
      print("🎯 LogoutBloc: PerformLogout event received");
      emit(LogoutLoading());
      
      // Check connectivity
      final isConnected = await ConnectivityService.isConnected();
      if (!isConnected) {
        print("❌ LogoutBloc: No internet connection");
        developer.log("❌ No internet connection", name: "LogoutBloc");
        emit(LogoutFailure("No internet connection"));
        return;
      }

      try {
        // Mock API Call
        print("📡 LogoutBloc: Requesting POST https://httpbin.org/post");
        developer.log("📡 Request: POST https://httpbin.org/post", name: "LogoutBloc");
        
        final response = await _dio.post(
          'https://httpbin.org/post',
          data: {'action': 'logout'},
        );

        print("📥 LogoutBloc: Response status: ${response.statusCode}");
        print("📥 LogoutBloc: Response Data: ${response.data}");
        developer.log("📥 Response: ${response.statusCode} - ${response.data.toString().substring(0, 100)}...", name: "LogoutBloc");

        if (response.statusCode == 200) {
          // Actual Logout
          await FirebaseAuth.instance.signOut();
          await Prefs.logout();
          
          emit(LogoutSuccess());
        } else {
          emit(LogoutFailure("Failed to logout API: ${response.statusCode}"));
        }
      } catch (e) {
        print("❌ LogoutBloc: Error: $e");
        developer.log("❌ Error during logout: $e", name: "LogoutBloc", error: e);
        emit(LogoutFailure("An error occurred: $e"));
      }
    });
  }
}
