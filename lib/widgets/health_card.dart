import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/health_item.dart';
import '../providers/app_provider.dart';
import '../l10n/app_strings.dart';
import '../screens/recipe_detail_screen.dart';

class HealthCard extends StatelessWidget {
  final HealthItem item;
  const HealthCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = AppStrings.from(p.isArabic);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(item: item))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            item.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(item.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(theme)))
                : _placeholder(theme),
            Positioned(
              bottom: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(Icons.menu_book_rounded, color: Colors.white, size: 13),
                  const SizedBox(width: 4),
                  Text(s.viewRecipeLabel, style: const TextStyle(color: Colors.white, fontSize: 11)),
                ]),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(item.category,
                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 6),
              Text(item.description,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 4,
                  children: item.benefits.take(3).map((b) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check, size: 10, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 3),
                      Text(b, style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 11)),
                    ]),
                  )).toList()),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder(ThemeData t) => Container(
    height: 150,
    decoration: BoxDecoration(
        color: t.colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
    child: Center(child: Icon(Icons.restaurant, size: 50, color: t.colorScheme.primary.withOpacity(0.3))),
  );
}
