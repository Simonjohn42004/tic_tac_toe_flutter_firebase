import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/bloc/auth/auth_bloc.dart';
import 'package:tic_tac_toe/bloc/auth/auth_event.dart';
import 'package:tic_tac_toe/component/glowing_button.dart';
import 'package:tic_tac_toe/screens/profile/profile_screen.dart';

class OnlineHomePage extends StatefulWidget {
  const OnlineHomePage({super.key});

  @override
  State<OnlineHomePage> createState() => _OnlineHomePageState();
}

class _OnlineHomePageState extends State<OnlineHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tic Tac Toe")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlowingButton(
              label: "Profile",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            const SizedBox(height: 20),
            GlowingButton(
              label: "Sign Out",
              onTap: () {
                context.read<AuthBloc>().add(AuthEventLogOut());
              },
            ),
          ],
        ),
      ),
    );
  }
}
