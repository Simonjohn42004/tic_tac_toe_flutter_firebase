import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/bloc/auth/auth_bloc.dart';
import 'package:tic_tac_toe/bloc/auth/auth_event.dart';
import 'package:tic_tac_toe/component/glowing_button.dart';

class OnlineHomePage extends StatefulWidget {
  const OnlineHomePage({super.key});

  @override
  State<OnlineHomePage> createState() => _OnlineHomePageState();
}

class _OnlineHomePageState extends State<OnlineHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tic Tac Toe")),
      body: Center(
        child: GlowingButton(
          label: "Sign Out",
          onTap: () {
            context.read<AuthBloc>().add(AuthEventLogOut());
          },
        ),
      ),
    );
  }
}
