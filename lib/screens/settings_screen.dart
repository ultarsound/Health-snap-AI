import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _wCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final w = context.read<AppProvider>().userWeight;
    if (w > 0) _wCtrl.text = w.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = AppStrings.from(p.isArabic);
    final theme = Theme.of(context);
    final isDark = p.isDarkMode;
    final stats = p.getWeightLossStats();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 8),
            Text(s.settingsTitle,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF212121))),
            const SizedBox(height: 28),

            // ── Language dropdown ───────────────────────────────────────
            _section(s.secLanguage, isDark),
            _langDropdown(p, s, theme, isDark),
            const SizedBox(height: 24),

            // ── Dark mode ───────────────────────────────────────────────
            _section(s.secAppearance, isDark),
            _tile(
              theme: theme,
              icon: isDark ? Icons.dark_mode : Icons.light_mode,
              iconColor:
                  isDark ? const Color(0xFF7C4DFF) : const Color(0xFFFF8F00),
              title: s.darkMode,
              subtitle: isDark ? s.darkModeOn : s.darkModeOff,
              trailing: Switch(
                  value: isDark,
                  onChanged: (_) => p.toggleDarkMode(),
                  activeColor: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),

            // ── Notifications ───────────────────────────────────────────
            _section(s.secNotifications, isDark),
            _tile(
              theme: theme,
              icon: p.notificationsMuted
                  ? Icons.notifications_off
                  : Icons.notifications_active,
              iconColor:
                  p.notificationsMuted ? Colors.grey : const Color(0xFF00BCD4),
              title: s.muteNotifs,
              subtitle: p.notificationsMuted ? s.notifsMuted : s.notifsActive,
              trailing: Switch(
                  value: p.notificationsMuted,
                  onChanged: (_) => p.toggleNotifications(),
                  activeColor: Colors.red),
            ),
            const SizedBox(height: 24),

            // ── Weight ─────────────────────────────────────────────────
            _section(s.secHealth, isDark),
            _weightCard(p, s, theme, isDark),

            // ── Stats ──────────────────────────────────────────────────
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 24),
              _section(s.statsTitle, isDark),
              Text(s.statsSubtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _statCard(
                        theme,
                        '',
                        s.weekLabel,
                        '-${stats['weekly']!.toStringAsFixed(1)} kg',
                        const Color(0xFF00BCD4))),
                const SizedBox(width: 8),
                Expanded(
                    child: _statCard(
                        theme,
                        '',
                        s.monthLabel,
                        '-${stats['monthly']!.toStringAsFixed(1)} kg',
                        const Color(0xFF2E7D32))),
                const SizedBox(width: 8),
                Expanded(
                    child: _statCard(
                        theme,
                        '',
                        s.threeMonthsLabel,
                        '-${stats['threeMonths']!.toStringAsFixed(1)} kg',
                        const Color(0xFFFF6B35))),
              ]),
              const SizedBox(height: 12),
              _tipBox(s.statsTip, theme),
              const SizedBox(height: 16),
              _progressCard(stats, p.userWeight, s, theme, isDark),
            ] else ...[
              const SizedBox(height: 12),
              _tipBox(s.enterWeightHint, theme),
            ],

            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  // ── Language dropdown ────────────────────────────────────────────────────
  // ── Language dropdown ────────────────────────────────────────────────────
  Widget _langDropdown(
      AppProvider p, AppStrings s, ThemeData theme, bool isDark) {
    final items = [
      _LangOption(code: 'ar', flag: '', label: 'العربية'),
      _LangOption(code: 'en', flag: '', label: 'English'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: p.language,
          isExpanded: true,

          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.primary,
          ),

          dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,

          borderRadius: BorderRadius.circular(14),

          // العنصر المختار
          selectedItemBuilder: (_) => items.map((item) {
            return Row(
              children: [
                Text(item.flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            );
          }).toList(),

          // عناصر القائمة
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item.code,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      item.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.code == 'ar' ? 'Arabic' : 'الإنجليزية',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (p.language == item.code)
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),

          onChanged: (v) {
            if (v != null) {
              p.setLanguage(v);
            }
          },
        ),
      ),
    );
  }

  // ── Weight card ──────────────────────────────────────────────────────────
  Widget _weightCard(
      AppProvider p, AppStrings s, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.monitor_weight,
                color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(s.weightLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(s.weightSub,
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ])),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _wCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: s.weightHint,
                suffixText: 'kg',
                filled: true,
                fillColor:
                    isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.withOpacity(0.3))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              final w = double.tryParse(_wCtrl.text);
              if (w != null && w > 0) {
                p.setUserWeight(w);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(s.weightSaved),
                  backgroundColor: const Color(0xFF2E7D32),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
            child: Text(s.save),
          ),
        ]),
      ]),
    );
  }

  Widget _section(String title, bool isDark) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87)),
      );

  Widget _tile(
          {required ThemeData theme,
          required IconData icon,
          required Color iconColor,
          required String title,
          required String subtitle,
          required Widget trailing}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text(subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ])),
          trailing,
        ]),
      );

  Widget _statCard(ThemeData theme, String emoji, String label, String value,
          Color color) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ]),
      );

  Widget _tipBox(String msg, ThemeData theme) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12))),
        ]),
      );

  Widget _progressCard(Map<String, double> stats, double weight, AppStrings s,
          ThemeData theme, bool isDark) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.journeyTitle,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 14),
          _progressRow(s.week1Label, stats['weekly']!, weight, Colors.cyan),
          const SizedBox(height: 10),
          _progressRow(s.month1Label, stats['monthly']!, weight,
              const Color(0xFF2E7D32)),
          const SizedBox(height: 10),
          _progressRow(s.threeMonths1, stats['threeMonths']!, weight,
              const Color(0xFFFF6B35)),
        ]),
      );

  Widget _progressRow(String label, double loss, double total, Color color) {
    final pct = (loss / total * 100).clamp(0.0, 100.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text('-${loss.toStringAsFixed(1)} kg',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
            value: pct / 100,
            backgroundColor: Colors.grey.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8),
      ),
    ]);
  }

  @override
  void dispose() {
    _wCtrl.dispose();
    super.dispose();
  }
}

class _LangOption {
  final String code, flag, label;
  const _LangOption(
      {required this.code, required this.flag, required this.label});
}
