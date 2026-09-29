import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';

/// Circular glass icon button that opens the nearest [Scaffold]'s
/// [AppSidebar] drawer. Placed in the header of each shell tab.
class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return Material(
      color: colors.primary.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => Scaffold.of(context).openDrawer(),
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(Icons.menu_rounded, color: colors.primary, size: 22),
        ),
      ),
    );
  }
}
