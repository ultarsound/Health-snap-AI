import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_strings.dart';
import '../models/health_item.dart';
import '../services/api_service.dart';
import '../widgets/health_card.dart';
import '../widgets/exercise_card.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  List<HealthItem> _meals = [];
  List<HealthItem> _exercises = [];
  bool _isLoadingMeals = true;
  bool _isLoadingExercises = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final isAr = context.read<AppProvider>().isArabic;
    final meals = await ApiService.fetchHealthyMeals(isArabic: isAr);
    final exercises = await ApiService.fetchExercises(isArabic: isAr);
    if (mounted) {
      setState(() {
        _meals = meals;
        _exercises = exercises;
        _isLoadingMeals = false;
        _isLoadingExercises = false;
      });
    }
  }

  Future<void> _search(String query) async {
    setState(() => _isLoadingMeals = true);
    final meals = await ApiService.fetchHealthyMeals(query: query, isArabic: context.read<AppProvider>().isArabic);
    if (mounted) setState(() { _meals = meals; _isLoadingMeals = false; });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = AppStrings.from(p.isArabic);
    final theme = Theme.of(context);
    final isDark = p.isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _search,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: s.searchHint,
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () { _searchController.clear(); _search(''); setState(() {}); })
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bell
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Icon(
                            p.notificationsMuted ? Icons.notifications_off : Icons.notifications_outlined,
                            color: theme.colorScheme.primary, size: 24),
                        ),
                        if (p.notificationCount > 0 && !p.notificationsMuted)
                          Positioned(
                            top: -4, right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: Text('${p.notificationCount}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.hello, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                    Text(s.homeSubtitle,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF212121))),
                  ]),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      Icon(Icons.favorite, color: theme.colorScheme.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(s.startToday,
                          style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              ),
            ),

            // ── Tab bar ───────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(10)),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.restaurant, size: 16), const SizedBox(width: 6), Text(s.tabFood),
                  ])),
                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.fitness_center, size: 16), const SizedBox(width: 6), Text(s.tabExercise),
                  ])),
                ],
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _isLoadingMeals
                      ? _shimmer()
                      : _meals.isEmpty
                          ? _empty(s.noResults, Icons.restaurant_outlined)
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _meals.length,
                              itemBuilder: (_, i) => HealthCard(item: _meals[i]),
                            ),
                  _isLoadingExercises
                      ? _shimmer()
                      : _exercises.isEmpty
                          ? _empty(s.noExercises, Icons.fitness_center)
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _exercises.length,
                              itemBuilder: (_, i) => ExerciseCard(item: _exercises[i]),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer() => ListView.builder(
    padding: const EdgeInsets.all(16), itemCount: 5,
    itemBuilder: (_, __) => Container(
      margin: const EdgeInsets.only(bottom: 12), height: 120,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
    ),
  );

  Widget _empty(String msg, IconData icon) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 60, color: Colors.grey[300]),
      const SizedBox(height: 12),
      Text(msg, style: TextStyle(color: Colors.grey[400], fontSize: 16)),
    ]),
  );

  @override
  void dispose() { _searchController.dispose(); _tabController.dispose(); super.dispose(); }
}
