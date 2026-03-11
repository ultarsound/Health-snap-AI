import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_strings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = AppStrings.from(p.isArabic);
    return Scaffold(
      body: Center(
        child: Text(s.profileSoon, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
