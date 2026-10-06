import 'package:flutter/material.dart';
import '../guides/mode_guides.dart';
import '../theme.dart';

/// Full detailed guide for one mode, or index of all modes.
class GuideScreen extends StatelessWidget {
  final String? modeId;

  const GuideScreen({super.key, this.modeId});

  @override
  Widget build(BuildContext context) {
    final guide = modeId != null ? ModeGuides.byId(modeId!) : null;

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        title: Text(guide?.name ?? 'How to measure'),
        backgroundColor: AppColors.nearBlack,
      ),
      body: guide == null ? _index(context) : _detail(guide),
    );
  }

  Widget _index(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: AppColors.glass,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              ModeGuides.handMarkRule,
              style: const TextStyle(height: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...ModeGuides.all.map(
          (g) => ListTile(
            title: Text(g.name),
            subtitle: Text(
              g.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.accentCyan),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GuideScreen(modeId: g.id)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _detail(ModeGuide guide) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(guide.summary, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Text(
          ModeGuides.handMarkRule,
          style: const TextStyle(fontSize: 13, height: 1.35, color: AppColors.accentCyan),
        ),
        const SizedBox(height: 20),
        ...guide.steps.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 6),
                Text(s.body, style: const TextStyle(height: 1.4)),
                if (s.tip != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Tip: ${s.tip}',
                    style: const TextStyle(color: AppColors.warningAmber, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (guide.keys.isNotEmpty) ...[
          const Divider(color: Colors.white12),
          const Text('Keys / buttons', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...guide.keys.map(
            (k) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $k', style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
        if (guide.options.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Options', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...guide.options.map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $o', style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ],
    );
  }
}
