import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/component/loading/loading_screen_controller.dart';

class LoadingScreen {
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();
  factory LoadingScreen() => _shared;

  LoadingScreenController? controller;

  void show({required BuildContext context, required String text}) {
    if (controller?.update(text) ?? false) {
      return;
    }
    controller = _showOverlay(context: context, text: text);
  }

  void hide() {
    controller?.close();
    controller = null;
  }

  LoadingScreenController _showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final text0 = StreamController<String>();
    text0.add(text);

    final state = Overlay.of(context);

    final overlay = OverlayEntry(
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Material(
          color: Colors.black.withAlpha(180),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                // Dark semi-transparent card with blue neon shadow
                color: const Color(0xFF151E2B),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10CFFF).withValues(alpha: 0.5),
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(color: const Color(0xFF10CFFF), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 18,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      // Glowing circular progress indicator
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [Color(0xFF10CFFF), Color(0xFF005F80)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: const CircularProgressIndicator(
                          strokeWidth: 4.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      StreamBuilder(
                        stream: text0.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF10CFFF),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFF10CFFF),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    state.insert(overlay);

    return LoadingScreenController(
      close: () {
        text0.close();
        overlay.remove();
        return true;
      },
      update: (text) {
        text0.add(text);
        return true;
      },
    );
  }
}
