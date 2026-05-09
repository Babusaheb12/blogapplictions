import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:blogapplictions/Api/Api_url.dart';
import 'package:blogapplictions/Api/ConnectivityService.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final Dio _dio = Dio();

  HomeBloc() : super(HomeInitial()) {
    on<FetchPosts>((event, emit) async {
      print("🎯 HomeBloc: FetchPosts event received");
      developer.log("🎯 FetchPosts event received", name: "HomeBloc");
      emit(HomeLoading());
      await _fetchPosts(emit);
    });

    on<FetchNextPage>((event, emit) async {
      print("🎯 HomeBloc: FetchNextPage event received");
      developer.log("🎯 FetchNextPage event received", name: "HomeBloc");
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        await _fetchPosts(emit, pageToken: event.pageToken, existingPosts: currentState.posts);
      }
    });
  }

  Future<void> _fetchPosts(Emitter<HomeState> emit, {String? pageToken, List<dynamic>? existingPosts}) async {
    // Check connectivity
    final isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      print("❌ HomeBloc: No internet connection");
      developer.log("❌ No internet connection", name: "HomeBloc");
      emit(HomeError("No internet connection"));
      return;
    }

    try {
      final Map<String, dynamic> queryParameters = {
        'key': ApiUrls.apiKeys,
      };
      if (pageToken != null) {
        queryParameters['pageToken'] = pageToken;
      }

      print("📡 HomeBloc: Requesting ${ApiUrls.blogs} with params: $queryParameters");
      developer.log("📡 Request: GET ${ApiUrls.blogs} with params: $queryParameters", name: "HomeBloc");

      final response = await _dio.get(
        ApiUrls.blogs,
        queryParameters: queryParameters,
      );

      print("📥 HomeBloc: Response status: ${response.statusCode}");
      print("📥 HomeBloc: Response Data: ${response.data}");
      developer.log("📥 Response: ${response.statusCode} - ${response.data.toString().substring(0, 200)}...", name: "HomeBloc");


      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> newPosts = data['items'] ?? [];
        final String? nextPageToken = data['nextPageToken'];

        final List<dynamic> allPosts = existingPosts != null ? [...existingPosts, ...newPosts] : newPosts;

        emit(HomeLoaded(posts: allPosts, nextPageToken: nextPageToken));
      } else {
        print("❌ HomeBloc: Failed with status ${response.statusCode}");
        emit(HomeError("Failed to load posts: ${response.statusCode}"));
      }
    } catch (e) {
      print("❌ HomeBloc: Error: $e");
      developer.log("❌ Error fetching posts: $e", name: "HomeBloc", error: e);
      emit(HomeError("An error occurred: $e"));
    }
  }
}


