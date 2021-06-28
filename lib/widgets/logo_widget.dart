import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({Key? key, this.fontSize = 50, this.alternative = false})
      : super(key: key);

  final double fontSize;
  final bool alternative;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Fipro',
        style: TextStyle(
          fontSize: fontSize,
          color: alternative
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
