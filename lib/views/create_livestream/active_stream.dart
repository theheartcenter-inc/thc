import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/views/widgets.dart';

class ActiveStream extends StatefulWidget {
  const ActiveStream({super.key});

  @override
  State<ActiveStream> createState() => _ActiveStreamState();
}

class _ActiveStreamState extends StateAsync<ActiveStream> {
  Timer? timer;
  void setTimer([_]) {
    timer?.cancel();
    if (!overlayVisible) setState(() => overlayVisible = true);
    timer = Timer(
      const Duration(seconds: 4),
      () => safeState(() => overlayVisible = false),
    );
  }

  bool overlayVisible = true;
  bool buttonHovered = false;

  void buttonHover(bool isHovered) {
    buttonHovered = isHovered;
    if (isHovered) timer?.cancel();
  }

  void mouseOffScreen([_]) async {
    timer?.cancel();

    await sleep(0.01); // wait for buttonHovered to update
    if (buttonHovered) return;

    safeState(() => overlayVisible = false);
  }

  void onTap() {
    if (timer?.isActive ?? false) {
      timer?.cancel();
      setState(() => overlayVisible = false);
    } else {
      setTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MouseRegion(
        onHover: setTimer,
        onExit: mouseOffScreen,
        child: GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              const _Backdrop(),
              StreamOverlay(overlayVisible ? 1.0 : 0.25, child: const _ViewCount()),
              StreamOverlay(overlayVisible ? 1.0 : 0.0, child: const _StreamingCamera()),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamOverlay(
        overlayVisible ? Offset.zero : const Offset(0, 2),
        child: _EndButton(onPressed: navigator.pop, onHover: buttonHover),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'go live',
      child: Transform.scale(
        scale: 1.1,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.elliptical(50, 30)),
          ),
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}

class _StreamingCamera extends StatelessWidget {
  const _StreamingCamera();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'A very cool Agora stream will be here',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}

class _ViewCount extends StatelessWidget {
  const _ViewCount();

  @override
  Widget build(BuildContext context) {
    final int peopleWatching = Random().nextBool() ? 69 : 420;
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Text(
          '$peopleWatching watching',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _EndButton extends FilledButton {
  const _EndButton({required super.onPressed, required super.onHover})
      : super(style: _style, child: const Text('End', style: TextStyle(fontSize: 18)));

  static const _style = ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Colors.red),
    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 25, vertical: 18)),
    shape: MaterialStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
    ),
  );
}

class StreamOverlay<T> extends StatelessWidget {
  const StreamOverlay(this.value, {super.key, required this.child})
      : assert(value is Offset || value is double);

  final T value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final child = AnimatedOpacity(
      opacity: context.watch<StreamOverlayFadeIn>().state ? 1 : 0,
      duration: Durations.medium1,
      child: this.child,
    );
    const duration = Durations.medium1;

    return switch (value) {
      final double opacity => AnimatedOpacity(
          opacity: opacity,
          duration: duration,
          child: child,
        ),
      final Offset offset => AnimatedSlide(
          offset: offset,
          duration: duration,
          curve: Curves.ease,
          child: child,
        ),
      _ => throw TypeError(),
    };
  }
}

class StreamOverlayFadeIn extends Cubit<bool> {
  StreamOverlayFadeIn(Animation<double> animation) : super(false) {
    animation.addStatusListener((status) => emit(status == AnimationStatus.completed));
  }
}
