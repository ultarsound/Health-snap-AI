import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/health_item.dart';
import '../providers/app_provider.dart';
import '../l10n/app_strings.dart';
import '../screens/recipe_detail_screen.dart';

class ExerciseCard extends StatelessWidget {
  final HealthItem item;
  const ExerciseCard({super.key, required this.item});

  Color _color(String c) {
    switch (c) {
      case 'كارديو': case 'Cardio': return const Color(0xFF00BCD4);
      case 'قوة': case 'Strength': return const Color(0xFFFF6B35);
      case 'استرخاء': case 'Relaxation': return const Color(0xFF9C27B0);
      default: return const Color(0xFF2E7D32);
    }
  }

  IconData _icon(String c) {
    switch (c) {
      case 'كارديو': case 'Cardio': return Icons.directions_run;
      case 'قوة': case 'Strength': return Icons.fitness_center;
      case 'استرخاء': case 'Relaxation': return Icons.self_improvement;
      default: return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = AppStrings.from(p.isArabic);
    final theme = Theme.of(context);
    final color = _color(item.category);

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(item: item))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(_icon(item.category), color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(item.category, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 5),
            Text(item.description, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 2),
            const SizedBox(height: 10),
            Row(children: [
              Wrap(spacing: 6, runSpacing: 4,
                  children: item.benefits.take(2).map((b) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                    child: Text(b, style: TextStyle(color: color, fontSize: 11)),
                  )).toList()),
              const Spacer(),
              Row(children: [
                Text(s.detailsLabel, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_forward_ios_rounded, color: color, size: 12),
              ]),
            ]),
          ])),
        ]),
      ),
    );
  }
}
