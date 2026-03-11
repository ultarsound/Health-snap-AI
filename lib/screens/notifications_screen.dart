import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_strings.dart';
import '../models/health_item.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<HealthNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final isAr = context.read<AppProvider>().isArabic;
    final list = await ApiService.fetchHealthNotifications(isArabic: isAr);
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
      context.read<AppProvider>().clearNotifications();
    }
  }

  String _formatTime(DateTime time, AppStrings s) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return s.formatAgo(diff.inMinutes, 'دقيقة', 'min');
    if (diff.inHours < 24) return s.formatAgo(diff.inHours, 'ساعة', 'hr');
    return s.formatAgo(diff.inDays, 'يوم', 'day');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = AppStrings.from(p.isArabic);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.notificationsTitle),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => setState(() {
              for (var n in _notifications) n.isRead = true;
            }),
            child: Text(s.markAllRead,
                style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.notifications_none,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(s.noNotifications,
                          style: TextStyle(color: Colors.grey[400])),
                    ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (ctx, i) {
                    final n = _notifications[i];
                    return GestureDetector(
                      onTap: () => setState(() => n.isRead = true),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: n.isRead
                              ? theme.cardTheme.color
                              : theme.colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: n.isRead
                              ? null
                              : Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle),
                            child: Center(
                              child: Text(n.title.split(' ').first,
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      n.title
                                          .substring(n.title.indexOf(' ') + 1),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(n.body,
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(_formatTime(n.time, s),
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11)),
                                ]),
                          ),
                          if (!n.isRead)
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle)),
                        ]),
                      ),
                    );
                  },
                ),
    );
  }
}
