import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/features/home/presentation/cubit/home_cubit.dart';
import 'package:impulse/features/home/presentation/pages/main_menu_page.dart';

class HomePage extends StatelessWidget {
  final String? userId;
  final String? userName;
  final String? userEmail;

  const HomePage({super.key, this.userId, this.userName, this.userEmail});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(ApiClient(userId: userId))..loadProgress(),
      child: Scaffold(
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoaded) {
              return MainMenuPage(userId: userId, userName: userName, userEmail: userEmail,);
            } else if (state is HomeError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}