import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/health_item.dart';
import '../providers/app_provider.dart';
import '../l10n/app_strings.dart';
import '../services/api_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final HealthItem item;
  const RecipeDetailScreen({super.key, required this.item});
  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HealthItem? _full;
  bool _loading = true;
  late bool _isFood;

  @override
  void initState() {
    super.initState();
    _isFood = widget.item.type == 'food';
    _tabController = TabController(length: _isFood ? 3 : 2, vsync: this);
    _loadFull();
  }

  Future<void> _loadFull() async {
    if (_isFood && widget.item.mealDbId != null) {
      final full = await ApiService.fetchMealDetail(widget.item.mealDbId!);
      if (mounted) setState(() { _full = full ?? widget.item; _loading = false; });
    } else {
      if (mounted) setState(() { _full = widget.item; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = AppStrings.from(p.isArabic);
    final theme = Theme.of(context);
    final isDark = p.isDarkMode;
    final item = _full ?? widget.item;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(slivers: [
              // ── Hero app bar ────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: item.imageUrl.isNotEmpty ? 280 : 140,
                pinned: true,
                backgroundColor: theme.colorScheme.primary,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: item.imageUrl.isNotEmpty
                      ? Stack(fit: StackFit.expand, children: [
                          Image.network(item.imageUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(theme)),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                        ])
                      : _placeholder(theme),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Title + category
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Text(item.title,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(item.category,
                            style: TextStyle(color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ]),

                    if (item.area != null) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.place_outlined, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(item.area!, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ]),
                    ],
                    const SizedBox(height: 16),

                    // Benefits chips
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: item.benefits.map((b) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2))),
                        child: Text(b, style: TextStyle(color: theme.colorScheme.primary,
                            fontSize: 11, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Tab bar
                    Container(
                      decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E2E) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12)),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(10)),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        tabs: _isFood
                            ? [Tab(text: s.tabIngredients), Tab(text: s.tabInstructions), Tab(text: s.tabBenefits)]
                            : [Tab(text: s.tabHowTo), Tab(text: s.tabBenefits)],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tab views
                    SizedBox(
                      height: 440,
                      child: TabBarView(
                        controller: _tabController,
                        children: _isFood
                            ? [
                                _ingredients(item, theme, s),
                                _instructions(item, theme, isDark, s),
                                _benefits(item, theme, s),
                              ]
                            : [
                                _instructions(item, theme, isDark, s),
                                _benefits(item, theme, s),
                              ],
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
    );
  }

  Widget _ingredients(HealthItem item, ThemeData theme, AppStrings s) {
    if (item.ingredients.isEmpty) {
      return Center(child: Text(s.noIngredients, style: TextStyle(color: Colors.grey[400])));
    }
    return ListView.builder(
      itemCount: item.ingredients.length,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(child: Text('${i + 1}',
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(item.ingredients[i], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          if (i < item.measures.length && item.measures[i].isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(item.measures[i],
                  style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
        ]),
      ),
    );
  }

  Widget _instructions(HealthItem item, ThemeData theme, bool isDark, AppStrings s) {
    final raw = item.instructions.isNotEmpty ? item.instructions : (s.noIngredients);
    final steps = raw.split(RegExp(r'\n+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return ListView.builder(
      itemCount: steps.length,
      itemBuilder: (_, i) {
        final clean = steps[i].replaceFirst(RegExp(r'^(\d+[\.\-\)]\s*|Step\s*\d+[\:\-]?\s*)'), '');
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: theme.cardTheme.color, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.08))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)]),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text('${i + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(clean.isNotEmpty ? clean : steps[i],
                    style: TextStyle(fontSize: 13, height: 1.6,
                        color: isDark ? Colors.white70 : Colors.black87)),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _benefits(HealthItem item, ThemeData theme, AppStrings s) {
    final extras = _isFood ? s.extraFoodBenefits : s.extraExerciseBenefits;
    final all = [...item.benefits, ...extras];
    return ListView.builder(
      itemCount: all.length,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.15))),
        child: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(all[i], style: const TextStyle(fontSize: 13, height: 1.4))),
        ]),
      ),
    );
  }

  Widget _placeholder(ThemeData t) => Container(
    color: t.colorScheme.primary.withOpacity(0.15),
    child: Center(child: Icon(
        _isFood ? Icons.restaurant : Icons.fitness_center,
        size: 70, color: t.colorScheme.primary.withOpacity(0.3))),
  );

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }
}
