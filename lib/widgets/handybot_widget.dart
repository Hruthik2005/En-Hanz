import 'package:flutter/material.dart';

class HandyBot extends StatelessWidget {
  final double size;
  final bool waving;

  const HandyBot({super.key, this.size = 100, this.waving = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.deepPurple.shade100,
          child: Icon(Icons.android, size: size * 0.5, color: Colors.deepPurple),
        ),
        if (waving)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Handy the Robot', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
