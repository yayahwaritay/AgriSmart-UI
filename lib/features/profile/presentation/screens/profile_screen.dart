import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/app_menu_button.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../widgets/about_card.dart';
import '../widgets/account_card.dart';
import '../widgets/theme_toggle.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Row(
              children: [
                const AppMenuButton(),
                const SizedBox(width: 12),
                Text('Profile', style: context.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 20),
            const AccountCard(),
            const SizedBox(height: 16),
            const ThemeToggle(),
            const SizedBox(height: 16),
            const AboutCard(),
          ],
        ),
      ),
    );
  }
}
