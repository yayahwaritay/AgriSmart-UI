import 'package:flutter/material.dart';

import 'agrismart_colors.dart';

extension AgriSmartThemeX on BuildContext {
  AgriSmartColors get agriColors => Theme.of(this).extension<AgriSmartColors>()!;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
