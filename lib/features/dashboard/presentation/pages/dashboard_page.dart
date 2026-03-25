import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('لوحة التحكم', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // Responsive stat cards: use Wrap so content can flow vertically without
          // causing GridView inside a Column overflow issues.
          LayoutBuilder(builder: (ctx, constraints) {
            // decide card width: for wide screens show two columns, otherwise one
            final maxWidth = constraints.maxWidth;
            final cardWidth = maxWidth >= 500 ? (maxWidth - 12) / 2 : maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(width: cardWidth, child: _StatCard(title: 'عدد المنتجات', value: '124')),
                SizedBox(width: cardWidth, child: _StatCard(title: 'المبيعات اليوم', value: '1,240')),
                SizedBox(width: cardWidth, child: _StatCard(title: 'المستخدمون', value: '3,210')),
                SizedBox(width: cardWidth, child: _StatCard(title: 'الأرباح', value: '12,400')),
              ],
            );
          }),
          const SizedBox(height: 16),
          const Text('ملخص الأداء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('الطلبات خلال الأسبوع الماضي', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  LinearProgressIndicator(value: 0.6),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
