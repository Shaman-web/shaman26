import 'package:flutter/material.dart';
import 'package:shaman/core/widgets/avatar_header.dart';
import 'package:shaman/core/widgets/animated_fade_in.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي'), actions: [
        IconButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false), icon: const Icon(Icons.home)),
      ]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedFadeIn(
            child: Column(mainAxisSize: MainAxisSize.min, children: [AvatarHeader(name: 'اسم المستخدم', subtitle: 'user@example.com')]),
          ),
        ),
      ),
    );
  }
}
