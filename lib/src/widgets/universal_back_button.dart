import 'package:flutter/material.dart';

class UniversalBackButton extends StatelessWidget {
  const UniversalBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () async {
          final navigator = Navigator.of(context);

          if (navigator.canPop()) {
            navigator.pop();
          }
        },
      ),
    );
  }
}
