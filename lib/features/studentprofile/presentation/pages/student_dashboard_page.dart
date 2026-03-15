import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaman/core/widgets/animated_fade_in.dart';
import 'package:shaman/core/widgets/avatar_header.dart';
import '../state/student_profile_provider.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<StudentProfileProvider>(context);
    final p = prov.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم الطالب'), actions: [
        IconButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false), icon: const Icon(Icons.home)),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedFadeIn(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AvatarHeader(name: p?.name, subtitle: p?.major, onEdit: () => Navigator.pushNamed(context, '/student-profile')),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  AnimatedFadeIn(child: _infoCard('المواد المسجلة', '12')),
                  AnimatedFadeIn(child: _infoCard('المعدل العام', '3.85')),
                  AnimatedFadeIn(child: _infoCard('الحضور', '92%')),
                  AnimatedFadeIn(child: _infoCard('المهام', '4 متأخرة')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
