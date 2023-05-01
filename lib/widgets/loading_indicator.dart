import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key, required this.active});

  final bool active;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late Animation<double> paddingAnimation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    paddingAnimation = Tween<double>(begin: -50, end: 65).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutSine,
      ),
    );
  }

  @override
  void didUpdateWidget(LoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    widget.active
        ? animationController.forward(from: animationController.value)
        : animationController.reverse(from: animationController.value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, _) {
        return Positioned.fill(
          top: paddingAnimation.value,
          child: const Align(
            alignment: Alignment.topCenter,
            child: RefreshProgressIndicator(
              semanticsLabel: "Loading Markers",
            ),
          ),
        );
      },
    );
  }
}
